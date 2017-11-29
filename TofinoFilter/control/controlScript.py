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

fwd_ports = ["1/0", "2/0"]
boost_ports = ["3/0"]

def main():
    # init.    
    mgr = BoostControlManager(["boostFilter"])
    mgr.start()
    # ports up.
    fwd_ports_dev = mgr.ports_up(fwd_ports, "100G", "RS")
    boost_ports_dev = mgr.ports_up(boost_ports, "100G", "RS")

    # wipe tables.
    mgr.cleanup_table("forwardTable")
    mgr.cleanup_table("boostTable")

    # add rules.
    mgr.add_boost_rules(fwd_ports_dev, boost_ports_dev)

    # dump tables.
    mgr.dump_table("forwardTable")
    mgr.dump_table("boostTable")

    # cleanup tables.
    mgr.cleanup_table("forwardTable")
    mgr.cleanup_table("boostTable")

    # close connection.
    mgr.end()

class BoostControlManager(ControlManagerBase):
    def __init__(self, p4_names, p4_prefixes=[]):
        ControlManagerBase.__init__(self, p4_names, p4_prefixes)
    # custom methods. 
    def add_boost_rules(self, fwd_ports_dev, boost_ports_dev):
        """
        Add rules for simple booster. 
        """
        # switch mapping rules. 
        # 1: ports 27 (vin1), 1 (link), and 3 (booster)
        # 2: ports 28 (vin2), 2 (link), and 4 (booster)

        # forwarding rules: 
        # switch 1: 
        # port 27 --> port 1
        # switch 2: 
        # port 2 --> port 28

        # admission rules: 
        # default (once enabled)

        # all other rules: default


        # add rule from 1 to 2.
        matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:34"))
        actnspec = boostFilter_set_egr_action_spec_t(fwd_ports_dev[1])
        result = self.client.forwardTable_table_add_with_set_egr(self.sess_hdl,self.dev_tgt,matchspec,actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        # add rule from 2 to 1.
        matchspec = boostFilter_forwardTable_match_spec_t(ethernet_dstAddr=macAddr_to_string("24:8a:07:5b:15:35"))
        actnspec = boostFilter_set_egr_action_spec_t(fwd_ports_dev[0])
        result = self.client.forwardTable_table_add_with_set_egr(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        # add rules from any port to booster.
        matchspec = boostFilter_boostTable_match_spec_t(fwd_ports_dev[0])
        actnspec = boostFilter_set_egr_action_spec_t(boost_ports_dev[0])
        result = self.client.boostTable_table_add_with_set_egr(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        matchspec = boostFilter_boostTable_match_spec_t(fwd_ports_dev[1])
        actnspec = boostFilter_set_egr_action_spec_t(boost_ports_dev[0])
        result = self.client.boostTable_table_add_with_set_egr(self.sess_hdl, self.dev_tgt, matchspec, actnspec)
        self.conn_mgr.complete_operations(self.sess_hdl)

        
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