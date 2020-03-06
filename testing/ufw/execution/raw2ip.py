from scapy.all import *
import sys

path = sys.argv[1]

pkts = rdpcap(path + "/moongen.pcap")

for pkt in pkts:
    pkt[Ether].type = 0x0800

wrpcap(path + "/new_moongen.pcap", pkts)


