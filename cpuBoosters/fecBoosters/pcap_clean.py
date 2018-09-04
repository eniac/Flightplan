import sys
from scapy.all import *

if len(sys.argv) != 3:
    print("Removes ethernet padding from pcap of IP packets")
    print("Usage: %s <input.pcap> <cleaned.pcap>" % sys.argv[0])
    exit()

scapy_cap  = rdpcap(sys.argv[1])

out = []
for pkt in scapy_cap:
    try:
        pkt=Ether(str(pkt)[0:14 + pkt[IP].len])
    except:
        pass
    out.append(pkt)

wrpcap(sys.argv[2], out)
