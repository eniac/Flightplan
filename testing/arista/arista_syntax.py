#!/usr/bin/env python
"""
The main control application. Run this. 
"""
from __future__ import print_function
import time, select, sys, os, re, importlib, logging, unittest, binascii, logging, json, select, signal, math, argparse
import cPickle as pkl

def syntax_parser():
    # args.
    parser = argparse.ArgumentParser(description='Parse input arguments')
    parser.add_argument('--enable-kv', '-k', dest="useKv", action='store_true', help='enable KV cache near source.', default=False)
    parser.add_argument('--set-kv-port', '-kp', type=str, dest="kvPort",help='Port where KV cache lives. Default: fpga port 12/1.', default="12/1")

    parser.add_argument('--enable-fec', '-f', dest="useFec", action='store_true', help='enable FEC.', default=False)
    parser.add_argument('--set-fec-encoder', '-ep', type=str, dest="encoderPort",help='Port where FEC encoder lives. Default: fpga port 12/2.', default="12/2")
    parser.add_argument('--set-fec-decoder', '-dp', type=str, dest="decoderPort",help='Port where FEC decoder lives. Default: fpga port 12/3.', default="12/3")

    parser.add_argument('--enable-fhc', '-fc', dest="useFPGAhc", action='store_true', help='enable FPGA header compression offloading.', default=False)
    parser.add_argument('--set-hc-compressor', '-hcc', dest='compressorPort', help='Port where FPGA Header Compressor lives. Default: fpga port 13/0', default="13/1")
    parser.add_argument('--set-hc-decompressor', '-hcd', dest='decompressorPort', help='Port where FPGA header decompressor lives. Default: fpga port 13/1', default="13/2")
    parser.add_argument('--allow-ipv6', help='allow ipv6 (default is block)', action='store_true')

    return parser

queueDepthLog = []

def log(*args, **kwargs):
    pass
    #print("#### ",end='')
    #print(*args, **kwargs)


def ports_from_args(args):
    ports = dict(
            FAULTY_LINK_1 = "15/1",
            FAULTY_LINK_2 = "15/2"
    )

    if args.useFec:
        ports['FEC_ENCODE'] = args.encoderPort
        ports['FEC_DECODE'] = args.decoderPort

    if args.useKv:
        ports['KV_CACHE'] = args.kvPort

    if args.useFPGAhc:
        ports['HC_COMPRESSOR'] = args.compressorPort
        ports['HC_DECOMPRESSOR'] = args.decompressorPort

    return ports

def generate_rules(ports, allow_ipv6):
    """
    Configure the wiring table to implement the specified topology.
    """

    rules = []
    if not allow_ipv6:
        no_ipv6_rule = ['flow noipv6', 'match ethertype 0x86dd', 'action drop']
        rules.append('\n\t'.join(no_ipv6_rule) + '\nexit\n')

    broadcast_rule = ['flow broadcast', 'match destination mac FF:FF:FF:FF:FF:FF']

    clientMAC = "24:8A:07:8F:EB:00"
    serverMAC = "24:8A:07:5B:15:35"
    clientPort = "14/1"
    serverPort = "14/2"

    for port in clientPort, serverPort:
        broadcast_rule.append("action output interface Ethernet%s" % port)

    rules.extend(addRoute('iperf', clientPort, serverPort, clientMAC, serverMAC, ports))

    if 'FEC_ENCODE' in ports:
        del ports['FEC_ENCODE']
        del ports['FEC_DECODE']

    if 'HC_COMPRESSOR' in ports:
        del ports['HC_COMPRESSOR']
        del ports['HC_DECOMPRESSOR']

    # add routes for tclust 3 <--> 4
    clientMAC = "00:02:c9:3a:84:00"
    serverMAC = "7c:fe:90:1c:36:81"
    clientPort = "14/3"
    serverPort = "14/4"
    rules += addRoute('mcd', clientPort, serverPort, clientMAC, serverMAC, ports)

    for port in clientPort, serverPort:
        broadcast_rule.append("action output interface Ethernet%s" % port)

    # Add L2 broadcast rules
    rules.append('\n\t'.join(broadcast_rule) + '\nexit\n')

    return rules
    # add L2 broadcast rule and group.
    #BCAST_GID = 1004
    #simpleInterface.addExactMatch("tiBroadcast", ["FF:FF:FF:FF:FF:FF"], "aiBroadcast", [])
    #mgr.add_mc_group(BCAST_GID, [ports[i].port for i in range(1, 5)]) # multicast group is for tofino hosts on ports 1:4.

    # configure packet dropping.
    #dropRate = args.dropRate
    #RV_MAX = 4294967295
    #N = int(dropRate * RV_MAX)
    #print ("adding rule to drop %s percent of packets on src --> dest of faulty link."%dropRate)
    #simpleInterface.addExactMatch("teSetDropThresh", [ports['FAULTY_LINK_1']], "aeSetDropThresh", [N])

def addAristaRule(name, ingress, egress, mac=None, proto=None, priority=1):
    if ingress is None and mac is None and proto is None:
        raise Exception("Cannot add empty rule")

    rules = ['flow %s' % name]
    if ingress is not None:
        rules.append('match input interface ethernet %s' % ingress)

    if mac is not None:
        rules.append('match destination mac %s' % mac)

    if proto is not None:
        if proto == 0x06:
            rules.append('match ip protocol tcp')
        elif proto == 0x11:
            rules.append('match ip protocol udp')
        else:
            rules.append('match ip protocol 0x%x' % proto)

    if priority is not None:
        rules.append('priority %d' % (10 - priority))

    rules.append('action output interface Ethernet%s' % egress)

    return ('\n\t'.join(rules) + '\nexit\n')

def addAristaRules(name, ingresses, egress, *args, **kwargs):
    rules = []
    for ing_name, ingress in ingresses.items():
        rule_name = name.split('_')
        rule_name.insert(1, ing_name)
        rule_name = '_'.join(rule_name)
        rules.append(addAristaRule(rule_name, ingress, egress, *args, **kwargs))
    return rules


def addRoute(name, client_port, server_port, client_mac, server_mac, booster_ports):
    '''
    Add routes from client --> server and server --> client using enabled boosters
    '''

    path = ['client']

    if ('FEC_ENCODE' in booster_ports) != ('FEC_DECODE' in booster_ports):
        raise Exception("If FEC_ENCODE is present, FEC_DECODE must be as well")
    if ('HC_COMPRESSOR' in booster_ports) != ('HC_DECOMPRESSOR' in booster_ports):
        raise Exception('If HC_COMPRESSOR is present, HC_DECOMPRESSOR must be as well')
    if ('FAULTY_LINK_1' in booster_ports) != ('FAULTY_LINK_2' in booster_ports):
        raise Exception('If FAULTY_LINK_1 is present, FAULTY_LINK_2 must be as well')

    ### PATH FROM CLIENT TO SERVER
    rules = []
    origins = {'client': client_port}

    if 'KV_CACHE' in booster_ports:
        log("Adding [ -> KV ] ")
        rules.append(addAristaRule(name + '_to_kv', client_port, booster_ports['KV_CACHE'], proto=0x0011,
                      mac=server_mac))
        path.append('kv cache')
        log("Adding [ <- Client ]")
        rules.append(addAristaRule(name + '_from_kv_to_client', booster_ports['KV_CACHE'], client_port, mac = client_mac))
        path.append('( <-- client )')
        origins['kv'] = booster_ports['KV_CACHE']

    if 'HC_COMPRESSOR' in booster_ports:
        log("Adding [ -> HC ] ")
        rules += addAristaRules(name + '_to_comp', origins, booster_ports['HC_COMPRESSOR'], proto=0x0006,
                       priority=1, mac=server_mac)
        path.append('compressor')
        origins['comp'] = booster_ports['HC_COMPRESSOR']

    if 'FEC_ENCODE' in booster_ports:
        log("Adding [ -> FEC ] ")
        rules += addAristaRules(name + '_to_fec', origins, booster_ports['FEC_ENCODE'], mac = server_mac,
                      priority=2)
        path.append('fec encoder')
        origins = {'enc': booster_ports['FEC_ENCODE']}

    if 'FAULTY_LINK_1' in booster_ports:
        log("Adding [ -> faulty ]")
        rules += addAristaRules(name + '_to_faulty', origins, booster_ports['FAULTY_LINK_1'],
                       mac=server_mac,
                       priority=3)
        path.append('faulty link')
        origins = {'faulty_2': booster_ports['FAULTY_LINK_2']}

    if 'FEC_DECODE' in booster_ports:
        log("Adding [ -> FEC Decode ]")
        rules += addAristaRules(name + '_to_decode', origins, booster_ports['FEC_DECODE'],
                       mac = server_mac)
        path.append('fec decode')
        origins = {'dec': booster_ports['FEC_DECODE']}

    if 'HC_DECOMPRESSOR' in booster_ports:
        log("Adding [ -> HD ]")
        rules += addAristaRules(name + '_to_decomp', origins, booster_ports['HC_DECOMPRESSOR'],
                       mac = server_mac)
        path.append('decompressor')
        origins['decomp'] = booster_ports['HC_DECOMPRESSOR']

    log("Adding [ => Server ]")
    rules += addAristaRules(name + '_to_server', origins, server_port, mac = server_mac,
                   priority=3)
    path.append('server')

    log("Set up route: " + ' --> '.join(path))

    #### PATH BACK FROM SERVER TO CLIENT

    path = ['server']
    origins = {'server': server_port}

    if 'FAULTY_LINK_2' in booster_ports:
        rules += addAristaRules(name + '_to_faulty_2', origins, booster_ports['FAULTY_LINK_2'],
                       mac=client_mac)
        path.append('faulty link')
        origins = {'faulty_1': booster_ports['FAULTY_LINK_1']}

    if 'KV_CACHE' in booster_ports:
        rules += addAristaRules(name + '_back_to_kv', origins, booster_ports['KV_CACHE'], proto=0x0011,
                       mac=client_mac, priority=1)
        path.append('kv cache')
        # Path back to client should already have been added above
        #origins['back_kv'] = booster_ports['KV_CACHE']

    rules += addAristaRules(name + '_to_client', origins, client_port, mac = client_mac, priority=2)
    path.append('server')

    log("Set up return route: " + ' --> '.join(path))

    return rules

if __name__ == '__main__':
    #print ("controller starting with configuration: ")
    #print ("\tdropRate: %s"%(args.dropRate))
    args = syntax_parser().parse_args()
    ports = ports_from_args(args)
    rules = generate_rules(ports, args.allow_ipv6)

    print('\n'.join(rules))
