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

host_ports_1 = ["25/0", "25/1", "25/2", "25/3"]
aggregate_ports_1 = ["3/0"]
boost_ports_1 = ["5/0"]

host_ports_2 = ["26/0", "26/1", "26/2", "26/3"]
aggregate_ports_2 = ["4/0"]
boost_ports_2 = ["6/0"]


# --preload-pcap --loop=10 --topspeed -i

def main():
    # init.    
    mgr = BoostControlManager(["boostFilter"])
    mgr.start()

    # switch mapping. 
    # 1: ports 27 (vin1), 1 (link), and 3 (booster)
    # 2: ports 28 (vin2), 2 (link), and 4 (booster)

    # ports up.
    host_macs_1 = ["ec:0d:9a:6d:e0:b8"]
    host_ports_dev_1 = mgr.ports_up(host_ports_1, "25G", "NONE")
    aggregate_ports_dev_1 = mgr.ports_up(aggregate_ports_1, "100G", "RS")
    boost_ports_dev_1 = mgr.ports_up(boost_ports_1, "100G", "RS")

    host_macs_2 = ["ec:0d:9a:7e:91:82"]
    host_ports_dev_2 = mgr.ports_up(host_ports_2, "25G", "NONE")
    aggregate_ports_dev_2 = mgr.ports_up(aggregate_ports_2, "100G", "RS")
    boost_ports_dev_2 = mgr.ports_up(boost_ports_2, "100G", "RS")

    # # wipe tables.
    # add rules that map ports to vswitch 1.
    # mgr.add_vswitch_rules(1, host_ports_dev_1, boost_ports_dev_1[0])
    # mgr.add_vswitch_rules(2, host_ports_dev_2, boost_ports_dev_2[0])

    # add multicast groups for each vswitch.
    mgr.add_mc_group(1, host_ports_dev_1 + aggregate_ports_dev_1)
    mgr.add_mc_group(2, host_ports_dev_2 + aggregate_ports_dev_2)

    # add rules to enable boosting (all switches)
    # mgr.add_admission_rules()

    # add forwarding rules.

    # remote host --> agg port 

    # local host --> local port

    # miss --> flood
    mgr.add_miss_rule()

    # mgr.add_local_local_rules(1, host_macs_1, host_ports_dev_1)
    # mgr.add_agg_local_rules(1, host_macs_2, aggregate_ports_dev_1[0])

    # mgr.add_local_local_rules(2, host_macs_2, host_ports_dev_2)
    # mgr.add_agg_local_rules(2, host_macs_1, aggregate_ports_dev_2[0])



    # wait for signal from user.
    raw_input("Press any key to tear down ...")

    mgr.cleanup_table("setSwitchIdTable")
    # mgr.cleanup_table("boostEndpointTable")
    # mgr.cleanup_table("boostPreprocTable")

    # # add rules.
    # mgr.add_boost_rules(fwd_ports_dev, boost_ports_dev)

    # # dump tables.
    # mgr.dump_table("forwardTable")
    # mgr.dump_table("boostTable")

    # # cleanup tables.
    # mgr.cleanup_table("forwardTable")
    # mgr.cleanup_table("boostTable")

    # close connection.
    mgr.end()

class BoostControlManager(ControlManagerBase):
    def __init__(self, p4_names, p4_prefixes=[]):
        ControlManagerBase.__init__(self, p4_names, p4_prefixes)
    # custom methods. 
    def add_vswitch_rules(self, switchId, fwdPortIds, boostPortId):
        """
        Add rules to initialize a virtual switch that owns a slice of the ports.
        """
        for fwdPortId in fwdPortIds:
            matchspec = boostFilter_setSwitchIdTable_match_spec_t(ig_intr_md_ingress_port=fwdPortId)
            actnspec = boostFilter_setSwitchId_action_spec_t(switchId, boostPortId)
            result = self.client.setSwitchIdTable_table_add_with_setSwitchId(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
            self.conn_mgr.complete_operations(self.sess_hdl)
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
    def add_miss_rule(self):
        """
        Add rule for forwarding table miss. 
        """
        self.client.forwardingTable_set_default_action_l2_miss(self.sess_hdl, self.dev_tgt)
        self.conn_mgr.complete_operations(self.sess_hdl)


    # def add_forward_rules(self, switchId, host_ports_dev, agg_port_dev):
    #     for hostPortId in host_ports_dev:
    #         # matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:35"))
    #         matchspec = boostFilter_forwardingTable_match_spec_t(slice_md_switchId = switchId, ig_intr_md_ingress_port=hostPortId)
    #         actnspec = boostFilter_setSwitchId_action_spec_t(switchId, boostPortId)
    #         result = self.client.setSwitchIdTable_table_add_with_setSwitchId(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
    #         self.conn_mgr.complete_operations(self.sess_hdl)


        # all ports -> aggregate port. 

        # add switch 1, boost port --> link port.
        # add switch 2, boost port --> out port. 
        # matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:34"))
        # actnspec = boostFilter_set_egr_action_spec_t(fwd_ports_dev[1])
        # result = self.client.forwardTable_table_add_with_set_egr(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
        # self.conn_mgr.complete_operations(self.sess_hdl)


        # self.client.boostPreprocTable_set_default_action_setBoostHeader_BOOST_TOFPGA(self.sess_hdl, self.dev_tgt)
        # self.conn_mgr.complete_operations(self.sess_hdl)

        # # forwarding rules: 
        # # switch 1: 
        # # port 27 --> port 1
        # # switch 2: 
        # # port 2 --> port 28

        # # admission rules: 
        # # default (once enabled)

        # # all other rules: default


        # # add rule from 1 to 2.
        # matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:34"))
        # actnspec = boostFilter_set_egr_action_spec_t(fwd_ports_dev[1])
        # result = self.client.forwardTable_table_add_with_set_egr(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
        # self.conn_mgr.complete_operations(self.sess_hdl)

        # # add rule from 2 to 1.
        # matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:35"))
        # actnspec = boostFilter_set_egr_action_spec_t(fwd_ports_dev[0])
        # result = self.client.forwardTable_table_add_with_set_egr(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
        # self.conn_mgr.complete_operations(self.sess_hdl)

        # # add rules from any port to booster.
        # matchspec = boostFilter_boostTable_match_spec_t(fwd_ports_dev[0])
        # actnspec = boostFilter_set_egr_action_spec_t(boost_ports_dev[0])
        # result = self.client.boostTable_table_add_with_set_egr(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
        # self.conn_mgr.complete_operations(self.sess_hdl)

        # matchspec = boostFilter_boostTable_match_spec_t(fwd_ports_dev[1])
        # actnspec = boostFilter_set_egr_action_spec_t(boost_ports_dev[0])
        # result = self.client.boostTable_table_add_with_set_egr(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
        # self.conn_mgr.complete_operations(self.sess_hdl)

        
    # def add_rules(self, loop_ports_out_dev):
    #     # example of default rules -- not for booster.
    #     self.cleanup_table("setLoopOutPort")
    #     # add counter1 : incrementCounter1
    #     self.client.counter1_set_default_action_incrementCounter1(self.sess_hdl, self.dev_tgt)

    #     # add computeMod : modCounter1
    #     self.client.computeMod_set_default_action_modCounter1(self.sess_hdl, self.dev_tgt)
    #     # add setLoopOutPort : countheader.counter1ModValue --> setEgress(egress_spec)
    #     i = 0
    #     for dev_port in loop_ports_out_dev:
    #         matchspec = globalCounter_setLoopOutPort_match_spec_t(countheader_counter1ModValue=i)
    #         actnspec = globalCounter_setEgress_action_spec_t(dev_port)
    #         result = self.client.setLoopOutPort_table_add_with_setEgress(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
    #         i+=1
    #     self.conn_mgr.complete_operations(self.sess_hdl)
    #     self.dump_table("setLoopOutPort")
    #     return


if __name__ == '__main__':
	main()