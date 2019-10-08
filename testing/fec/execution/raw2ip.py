from scapy.all import *
import sys

pkts = rdpcap(str(sys.argv[1]) + "/moongen.pcap")

for pkt in pkts:
    pkt[Ether].type = 0x0800

wrpcap(str(sys.argv[1]) + "/new_moongen.pcap", pkts)


