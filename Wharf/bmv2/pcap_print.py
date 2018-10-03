import sys
from scapy.all import *

if len(sys.argv) != 2:
    print("Removes ethernet padding from pcap of IP packets")
    print("Usage: %s <input.pcap> <cleaned.pcap>" % sys.argv[0])
    exit()

scapy_cap  = rdpcap(sys.argv[1])

out = []
for i, pkt in enumerate(scapy_cap):
    try:
        #pkt[IP].chksum = 0
        #pkt[IP].id = 0
        #pkt[UDP].chksum = 0
        pkt_notrail=Ether(str(pkt)[0:14 + pkt[IP].len])
        #out.append(packet_without_trailer)
        pkt_notrail.show2()
    except Exception as e:
        print("Error: %s"%e)
        pkt.show()


