#!/usr/bin/env python2

# Copyright 2013-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import os
import sys
if 'BMV2_REPO' in os.environ:
    newpath  = os.path.join(os.environ['BMV2_REPO'], 'tools')
    print("Appending {} to pythonpath".format(newpath))
    sys.path.append(newpath)
else:
    print("WARNING: BMV2_REPO variable not found")
    print("Unless behavioral-model/tools has been added to the path explicitly, "
          "this test will likely fail")

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI

from flightplan_p4_mininet import P4Switch, P4Host, send_commands

from collections import defaultdict
import argparse
import yaml
from time import sleep

parser = argparse.ArgumentParser(description="Flightplan Mininet Layout")
parser.add_argument('config', help="Path to topological configuration yaml file")
parser.add_argument('--pcap-dump', help="Path to directory to dump pcap files into",
                    type=str, required=False, default=None)
parser.add_argument('--verbose', help='Turn on console logging',
                    action='store_true')
parser.add_argument('--log', help='Log to this directory',
                    type=str, required=False, default=None)
parser.add_argument('--cli', help='Run CLI',
                    action='store_true')
parser.add_argument('--bmv2-exe', help='Path to bmv2 executable',
                    type=str, required=False, default=None)
parser.add_argument('--replay', help='Provide a pcap file to be sent through from h1 to h2',
                    type=str, action='store', required=False, default=False)
parser.add_argument('--host-prog', help='Run a program on a host. Syntax = "hostname:program to run"',
                    type=str, action='append', required=False, default=[])
parser.add_argument('--time', help='Time to run mininet for',
                    type=int, required=False, default=1)
# Modified below in main execution
# (sorry for the global)
global cfg_file

def cfgpath(path):
    cfg_dir = os.path.dirname(os.path.realpath(cfg_file))
    return os.path.join(cfg_dir, path)

class FPTopo(Topo):

    def __init__(self, host_spec, switch_spec, sw_path, log, verbose, pcap_dump):
        Topo.__init__(self)

        link_names = []
        self.all_links = {}

        self.log_dir = log
        self.host_spec = host_spec
        self.switch_spec = switch_spec
        self.all_nodes = {}
        base_thrift = 9090

        switch_items = sorted(switch_spec.items(), key=lambda x: x[0])

        for i, (sw_name, sw_opts) in enumerate(switch_items):
            if log:
                console_log = os.path.join(log, sw_name+'.log')
            else:
                console_log = None

            switch = self.addSwitch(sw_name,
                                    sw_path = sw_path,
                                    json_path = cfgpath(sw_opts['cfg']),
                                    thrift_port = base_thrift + i,
                                    pcap_dump = pcap_dump,
                                    log_console = console_log,
                                    verbose = verbose)

            self.all_nodes[sw_name] = dict(
                    node=switch,
                    port=base_thrift+i)


            link_names.extend([(sw_name, link) for link in sw_opts.get('links', [])])
            print("SWITCH: %s" % self.all_nodes[sw_name])

        for i, host in enumerate(sorted(host_spec)):
            self.all_nodes[host] = dict(
                    node = (self.addHost(host,
                                         ip = '10.0.{}.1/24'.format(i),
                                         mac = '00:04:00:00:00:{:02x}'.format(i),
                                         pcap_dump= pcap_dump)),
                    ip = '10.0.{}.1'.format(i),
                    mac = '00:04:00:00:00:{:02x}'.format(i),
            )
            print("HOST: %s" % self.all_nodes[host])

            #nodes[host].setDefaultRoute('dev eth0 via 10.0.%d.1' %i)

        n_links = defaultdict(int)

        for i, (name1, name2) in enumerate(link_names):
            n1 = self.all_nodes[name1]['node']
            n2 = self.all_nodes[name2]['node']

            i1 = n_links[n1]
            n_links[n1] += 1

            i2 = n_links[n2]
            n_links[n2] += 1

            self.addLink(n1, n2,
                         port1=i1,
                         port2=i2)
            self.all_links['{}-{}'.format(name1,name2)] = i1
            self.all_links['{}-{}'.format(name2,name1)] = i2


    def init(self, net):

        for node1 in self.host_spec:
            #for node2 in self.host_spec:
                #if node1 == node2:
                #    continue
            h1 = net.get(node1)
            h1.cmd('ip route add default dev eth0 via ' + self.all_nodes[node1]['ip'])
            #h1.setDefaultRoute('dev eth0 via ' + self.all_nodes[node1]['ip'])

        for node in self.host_spec:
            n = net.get(node)
            n.describe()

    def start_host_dump(self, net, directory):
        for host in self.host_spec:
            fname = os.path.join(directory, host + '_out.pcap')
            print("Dumping {} output to {}".format(host, fname))
            net.get(host).cmd('tcpdump -i eth0 -Q out -w {}&'.format(fname))
            fname = os.path.join(directory, host + '_in.pcap')
            print("Dumping {} input to {}".format(host, fname))
            net.get(host).cmd('tcpdump -i eth0 -Q in -w {}&'.format(fname))

    def stop_host_dump(self, net):
        print("Stopping tcpdump on hosts")
        for host in self.host_spec:
            net.get(host).cmd('pkill tcpdump')


    def do_switch_replay(self, net):
        for sw1_name, sw_opts in self.switch_spec.items():
            for sw2_name, filename in sw_opts.get('replay',{}).items():
                print("Replaying {} from {} to {}".format(filename, sw1_name, sw2_name))
                num = self.all_links['{}-{}'.format(sw1_name, sw2_name)]
                net.get(sw1_name).cmd(
                        'tcpreplay -i {}-eth{} {}'.format(sw1_name, num, cfgpath(filename))
                )
                sleep(1)

    def do_commands(self, net):
        for sw_name, sw_opts in self.switch_spec.items():
            if 'cmds' in sw_opts:
                for cmd_file in sw_opts['cmds']:
                    commands = open(cfgpath(cmd_file)).readlines()
                    send_commands(self.all_nodes[sw_name]['port'], cfgpath(sw_opts['cfg']), commands)

    def run_host_programs(self, net, extras):
        for name, spec in self.host_spec.items():
            if 'program' in spec:
                print("Running {} on {}".format(spec['program'], name))
                net.get(name).cmd('{} > {}/{}_prog.log 2>&1 &'.format(spec['program'], self.log_dir, name))

        for extra_prog in extras:
            try:
                name, program = extra_prog.split(':')
            except:
                print("Programs provided from cli must be of form 'h1:program to run'")
                raise
            print("Running {} on {}".format(program, name))
            net.get(name).cmd('{} > {}/{}_prog.log 2>&1 &'.format(program, self.log_dir, name))

    def do_host_replay(self, net, host, towards, file):
        print("Replaying {} on {}.eth0".format(file, host))
        net.get(host).cmd(
                'tcpreplay -p 100 -i eth0 {}'.format(file)
        )

def main():
    global cfg_file
    args = parser.parse_args()

    if args.bmv2_exe is None:
        bmv2_exe = os.path.join(os.environ['BMV2_REPO'], 'targets', 'booster_switch', 'simple_switch')
    else:
        bmv2_exe = args.bmv2_exe

    cfg_file = args.config

    with open(args.config) as f:
        cfg = yaml.load(f)

    topo = FPTopo(cfg['hosts'], cfg['switches'],
                  bmv2_exe, args.log, args.verbose, args.pcap_dump)

    print("Starting mininet")
    net = Mininet(topo=topo, host=P4Host, switch=P4Switch, controller=None)

    net.start()

    topo.init(net)

    if args.pcap_dump:
        topo.start_host_dump(net, args.pcap_dump)


    sleep(1)

    topo.do_switch_replay(net)

    sleep(1)

    topo.do_commands(net)

    topo.run_host_programs(net, args.host_prog)

    if args.replay:
        replay_args = args.replay.split(":")
        replay_arg1 = replay_args[0].split('-')
        if len(replay_args) != 2 or len(replay_arg1) != 2:
            raise Exception("args.replay must have form Host-Switch:File")
        topo.do_host_replay(net, replay_arg1[0], replay_arg1[1], replay_args[1])
        sleep(1)

    sleep(args.time)

    if args.cli:
        CLI(net)

    if args.pcap_dump:
        topo.stop_host_dump(net)
    print("Stoping mininet")

if __name__ == '__main__':
    setLogLevel('debug')
    main()


