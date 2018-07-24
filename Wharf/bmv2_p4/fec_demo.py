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

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI

from p4_mininet import P4Switch, P4Host

import argparse
from time import sleep

parser = argparse.ArgumentParser(description="FEC demo")
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action='store', required=True)
parser.add_argument('--encoder-json', help='Path to encoder JSON',
                    type=str, action='store', required=True)
parser.add_argument('--decoder-json', help='Path to decoder JSON',
                    type=str, action='store', required=True)
parser.add_argument('--dropper-json', help='Path to dropper JSON',
                    type=str, action='store', required=True)
parser.add_argument('--pcap-dump', help='Dump packets on interfaces to pcap files',
                    type=str, action="store", required=False, default=False)
parser.add_argument('--e2e', help='Provide a pcap file to be sent through',
                    type=str, action='store', required=False, default=False)
parser.add_argument('--log-console', help='Log console to this directory',
                    type=str, action='store', required=False, default=None)

args = parser.parse_args()

class FecTopo(Topo):

    def __init__(self, bm, encoder_json, decoder_json, dropper_json, pcap_dump, log_console, **opts):
        Topo.__init__(self, **opts)

        params = (
                ('encoder', encoder_json, 9090),
                ('dropper', dropper_json, 9091),
                ('decoder', decoder_json, 9092)
        )

        switches = []

        for i, (name, json, port) in enumerate(params):
            if log_console:
                console_log = '{}/{}.log'.format(log_console, name)
            switches.append(self.addSwitch('s%d' % i,
                                           sw_path = bm,
                                           json_path = json,
                                           thrift_port = port,
                                           pcap_dump = pcap_dump,
                                           log_console = console_log,
                                           verbose=True))

        hosts = []
        for i in range(2):
            hosts.append(self.addHost('h{}'.format(i+1),
                                      ip = '10.0.{}.1/24'.format(i),
                                      mac = '00:04:00:00:00:{:x}'.format(i)))

        nodes = [hosts[0]] + switches + [hosts[1]]

        for n1, n2 in zip(nodes, nodes[1:]):
            self.addLink(n1, n2)

def main():
    topo = FecTopo(args.behavioral_exe,
                   args.encoder_json,
                   args.decoder_json,
                   args.dropper_json,
                   args.pcap_dump,
                   args.log_console)
    net = Mininet(topo = topo,
                  host = P4Host,
                  switch = P4Switch,
                  controller = None)
    net.start()


    sw_mac = ["00:aa:bb:00:00:%02x" % n for n in xrange(2)]

    sw_addr = ["10.0.%d.1" % n for n in xrange(2)]

    for n in xrange(2):
        h = net.get('h%d' % (n + 1))
        h.setARP(sw_addr[n], sw_mac[n])
        h.setDefaultRoute("dev eth0 via %s" % sw_addr[n])

    for n in xrange(2):
        h = net.get('h%d' % (n + 1))
        h.describe()

    sleep(1)

    print "Ready !"

    if args.e2e:
        h1 = net.get('h%d' % (1))
        h1.cmd('tcpreplay -p 100 -i eth0 {}'.format(args.e2e))
        sleep(2)
    else:
        CLI( net )

    net.stop()

if __name__ == '__main__':
    setLogLevel( 'debug' )
    main()
