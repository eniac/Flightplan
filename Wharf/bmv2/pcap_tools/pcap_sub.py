import sys
from argparse import ArgumentParser
from scapy.all import *

parser = ArgumentParser("Set IP and MAC on pcap files")
parser.add_argument("input", type=str, help="input.pcap")
parser.add_argument("output", type=str, help="output.pcap")
parser.add_argument("dir", type=int, default=0, nargs="?", help="If 0, packets originate at src. Otherwise, at dst")
parser.add_argument("--sip", type=str, default="10.0.0.10", help="Source IP")
parser.add_argument("--smac", type=str, default='22:11:11:11:11:21', help='Source MAC')
parser.add_argument('--dip', type=str, default='10.0.0.12', help='Dest IP')
parser.add_argument('--dmac', type=str, default='22:11:11:11:11:23', help='Dest MAC')

args = parser.parse_args()

scapy_cap  = rdpcap(args.input)

out = []
print("Swapping out IP addresses for mininet from {} to {} ".format(args.input, args.output))

src_mac = args.smac
dst_mac = args.dmac
src_ip = args.sip
dst_ip = args.dip

if args.dir == 1:
    tmp = dst_mac
    dst_mac = src_mac
    src_mac = tmp
    tmp = src_ip
    src_ip = dst_ip
    dst_ip = tmp

for pkt in scapy_cap:
    try:
        pkt[Ether].src = src_mac
        pkt[Ether].dst = dst_mac
        pkt[IP].src = src_ip
        pkt[IP].dst = dst_ip
        del pkt[IP].chksum
        if UDP in pkt:
            del pkt[UDP].chksum
        out.append(pkt)
        #out.append(packet_without_trailer[UDP].payload)
        #out.append(packet_without_trailer)
    except Exception as e:
        print("Error: %s"%e)
        out.append(pkt)



wrpcap(args.output, out)
