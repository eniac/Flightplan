import sys
from scapy.all import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input', type=str)
parser.add_argument('cleaned', type=str)
parser.add_argument('--ipv4-only', action='store_true', required=False, default=False)
parser.add_argument('--rm-chksum', action='store_true', required=False, default=False)
args = parser.parse_args()

scapy_cap  = rdpcap(args.input)

print("Pcap cleaning {} to {}".format(args.input, args.cleaned))
out = []
for pkt in scapy_cap:
    try:
        if (IP not in pkt or pkt[IP].version != 4) and args.ipv4_only:
            continue
        if IP not in pkt:
            out.append(pkt)
        else:
            if args.rm_chksum:
                pkt[IP].chksum = 0
                pkt[IP].id = 0
                if UDP in pkt:
                    pkt[UDP].chksum = 0
            packet_without_trailer=Ether(str(pkt)[0:14 + pkt[IP].len])
            out.append(packet_without_trailer)
    except Exception as e:
        print("Error: {}".format(e))
        if args.ipv4_only:
            print("Skipping...")
        else:
            out.append(pkt)

wrpcap(sys.argv[2], out)
