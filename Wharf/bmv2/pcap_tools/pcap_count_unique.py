from __future__ import print_function
from scapy.all import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input', type=str)
parser.add_argument('--include-tcp', action='store_true')
args = parser.parse_args()

in_cap = rdpcap(args.input)

tcps = [pkt[TCP] for pkt in in_cap if TCP in pkt and Raw in pkt]

pkt_loads = []
pkt_strs = []
for pkt in tcps:
    pkt.chksum = 0
    pkt_strs.append(str(pkt))
    pkt_loads.append(pkt.load)

if args.include_tcp:
    print(len(set(pkt_strs)))
else:
    print(len(set(pkt_loads)))
#print(len(set(pkt_strs)))
