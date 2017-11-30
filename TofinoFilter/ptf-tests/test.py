import unittest
import pd_base_tests

from ptf import config
from ptf.testutils import *
from ptf.thriftutils import *

from boostFilter.p4_pd_rpc.ttypes import *
from res_pd_rpc.ttypes import *

class RegisterTest(pd_base_tests.ThriftInterfaceDataPlane):
    def __init__(self):
        pd_base_tests.ThriftInterfaceDataPlane.__init__(self,
                                                        ["boostFilter"])
        self.sidToMac = {1: {"11:11:11:11:11:11":1, "77:77:77:77:77:77": 7, "88:88:88:88:88:88": 8}, 2:{"44:44:44:44:44:44":4}}
        self.sidToLocal = {k: v.values() for k, v in self.sidToMac.items()}
        # self.sidToLocal = {1: [1], 2:[4]}
        self.sidToAgg = {1: 2, 2:5}
        self.sidToBoost = {1: 3, 2: 6}

        self.localToSid = {}
        for sid, localList in self.sidToLocal.items():
            for local in localList:
                self.localToSid[local] = sid

        self.mc_group_hdls = []



    def addVswitchRules(self, sid):
        """
        Add rules to initialize a virtual switch that owns a slice of the ports.
        """
        print self.sidToLocal[sid]
        print [self.sidToAgg[sid]]
        for portId in self.sidToLocal[sid] + [self.sidToAgg[sid]]:
            matchspec = boostFilter_setSwitchIdTable_match_spec_t(ig_intr_md_ingress_port=portId)
            actnspec = boostFilter_setSwitchId_action_spec_t(sid, self.sidToBoost[sid])
            result = self.client.setSwitchIdTable_table_add_with_setSwitchId(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
            self.conn_mgr.complete_operations(self.sess_hdl)

    def addMcGroups(self):
        """
        create a multicast flood group for each port.
        """
        lag_map = set_port_or_lag_bitmap(256, [])

        # flood to every other port in your group besides the booster. 
        for port, sid in self.localToSid.items():
            mc_id = port
            flood_ports = self.sidToLocal[sid] + [self.sidToAgg[sid]]
            flood_ports = list(set(flood_ports) - set([port]))
            print ("sid: %s port: %s flood_ports: %s"%(sid, port, flood_ports))
            port_map = set_port_or_lag_bitmap(288, flood_ports)
            mc_grp_hdl = self.mc.mc_mgrp_create(self.mc_sess_hdl, self.dev_tgt.dev_id, mc_id)
            mc_node_hdl = self.mc.mc_node_create(self.mc_sess_hdl, self.dev_tgt.dev_id, 0, port_map, lag_map)
            self.mc.mc_associate_node(self.mc_sess_hdl, self.dev_tgt.dev_id, mc_grp_hdl, mc_node_hdl, 0, 0)
            self.mc_group_hdls.append(mc_grp_hdl)

        # also flood from agg.
        for sid, agg in self.sidToAgg.items():
            mc_id = agg
            flood_ports = self.sidToLocal[sid]
            port_map = set_port_or_lag_bitmap(288, flood_ports)
            mc_grp_hdl = self.mc.mc_mgrp_create(self.mc_sess_hdl, self.dev_tgt.dev_id, mc_id)
            mc_node_hdl = self.mc.mc_node_create(self.mc_sess_hdl, self.dev_tgt.dev_id, 0, port_map, lag_map)
            self.mc.mc_associate_node(self.mc_sess_hdl, self.dev_tgt.dev_id, mc_grp_hdl, mc_node_hdl, 0, 0)
            self.mc_group_hdls.append(mc_grp_hdl)


        return

    def addUnicastRule(self, sid, dmac, outport_dev):
        """ 
        add a single forwarding rule. 
        """
        matchspec = boostFilter_forwardingTable_match_spec_t(slice_md_switchId = sid, ethernet_dstAddr=macAddr_to_string(dmac))
        actnspec = boostFilter_unicast_action_spec_t(outport_dev)
        result = self.client.forwardingTable_table_add_with_unicast(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)
    def addBroadcastRule(self, sid):
        """ 
        add a single broadcast rule. 
        """
        matchspec = boostFilter_forwardingTable_match_spec_t(slice_md_switchId = sid, ethernet_dstAddr=macAddr_to_string("ff:ff:ff:ff:ff:ff"))
        result = self.client.forwardingTable_table_add_with_broadcast(self.sess_hdl,self.dev_tgt,matchspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

    def addUnicastRules(self):
        """
        Add the unicast rules. 
        """
        for lSid, lMacMap in self.sidToMac.items():
            lAgg = self.sidToAgg[lSid]
            for lMac, lPort in lMacMap.items():
                self.addUnicastRule(lSid, lMac, lPort)
            for rSid, rMacMap in self.sidToMac.items():
                for rMac, rPort in rMacMap.items():
                    if rSid != lSid: 
                        self.addUnicastRule(lSid, rMac, lAgg)

    def addBroadcastRules(self):
        """
        Add the broadcast rules. 
        """ 
        for lSid in self.sidToMac.keys():
            self.addBroadcastRule(lSid)

    def setUp(self):
        pd_base_tests.ThriftInterfaceDataPlane.setUp(self)

        self.sess_hdl = self.conn_mgr.client_init()
        self.dev      = 0
        self.dev_tgt  = DevTarget_t(self.dev, hex_to_i16(0xFFFF))

        self.mc_sess_hdl = self.mc.mc_create_session()


        print("\nConnected to Device %d, Session %d" % (
            self.dev, self.sess_hdl))
        # wipe tables.
        self.cleanup_table("setSwitchIdTable")
        self.cleanup_table("forwardingTable")

        # add mapping rules for vswitch 1 and 2.
        self.addVswitchRules(1)
        self.addVswitchRules(2)


    def runLocalUnicastTest(self):
        # add unicast rules. 
        self.addUnicastRules()
        print("Sending Packet Now")
        ingress_port = 1 
        egress_port = 1 
        pkt = simple_tcp_packet(eth_dst='11:11:11:11:11:11',
                                eth_src='00:00:00:00:00:00',
                                ip_dst='192.168.0.1',
                                ip_id=101,
                                ip_ttl=64,
                                ip_ihl=5,
                                with_tcp_chksum=True,
                                pktlen=100)
        send_packet(self, ingress_port, pkt)
        print("Expecting packet on port %d" % egress_port)
        verify_packets(self, pkt, [egress_port])

        egress_port = 2
        pkt = simple_tcp_packet(eth_dst='44:44:44:44:44:44',
                                eth_src='00:00:00:00:00:00',
                                ip_dst='192.168.0.1',
                                ip_id=101,
                                ip_ttl=64,
                                ip_ihl=5,
                                with_tcp_chksum=True,
                                pktlen=100)
        send_packet(self, ingress_port, pkt)
        print("Expecting packet on port %d" % egress_port)
        verify_packets(self, pkt, [egress_port])

        egress_port = 7
        pkt = simple_tcp_packet(eth_dst='77:77:77:77:77:77',
                                eth_src='00:00:00:00:00:00',
                                ip_dst='192.168.0.1',
                                ip_id=101,
                                ip_ttl=64,
                                ip_ihl=5,
                                with_tcp_chksum=True,
                                pktlen=100)
        send_packet(self, ingress_port, pkt)
        print("Expecting packet on port %d" % egress_port)
        verify_packets(self, pkt, [egress_port])

    def runLocalMulticastTest(self):
        # add multicast groups. 
        self.addMcGroups()
        # add broadcast rules. 
        self.addBroadcastRules()

        switch1Ports = self.sidToLocal[1] + [self.sidToAgg[1]]

        for ingress_port in switch1Ports:
            egress_ports = list(set(switch1Ports) - set([ingress_port]))
            pkt = simple_tcp_packet(eth_dst='FF:FF:FF:FF:FF:FF',
                                    eth_src='00:00:00:00:00:00',
                                    ip_dst='192.168.0.1',
                                    ip_id=101,
                                    ip_ttl=64,
                                    ip_ihl=5,
                                    with_tcp_chksum=True,
                                    pktlen=100)
            send_packet(self, ingress_port, pkt)
            print("Ingress: %s Expecting packets on ports %s"%(ingress_port, str(egress_ports)))
            verify_packets(self, pkt, egress_ports)


    def runTest(self):
        self.runLocalUnicastTest()
        self.runLocalMulticastTest()


        # # check the register. 
        # arrayLen = 32
        # flags = regprob_register_flags_t(read_hw_sync=True)
        # arrayVals = []
        # print "register values: "
        # for arrayIdx in range(arrayLen):
        #     res = self.client.register_read_reg_test(self.sess_hdl, self.dev_tgt, arrayIdx, flags)
        #     self.conn_mgr.complete_operations(self.sess_hdl)
        #     print res
        # print "regtest values: " + ", ".join([str(v) for v in arrayVals])
        
    def tearDown(self):
        # multicast teardown.
        for mc_grp_hdl in self.mc_group_hdls:
            self.mc.mc_mgrp_destroy(self.mc_sess_hdl, self.dev_tgt.dev_id, hex_to_i32(mc_grp_hdl))
        try:
            print("Clearing table entries")
            self.cleanup_table("setSwitchIdTable")
            self.cleanup_table("forwardingTable")
        except:
            print("Error while cleaning up. ")
            print("You might need to restart the driver")
        finally:
            print ("closing connection to asic.")
            self.mc.mc_destroy_session(self.mc_sess_hdl)
            self.conn_mgr.complete_operations(self.sess_hdl)
            self.conn_mgr.client_cleanup(self.sess_hdl)        
            if self.transport_pltfm:
                self.transport_pltfm.close()
            if self.transport_diag:
                self.transport_diag.close()
            self.transport.close()
            print("Closed Session %d" % self.sess_hdl)
            pd_base_tests.ThriftInterfaceDataPlane.tearDown(self) 


    # helper. deletes all the entries in a table.
    def cleanup_table(self, table):
        table = 'self.client.' + table
        # get entry count
        num_entries = eval(table + '_get_entry_count')\
                      (self.sess_hdl, self.dev_tgt.dev_id)
        if num_entries == 0:
            return
        # get the entry handles
        hdl = eval(table + '_get_first_entry_handle')\
                (self.sess_hdl, self.dev_tgt)
        if num_entries > 1:
            hdls = eval(table + '_get_next_entry_handles')\
                (self.sess_hdl, self.dev_tgt.dev_id, hdl, num_entries - 1)
            hdls.insert(0, hdl)
        else:
            hdls = [hdl]
        # delete the table entries
        for hdl in hdls:
            entry = eval(table + '_get_entry')\
                (self.sess_hdl, self.dev_tgt.dev_id, hdl, True)
            eval(table + '_table_delete_by_match_spec')\
                (self.sess_hdl, self.dev_tgt, entry.match_spec)


def port_to_pipe(port):
    return port >> 7
def port_to_pipe_local_id(port):
    return port & 0x7F
def port_to_bit_idx(port):
    pipe = port_to_pipe(port)
    index = port_to_pipe_local_id(port)
    return 72 * pipe + index

def set_port_or_lag_bitmap(bit_map_size, indicies):
    bit_map = [0] * ((bit_map_size+7)/8)
    for i in indicies:
        index = port_to_bit_idx(i)
        bit_map[index/8] = (bit_map[index/8] | (1 << (index%8))) & 0xFF
    return bytes_to_string(bit_map)

def mirror_session(mir_type, mir_dir, sid, egr_port=0, egr_port_v=False,
                   egr_port_queue=0, packet_color=0, mcast_grp_a=0,
                   mcast_grp_a_v=False, mcast_grp_b=0, mcast_grp_b_v=False,
                   max_pkt_len=0, level1_mcast_hash=0, level2_mcast_hash=0,
                   cos=0, c2c=0, extract_len=0, timeout=0, int_hdr=[]):
  return MirrorSessionInfo_t(mir_type,
                             mir_dir,
                             sid,
                             egr_port,
                             egr_port_v,
                             egr_port_queue,
                             packet_color,
                             mcast_grp_a,
                             mcast_grp_a_v,
                             mcast_grp_b,
                             mcast_grp_b_v,
                             max_pkt_len,
                             level1_mcast_hash,
                             level2_mcast_hash,
                             cos,
                             c2c,
                             extract_len,
                             timeout,
                             int_hdr,
                             len(int_hdr))

