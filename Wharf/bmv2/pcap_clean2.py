import sys
from scapy.all import *

if len(sys.argv) != 3:
    print("Removes ethernet padding from pcap of IP packets")
    print("Usage: %s <input.pcap> <cleaned.pcap>" % sys.argv[0])
    exit()

scapy_cap  = rdpcap(sys.argv[1])

out = []
print "$%^$%^$%#^$%#^", sys.argv[1]
for pkt in scapy_cap:
    try:
        pkt[IP].chksum = 0
        pkt[IP].id = 0
        pkt[UDP].chksum = 0
        packet_without_trailer=Ether(str(pkt)[0:14 + pkt[IP].len])
        out.append(packet_without_trailer)
        #out.append(packet_without_trailer[UDP].payload)
        #out.append(packet_without_trailer)
    except Exception as e:
        print("Error: %s"%e)
        out.append(pkt)



wrpcap(sys.argv[2], out)
