from scapy.all import *
import sys

pkts = rdpcap(sys.argv[1], 10)

pcap_size = 0
for pkt in pkts:
    pcap_size += len(pkt)


print("size of 1 packet: " + str(len(pkts[0]))) 
print("size of pcap: " + str(pcap_size)) 



