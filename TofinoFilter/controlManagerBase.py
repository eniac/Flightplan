"""
Simple controller that: 
1. opens ports.
2. adds rules.
3. deletes rules/ports.
"""

import importlib
import os
import logging
import unittest
import re
from binascii import hexlify
import ptf
from ptf import config

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.protocol import TMultiplexedProtocol

from res_pd_rpc.ttypes import * # DevTarget_t
from ptf.thriftutils import * # hex_to_i16
import port_mapping
from pltfm_pm_rpc.ttypes import * # pltfm_pm_port_speed_t
from globalCounter.p4_pd_rpc.ttypes import * # for this specific app.

this_dir = os.path.dirname(os.path.abspath(__file__))


class ControlManagerBase(object):
    def __init__(self, p4_names, p4_prefixes=[]):
        self.devPorts = []
        assert( (type(p4_names) is list) and (len(p4_names) > 0) )
        if p4_prefixes:
            assert( (type(p4_prefixes) is list) and (len(p4_prefixes) == len(p4_names)) )
        else:
            p4_prefixes = p4_names
        self.p4_names = p4_names
        self.p4_prefixes = p4_prefixes
        self.p4_client_modules = {}
        for p4_name, p4_prefix in zip(p4_names, p4_prefixes):
            if p4_name == "":
                self.p4_client_modules[p4_name] = importlib.import_module(".".join(["p4_pd_rpc", p4_prefix]))
            else:
                self.p4_client_modules[p4_name] = importlib.import_module(".".join([p4_name, "p4_pd_rpc", p4_prefix]))
        self.mc_client_module = importlib.import_module(".".join(["mc_pd_rpc", "mc"]))
        try:
            self.mirror_client_module = importlib.import_module(".".join(["mirror_pd_rpc", "mirror"]))
        except:
            self.mirror_client_module = None
        try:
            self.sd_client_module = importlib.import_module(".".join(["sd_pd_rpc", "sd"]))
        except:
            self.sd_client_module = None
        try:
            self.plcmt_client_module = importlib.import_module(".".join(["plcmt_pd_rpc", "plcmt"]))
        except:
            self.plcmt_client_module = None
        try:
            self.devport_mgr_client_module = importlib.import_module(".".join(["devport_mgr_pd_rpc", "devport_mgr"]))
        except:
            self.devport_mgr_client_module = None
        try:
            self.port_mgr_client_module = importlib.import_module(".".join(["port_mgr_pd_rpc", "port_mgr"]))
        except:
            self.port_mgr_client_module = None
        self.conn_mgr_client_module = importlib.import_module(".".join(["conn_mgr_pd_rpc", "conn_mgr"]))
        try:
            self.pkt_client_module = importlib.import_module(".".join(["pkt_pd_rpc", "pkt"]))
        except:
            self.pkt_client_module = None

        try:
            self.pltfm_pm_client_module = importlib.import_module(".".join(["pltfm_pm_rpc", "pltfm_pm_rpc"]))
        except:
            self.pltfm_pm_client_module = None
        try:
            self.pltfm_mgr_client_module = importlib.import_module(".".join(["pltfm_mgr_rpc", "pltfm_mgr_rpc"]))
        except:
            self.pltfm_mgr_client_module = None
        try:
            self.diag_client_module = importlib.import_module(".".join(["diag_rpc", "diag_rpc"]))
        except:
            self.diag_client_module = None


    def start(self):

        # Set up thrift client and contact server
        thrift_server = 'localhost'
        self.transport = TSocket.TSocket(thrift_server, 9090)

        self.transport = TTransport.TBufferedTransport(self.transport)
        bprotocol = TBinaryProtocol.TBinaryProtocol(self.transport)
        # And the pltfm server as well
        self.transport_pltfm = None
        if self.pltfm_pm_client_module or self.pltfm_mgr_client_module:
            thrift_server = 'localhost'
            self.transport_pltfm = TSocket.TSocket(thrift_server, 9095)
            self.transport_pltfm = TTransport.TBufferedTransport(self.transport_pltfm)
            bprotocol_pltfm = TBinaryProtocol.TBinaryProtocol(self.transport_pltfm)

        # And the diag server as well
        self.transport_diag = None
        if self.diag_client_module:
            thrift_server = 'localhost'
            self.transport_diag = TSocket.TSocket(thrift_server, 9096)
            self.transport_diag = TTransport.TBufferedTransport(self.transport_diag)
            #bprotocol_diag = TBinaryProtocol.TBinaryProtocol(self.transport_diag)

        self.mc_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "mc")
        if self.mirror_client_module:
            self.mirror_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "mirror")
        if self.sd_client_module:
            self.sd_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "sd")
        if self.plcmt_client_module:
            self.plcmt_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "plcmt")
        if self.devport_mgr_client_module:
            self.devport_mgr_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "devport_mgr")
        else:
            self.devport_mgr_protocol = None
        if self.port_mgr_client_module:
            self.port_mgr_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "port_mgr")
        else:
            self.port_mgr_protocol = None
        self.conn_mgr_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "conn_mgr")
        if self.pkt_client_module:
            self.pkt_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, "pkt")
        else:
            self.pkt_protocol = None

        if self.pltfm_pm_client_module and self.transport_pltfm:
            self.pltfm_pm_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol_pltfm, "pltfm_pm_rpc")
        else:
            self.pltfm_pm_protocol = None
        if self.pltfm_mgr_client_module and self.transport_pltfm:
            self.pltfm_mgr_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol_pltfm, "pltfm_mgr_rpc")
        else:
            self.pltfm_mgr_protocol = None
        if self.diag_client_module and self.transport_diag:
            self.diag_protocol = TBinaryProtocol.TBinaryProtocol(self.transport_diag)
        else:
            self.diag_protocol = None
        self.p4_protocols = {}
        self.clients = {}
        self.client = None
        for p4_name, p4_prefix in zip(self.p4_names, self.p4_prefixes):
            p4_protocol = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, p4_prefix)
            self.p4_protocols[p4_name] = p4_protocol
            self.clients[p4_name] = self.p4_client_modules[p4_name].Client(p4_protocol)

        if len(self.clients) == 1:
            self.client = self.clients.values()[0]

        self.mc = self.mc_client_module.Client(self.mc_protocol)
        if self.mirror_client_module:
            self.mirror = self.mirror_client_module.Client(self.mirror_protocol)
        else:
            self.mirror = None
        if self.sd_client_module:
            self.sd = self.sd_client_module.Client(self.sd_protocol)
        else:
            self.sd = None
        if self.plcmt_client_module:
            self.plcmt = self.plcmt_client_module.Client(self.plcmt_protocol)
        else:
            self.plcmt = None
        if self.devport_mgr_client_module:
            self.devport_mgr = self.devport_mgr_client_module.Client(self.devport_mgr_protocol)
        else:
            self.devport_mgr = None
        if self.port_mgr_client_module:
            self.port_mgr = self.port_mgr_client_module.Client(self.port_mgr_protocol)
        else:
            self.port_mgr = None
        self.conn_mgr = self.conn_mgr_client_module.Client(self.conn_mgr_protocol)
        if self.pkt_client_module:
            self.pkt = self.pkt_client_module.Client(self.pkt_protocol)
        else:
            self.pkt = None

        if self.pltfm_pm_client_module and self.transport_pltfm:
            self.pltfm_pm = self.pltfm_pm_client_module.Client(self.pltfm_pm_protocol)
        else:
            self.pltfm_pm = None
        if self.pltfm_mgr_client_module and self.transport_pltfm:
            self.pltfm_mgr = self.pltfm_mgr_client_module.Client(self.pltfm_mgr_protocol)
        else:
            self.pltfm_mgr = None
        if self.diag_client_module and self.transport_diag:
            self.diag = self.diag_client_module.Client(self.diag_protocol)
        else:
            self.diag = None
        self.transport.open()
        if self.transport_pltfm:
            try:
                self.transport_pltfm.open()
            except:
                print "Did not connect to pltfm thrift server"
                self.transport_pltfm = None
                self.pltfm_mgr = None
                self.pltfm_pm = None
        if self.transport_diag:
                try:
                    self.transport_diag.open()
                except:
                    print "Did not connect to diag thrift server"
                    self.transport_diag = None
                    self.diag = None


        self.sess_hdl = self.conn_mgr.client_init()
        self.dev_tgt = DevTarget_t(0, hex_to_i16(0xFFFF))

        self.platform_type = "mavericks"
        board_type = self.pltfm_pm.pltfm_pm_board_type_get()
        if re.search("0x0234|0x1234|0x4234", hex(board_type)):
            self.platform_type = "mavericks"
        elif re.search("0x2234|0x3234", hex(board_type)):
            self.platform_type = "montara"

        return self.client

    def end(self):
        self.ports_down()

        # close client connection.
        print ("closing connection to asic.")
        self.conn_mgr.client_cleanup(self.sess_hdl)        
        if self.transport_pltfm:
            self.transport_pltfm.close()
        if self.transport_diag:
            self.transport_diag.close()
        self.transport.close()

    # helper. Dumps information about a table.
    def dump_table(self, table):
        '''' Dump all entries of a table'''
        dev_tgt = DevTarget_t(0, hex_to_i16(0xFFFF))
        table = 'self.client.' + table

        # fetch the total number of entries
        num_entries = eval(table + '_get_entry_count')\
                (self.sess_hdl, dev_tgt.dev_id)
        print 'Table: %s'%table + ' Number of entries : {}'.format(num_entries)
        if num_entries == 0:
            return

        # fetch the first entry
        hdl = eval(table + '_get_first_entry_handle')\
                (self.sess_hdl, dev_tgt)

        # fetch the remaining entries
        if num_entries > 1:
            hdls = eval(table + '_get_next_entry_handles')\
                (self.sess_hdl, dev_tgt.dev_id, hdl, num_entries - 1)
            hdls.insert(0, hdl)
        else:
            hdls = [hdl]

        # dump the entries
        i = 1
        for hdl in hdls:
            entry = eval(table + '_get_entry')\
                (self.sess_hdl, dev_tgt.dev_id, hdl, True)
            print '\tEntry', i
            print '\t    Match:'
            for key, val in entry.match_spec.__dict__.iteritems():
                if type(val) == str:                    
                    print '        ',
                    print key, ':', hexlify(val)
                else:
                    print '        ',
                    print key, ':', val

            if hasattr(entry, 'action_desc'):
                print '\t    Action:', entry.action_desc.name
                print '\t    Data:',
                for key, val in entry.action_desc.data.__dict__.items():
                    print '        ',
                    print key, ':', val
            elif hasattr(entry, 'members'):
                print '\t    Members:', entry.members
            i += 1    

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

    # bring up ports based on name.
    def ports_up(self, fp_ports):
        devPorts = port_mapping.getDevPorts(self.platform_type, fp_ports)

        print ("enabling ports: %s (dev ids: %s)"%(fp_ports, devPorts))
        # add and enable the ports
        for i in devPorts:
            print ("port: %s"%i)
            try:            
                self.pltfm_pm.pltfm_pm_port_add(0, i,
                                       pltfm_pm_port_speed_t.BF_SPEED_40G,
                                       pltfm_pm_fec_type_t.BF_FEC_TYP_NONE)
                self.pltfm_pm.pltfm_pm_port_enable(0, i)
            except:
                print ("\tport not enabled (already up?)")

        self.devPorts += devPorts
        return devPorts

    # bring down ports.
    def ports_down(self):
        for i in self.devPorts:
            print ("deleting port: %s"%i)
            self.pltfm_pm.pltfm_pm_port_del(0, i)
        self.pltfm_pm.pltfm_pm_switchd_port_cleanup(0)


    def add_boost_rules(self):
        self.platform_type = "mavericks"
        board_type = self.pltfm_pm.pltfm_pm_board_type_get()
        if re.search("0x0234|0x1234|0x4234", hex(board_type)):
            self.platform_type = "mavericks"
        elif re.search("0x2234|0x3234", hex(board_type)):
            self.platform_type = "montara"

        # get the device ports from front panel ports
        # manual lookup from bf-sde. 128 = 1/0, 136 = 2/0
        # self.devPorts = getDevPorts(self.platform_type, fp_ports)

        print ("enabling ports: %s"%self.devPorts)
        # add and enable the ports
        for i in self.devPorts:
            print ("port: %s"%i)
            try:            
                self.pltfm_pm.pltfm_pm_port_add(0, i,
                                       pltfm_pm_port_speed_t.BF_SPEED_40G,
                                       pltfm_pm_fec_type_t.BF_FEC_TYP_NONE)
                self.pltfm_pm.pltfm_pm_port_enable(0, i)
            except:
                print ("\tport not enabled (already up?)")


        # add rule from 1 to 2.
        matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:34"))
        actnspec = boostFilter_set_egr_action_spec_t(self.devPorts[1])
        result = self.client.forwardTable_table_add_with_set_egr(
                                                            self.sess_hdl,
                                                            self.dev_tgt,
                                                            matchspec,
                                                            actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)


        # add rule from 2 to 1.
        matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:35"))
        actnspec = boostFilter_set_egr_action_spec_t(self.devPorts[0])
        result = self.client.forwardTable_table_add_with_set_egr(
                                                            self.sess_hdl,
                                                            self.dev_tgt,
                                                            matchspec,
                                                            actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        # add rules from any port to booster.
        matchspec = boostFilter_boostTable_match_spec_t(self.devPorts[0])
        actnspec = boostFilter_set_egr_action_spec_t(self.devPorts[2])
        result = self.client.boostTable_table_add_with_set_egr(
                                                            self.sess_hdl,
                                                            self.dev_tgt,
                                                            matchspec,
                                                            actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        matchspec = boostFilter_boostTable_match_spec_t(self.devPorts[1])
        actnspec = boostFilter_set_egr_action_spec_t(self.devPorts[2])
        result = self.client.boostTable_table_add_with_set_egr(
                                                            self.sess_hdl,
                                                            self.dev_tgt,
                                                            matchspec,
                                                            actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        

        

    def add_simple_rule(self, table):

        # get the device ports from front panel ports
        # manual lookup from bf-sde. 128 = 1/0, 136 = 2/0
        # self.devPorts = getDevPorts(self.platform_type, fp_ports)

        print ("enabling ports: %s"%self.devPorts)
        # add and enable the ports
        for i in self.devPorts:
            print ("port: %s"%i)
            try:            
                self.pltfm_pm.pltfm_pm_port_add(0, i,
                                       pltfm_pm_port_speed_t.BF_SPEED_40G,
                                       pltfm_pm_fec_type_t.BF_FEC_TYP_NONE)
                self.pltfm_pm.pltfm_pm_port_enable(0, i)
            except:
                print ("\tport not enabled (already up?)")

        # match: packets from devPort[0]
        self.matchspec = simpleWire_forwardTable_match_spec_t(self.devPorts[0])
        # action: send to devPort[1]
        self.actnspec = simpleWire_set_egr_action_spec_t(self.devPorts[1])

        # program match and action spec entries
        print "Populating table entries"
        # <tablename>_table_add_with_<actionname>
        try:
            result = self.client.forwardingTable_table_add_with_set_egr(
                                                                self.sess_hdl,
                                                                self.dev_tgt,
                                                                self.matchspec,
                                                                self.actnspec)
            self.conn_mgr.complete_operations(self.sess_hdl)
        except:
            print "\tinvalid table operation! (entry already exists?)"

        print ("current table entries:")
        self.dump_table("forwardingTable")



if __name__ == '__main__':
	main()