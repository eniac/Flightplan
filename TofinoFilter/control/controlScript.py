"""
Simple controller that: 
1. opens ports.
2. adds rules.
3. deletes rules/ports.
"""
progName = "boostFilter"

import importlib
import os
import logging
import unittest
import re
import time
import ptf
from ptf import config

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.protocol import TMultiplexedProtocol

from res_pd_rpc.ttypes import * # DevTarget_t
from ptf.thriftutils import * # hex_to_i16
from pltfm_pm_rpc.ttypes import * # pltfm_pm_port_speed_t


exec("from %s.p4_pd_rpc.ttypes import *"%progName)
exec("from %s.p4_pd_rpc.%s import *"%(progName, progName))
from controlManagerBase import *

this_dir = os.path.dirname(os.path.abspath(__file__))

# L1 configuration. 
host_ports_1 = ["25/0", "25/1", "25/2", "25/3"]
aggregate_ports_1 = ["3/0"]
boost_ports_1 = ["5/0"]

host_ports_2 = ["26/0", "26/1", "26/2", "26/3"]
aggregate_ports_2 = ["4/0"]
boost_ports_2 = ["6/0"]


class StaticVswitch(object):
    def __init__(self, sid):
        self.sid = sid
        self.lMacMap = {}
        self.aggPort = None
        self.boostPort = None

    def addStation(self, mac, port):
        """
        add a L2 host. Pass this a mac address and a dev_port.
        """
        self.lMacMap[mac] = port
    def addAggLink(self, port):
        """
        add an uplink / aggregation link. 
        """
        self.aggPort = port
    def addBoostLink(self, port):
        """
        add a port to a booster.
        """
        self.boostPort = port
    def export(self):
        return (self.lMacMap, self.aggPort, self.boostPort)


# --preload-pcap --loop=10 --topspeed -i

def main():
    # init.    
    mgr = BoostControlManager(["boostFilter"])
    mgr.start()


    # ports up.
    host_ports_dev_1 = mgr.ports_up(host_ports_1, "25G", "NONE")
    aggregate_ports_dev_1 = mgr.ports_up(aggregate_ports_1, "100G", "RS")
    boost_ports_dev_1 = mgr.ports_up(boost_ports_1, "100G", "RS")

    host_ports_dev_2 = mgr.ports_up(host_ports_2, "25G", "NONE")
    aggregate_ports_dev_2 = mgr.ports_up(aggregate_ports_2, "100G", "RS")
    boost_ports_dev_2 = mgr.ports_up(boost_ports_2, "100G", "RS")


    s1 = StaticVswitch(1)
    s1.addStation("ec:0d:9a:6d:e0:b8", 191)
    s1.addStation("ec:0d:9a:7e:91:82", 183)
    s1.addAggLink(aggregate_ports_dev_1[0])
    s1.addBoostLink(boost_ports_dev_1[0])

    # add switches. 
    mgr.addVswitch(s1)
    # install rules for port --> switch mapping.
    mgr.addVswitchRules(s1.sid)

    # s2 = StaticVswitch(2)
    # s2.addStation("ec:0d:9a:7e:91:82", 183)
    # s2.addAggLink(aggregate_ports_dev_2[0])
    # s2.addBoostLink(boost_ports_dev_2[0])
    # mgr.addVswitch(s2)
    # mgr.addVswitchRules(s2.sid)

    # install unicast rules. 
    print "installing unicast rules."
    mgr.addUnicastRules()

    # install broadcast rules. 
    print "installing broadcast rules."
    mgr.addMcGroups()
    mgr.addBroadcastRules()

    # mgr.dump_table("setSwitchIdTable")
    mgr.dump_table("forwardingTable")

    # add rules to enable boosting (all switches)
    # mgr.add_admission_rules()


    # wait for signal from user.
    raw_input("Press any key to tear down ...")

    # cleanup tables.
    mgr.cleanup_table("setSwitchIdTable")
    mgr.cleanup_table("forwardingTable")

    # close connection.
    mgr.end()

class BoostControlManager(ControlManagerBase):
    def __init__(self, p4_names, p4_prefixes=[]):
        ControlManagerBase.__init__(self, p4_names, p4_prefixes)
        # internal mapping structures. 
        self.sidToMac = {}
        self.sidToLocal = {}
        self.sidToAgg = {}
        self.sidToBoost = {}
        self.localToSid = {}

        self.mc_group_hdls = []

    # custom methods. 
    def addVswitch(self, vSwitch):
        """
        Add a switch object to the topology. 
        """
        # update maps.
        self.sidToMac[vSwitch.sid] = vSwitch.lMacMap
        self.sidToAgg[vSwitch.sid] = vSwitch.aggPort        
        self.sidToBoost[vSwitch.sid] = vSwitch.boostPort        
        # rebuild convenience maps. 
        self.sidToLocal = {k: v.values() for k, v in self.sidToMac.items()}
        self.localToSid = {}        
        for sid, localList in self.sidToLocal.items():
            for local in localList:
                self.localToSid[local] = sid

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


    def add_admission_rules(self):
        """
        Add admission control rules. 
        """
        # boostEndpointTable
        self.client.boostEndpointTable_set_default_action_setBoostFlag(self.sess_hdl, self.dev_tgt)
        self.conn_mgr.complete_operations(self.sess_hdl)

    def add_boost_rules(self, fwd_ports_dev):
        """
        Add rules for boosting preprocessing. 
        """
        self.client.boostPreprocTable_set_default_action_setBoostHeader_BOOST_TOFPGA(self.sess_hdl, self.dev_tgt)
        self.conn_mgr.complete_operations(self.sess_hdl)


if __name__ == '__main__':
	main()