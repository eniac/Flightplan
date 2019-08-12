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
from mininet.link import TCLink

from flightplan_p4_mininet import P4Switch, P4Host, send_commands

from collections import defaultdict
import argparse
import yaml
from pprint import pprint
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
parser.add_argument('--replay', help='Provide a pcap file to be sent through from h1 to h2. '
                                     'Syntax = "from-to:file.pcap"',
                    type=str, action='store', required=False, default=False)
parser.add_argument('--host-prog', help='Run a program on a host. Syntax = "hostname:program to run"',
                    type=str, action='append', required=False, default=[])
parser.add_argument('--pre-replay', help='Provide a pcap file to be played before a host program '
                    'in the background. Syntax = "from-to:file.pcap:bg (0 or 1)[:speed]"',
                    type=str, action='append', required=False, default=[])
parser.add_argument('--time', help='Time to run mininet for',
                    type=int, required=False, default=1)
parser.add_argument('--bw', help='Bandwidth for all links in Mbps',
                    type=float, required=False, default=1)
parser.add_argument('--pcap-to', help='Capture traffic to this device (default: all)',
                    type=str, action='append', required=False, default=[])
parser.add_argument('--pcap-from', help='Capture traffic from this device (default: all)',
                    type=str, action='append', required=False, default=[])

class TopoSpecError(Exception):
    pass

class FPTopo(Topo):

    def cfgpath(self, path):
        return os.path.join(self.cfgbase, path)

    def __init__(self, host_spec, switch_spec, sw_path, log, verbose, cfg_file, bw):
        Topo.__init__(self)
        print("Flightplan Mininet using config " + cfg_file)

        self.cfgbase = os.path.dirname(os.path.realpath(cfg_file))
        self.link_ports = defaultdict(dict)
        next_link_port = defaultdict(int)

        self.log_dir = log

        self.all_nodes = {}
        self.all_switches = {}
        self.all_hosts = {}

        base_thrift = 9090

        switch_items = sorted(switch_spec.items(), key=lambda x: x[0])

        for i, (sw_name, sw_opts) in enumerate(switch_items):

            if 'links' in sw_opts:
                raise TopoSpecError("top level 'links' specification no longer supported. " \
                                    "Use 'interfaces' instead")

            if log:
                console_log = os.path.join(log, sw_name+'.log')
            else:
                console_log = None

            if len(sw_name) > 10:
                raise TopoSpecError("Switch name '{}' too long. Max length 10 characters"
                        .format(sw_name))

            self.addSwitch(sw_name,
                           sw_path = sw_path,
                           json_path = self.cfgpath(sw_opts['cfg']),
                           thrift_port = base_thrift + i,
                           log_console = console_log,
                           verbose = verbose,
                           dpid = '{:16x}'.format(i))

            switch = dict(
                    name = sw_name,
                    cfg = sw_opts['cfg'],
                    thrift_port = base_thrift + i,
                    interfaces = [],
                    replay = sw_opts.get('replay', {}),
                    cmds = sw_opts.get('cmds', []),
            )

            self.all_nodes[sw_name] = switch
            self.all_switches[sw_name] = switch

            if 'interfaces' not in sw_opts:
                continue

            for iface_opts in sw_opts['interfaces']:
                if 'link' not in iface_opts:
                    raise TopoSpecError("Switch interface must specify at least 'link'")
                link_name = iface_opts['link']
                port_num = iface_opts.get('port', next_link_port[sw_name])

                self.link_ports[sw_name][link_name] = port_num
                next_link_port[sw_name] = max(next_link_port[sw_name], port_num+1)

                switch['interfaces'].append(iface_opts)
                switch['interfaces'][-1]['port'] = port_num

                if 'name' not in iface_opts:
                    iface_opts['name'] = self.default_iface_name(sw_name, port_num)

        for i, (host_name, host_ops) in enumerate(sorted(host_spec.items())):

            if len(host_name) > 10:
                raise TopoSpecError('Switch name "{}" too long. Max len == 10'.format(host_name))

            if 'links' in host_ops:
                raise TopoSpecError("top level 'links' specification no longer supported. " \
                                    "Use 'interfaces' instead")
            host = dict(
                    name = host_name,
                    interfaces = [],
                    # IP and MAC will be changed below if specified
                    default_ip = self.next_ip_address(),
                    default_mac = self.next_mac_address(),
                    programs = host_ops.get('programs', [])
            )

            self.all_nodes[host_name] = host
            self.all_hosts[host_name] = host
            for iface_opts in host_ops.get('interfaces', []):
                port_num = iface_opts.get('port', next_link_port[host_name])

                # If linked-to switch is specified
                if 'link' in iface_opts:
                    link_name = iface_opts['link']
                    self.link_ports[host_name][link_name] = port_num
                elif None not in self.link_ports[host_name]:
                    # Otherwise, this interface can be used as the default
                    self.link_ports[host_name][None] = port_num
                elif port_num != 0:
                    raise TopoSpecError("Interface {}-{} is neither explicitly linked, "
                                        "nor is it the default (0) interface"
                                        .format(host_name, port_num))

                next_link_port[host_name] = max(next_link_port[host_name], port_num+1)

                host['interfaces'].append(iface_opts)
                iface_opts['port'] = port_num

                if 'ip' not in iface_opts:
                    iface_opts['ip'] = self.next_ip_address()
                if 'mac' not in iface_opts:
                    iface_opts['mac'] = self.next_mac_address()

                if 'name' not in iface_opts:
                    iface_opts['name'] = self.default_iface_name(host_name, port_num)

                if port_num == 0:
                    host['default_ip'] = iface_opts['ip']
                    host['default_mac'] = iface_opts['mac']

            self.addHost(host_name,
                         ip = host['default_ip'],
                         mac = host['default_mac'],
                         )




        created_links = defaultdict(set)
        for name1, links1 in self.link_ports.items():
            for name2, port1 in links1.items():
                if name2 is None:
                    # Port is so-far unspecified
                    # Wait for it to be defined in the other direction
                    continue

                # Already added in the other direction
                if name1 in created_links[name2]:
                    continue

                if name1 not in self.link_ports[name2]:
                    # If the default interface hasn't been assigned, assign it
                    if None in self.link_ports[name2]:
                        self.link_ports[name2][name1] = self.link_ports[name2][None]
                        del self.link_ports[name2][None]
                    else:
                        self.link_ports[name2][name1] = next_link_port[name2]
                        next_link_port[name2] += 1

                port2 = self.link_ports[name2][name1]

                print("Adding link between {}.{} and {}.{}".format(name1, port1, name2, port2))
                self.addLink(name1, name2,
                             port1 = port1,
                             port2 = port2,
                             intfName1 = self.iface_name(name1, port1),
                             intfName2 = self.iface_name(name2, port2),
                             bw=bw
                             )
                created_links[name1].add(name2)
                created_links[name2].add(name1)

        for name1, links1 in self.link_ports.items():
            for name2, port1 in links1.items():
                if name2 is None:
                    raise TopoSpecError("Link from {}->{} on unspecified port".format(name1, name2))

        for name in self.all_nodes:
            if name not in self.link_ports:
                raise TopoSpecError("Node {} is not connected to anything".format(name))

    def iter_interfaces(self):
        for node in self.all_nodes.values():
            for interface in node['interfaces']:
                yield interface

    def next_mac_address(self):
        i = 1
        while True:
            mac = '00:00:00:00:00:{:02x}'.format(i)
            used = False
            for interface in self.iter_interfaces():
                if interface.get('mac','') == mac:
                    used = True
                    break
            for host in self.all_hosts.values():
                if host['default_mac'] == mac:
                    used = True
                    break
            if not used:
                return mac
            i += 1

    def next_ip_address(self):
        i = 1
        while True:
            ip = '10.0.0.{}'.format(i)
            used = False
            for interface in self.iter_interfaces():
                if interface.get('ip','').split('/')[0] == ip:
                    used = True
                    break
            for host in self.all_hosts.values():
                if host['default_ip'] == ip:
                    used = True
                    break
            if not used:
                return ip
            i += 1

    @staticmethod
    def default_iface_name(node, num):
        return '{}-eth{}'.format(node, num)

    def iface_name(self, node, num):
        opts = self.all_nodes[node]
        if 'interfaces' not in opts:
            return self.default_iface_name(node, num)
        for interface in opts['interfaces']:
            if interface['port'] == num:
                return interface.get('name', self.default_iface_name(node, num))
        return self.default_iface_name(node, num)

    def init(self, net):

        # Disable ipv6 manually
        for h in net.hosts:
            h.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
            h.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
            h.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")
        for s in net.switches:
            s.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
            s.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
            s.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")

        for name, opts in self.all_nodes.items():
            if 'interfaces' not in opts:
                continue
            node = net.get(name)
            for iface_ops in opts['interfaces']:
                if iface_ops['port'] == 0:
                    continue
                ifname = self.iface_name(name, iface_ops['port'])
                if 'ip' in iface_ops:
                    node.setIP(iface_ops['ip'], intf=ifname)
                if 'mac' in iface_ops:
                    node.setMAC(iface_ops['mac'], intf=ifname)

    def start_tcp_dump(self, net, directory, name1, name2, if1):
        iface = self.iface_name(name1, if1)

        fname = os.path.join(directory, '{}_to_{}.pcap'.format(name1, name2))
        net.get(name1).cmd('tcpdump -i {} -Q out -w {}&'.format(iface, fname))

    def start_tcp_dumps(self, net, directory, pcap_to, pcap_from):
        for name1, links in self.link_ports.items():
            for name2, if1 in links.items():
                if len(pcap_from) > 0 or len(pcap_to) > 0:
                    if name1 not in pcap_from and name2 not in pcap_to:
                        continue
                self.start_tcp_dump(net, directory, name1, name2, if1)

    def stop_tcp_dumps(self, net):
        print("Stopping tcpdump")
        for node in self.all_nodes:
            os.system('pkill tcpdump')
            #net.get(node).cmd('pkill tcpdump')

    def do_switch_replay(self, net):
        for sw1_name, sw_opts in self.all_switches.items():
            for sw2_name, filename in sw_opts['replay'].items():
                if sw2_name not in self.link_ports[sw1_name]:
                    raise TopoSpecError("Replay attempted between disconnected nodes {}->{}"
                                        .format(sw1_name, sw2_name))
                num = self.link_ports[sw1_name][sw2_name]
                print("Replaying {} from {} on {} to {}"
                      .format(filename, sw1_name, self.iface_name(sw1_name, num), sw2_name))
                net.get(sw1_name).cmd(
                        'tcpreplay -i {} {}'
                        .format(self.iface_name(sw1_name, num), self.cfgpath(filename))
                )

    def do_commands(self, net):
        for sw_name, sw_opts in self.all_switches.items():
            for cmd in sw_opts['cmds']:
                if os.path.isfile(self.cfgpath(cmd)):
                    commands = open(self.cfgpath(cmd)).readlines()
                else:
                    commands = [cmd]
                send_commands(self.all_nodes[sw_name]['thrift_port'],
                              self.cfgpath(sw_opts['cfg']), commands)

    def run_host_programs(self, net, extras):
        for name, opts in self.all_hosts.items():
            for i, program in enumerate(opts['programs']):
                print("Running {} on {}".format(program, name))
                net.get(name).cmd('{} > {}/{}_prog_{}.log 2>&1 &'
                                  .format(program, self.log_dir, name, i))

        for i, extra_prog in enumerate(extras):
            try:
                name, program = extra_prog.split(':')
            except:
                raise TopoSpecError("Programs provided from CLI must be of form 'h1:program'")
            print("Running {} on {}".format(program, name))
            net.get(name).cmd('{} > {}/{}_prog_{}.log 2>&1 &'
                              .format(program, self.log_dir, name, i))

    def do_host_replay(self, net, host, towards, file):
        port_num = self.link_ports[host][towards]
        print("Replaying {} on {}.{}".format(file, host, self.iface_name(host, port_num)))
        net.get(host).cmd(
                'tcpreplay -p 100 -i {} {}'.format(self.iface_name(host, port_num), file)
        )

    def do_pre_replay(self, net, host, towards, file, bg, speed):
        if speed is None:
            speed = 100
        port_num = self.link_ports[host][towards]
        print("Replaying {} on {}.{}".format(file, host, self.iface_name(host, port_num)))
        net.get(host).cmd(
                'tcpreplay -p {} -i {} {}{}'.format(speed, self.iface_name(host, port_num), file,
                                                    '&' if bg else '')
        )

def main():
    args = parser.parse_args()

    if args.bmv2_exe is None:
        bmv2_exe = os.path.join(os.environ['BMV2_REPO'], 'targets', 'booster_switch', 'simple_switch')
    else:
        bmv2_exe = args.bmv2_exe

    with open(args.config) as f:
        cfg = yaml.load(f)

    topo = FPTopo(cfg['hosts'], cfg['switches'],
                  bmv2_exe, args.log, args.verbose, args.config, args.bw)

    print("Starting mininet")
    net = Mininet(topo=topo, host=P4Host, switch=P4Switch, controller=None, link=TCLink)

    net.start()
    net.staticArp()

    try:
        topo.init(net)

        if args.pcap_dump:
            topo.start_tcp_dumps(net, args.pcap_dump, args.pcap_to, args.pcap_from)


        sleep(.1)

        topo.do_switch_replay(net)

        sleep(.1)

        topo.do_commands(net)

        sleep(1)

        for arg in args.pre_replay:
            replay_args = arg.split(":")
            replay_arg1 = replay_args[0].split('-')
            if len(replay_args) not in (3,4) or len (replay_arg1) != 2:
                raise Exception("args.pre_replay must have form Host-Switch:File:bg[:Speed]")
            if len(replay_args) == 4:
                speed = int(replay_args[3])
            else:
                speed = None

            bg = int(replay_args[2])

            topo.do_pre_replay(net, replay_arg1[0], replay_arg1[1], replay_args[1], bg, speed)

        topo.run_host_programs(net, args.host_prog)

        if args.replay:
            replay_args = args.replay.split(":")
            replay_arg1 = replay_args[0].split('-')
            if len(replay_args) != 2 or len(replay_arg1) != 2:
                raise Exception("args.replay must have form Host-Switch:File")
            topo.do_host_replay(net, replay_arg1[0], replay_arg1[1], replay_args[1])
            sleep(.1)

        sleep(args.time)

        if args.cli:
            CLI(net)

        if args.pcap_dump:
            topo.stop_tcp_dumps(net)
        print("Stopping mininet")
        net.stop()

    except:
        print("Encountered exception running mininet")
        try:
            net.stop()
        except:
            pass
        raise

if __name__ == '__main__':
    setLogLevel('debug')
    main()


