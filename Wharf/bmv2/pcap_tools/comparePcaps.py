"""
Test all packets in `src` are present in `dst`
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess
import scapy.all as scapy

# pcapF1 = "oneFlow.pcap.compressor.in.pcap"
# pcapF2 = "oneFlow.pcap.compressor.out.pcap"

def comparePcaps(src, dst):
    pcap1 = scapy.rdpcap(open(src, 'rb'))
    pcap2 = scapy.rdpcap(open(dst, 'rb'))

    pkts2 = []
    for pkt in pcap2:
        if scapy.IP in pkt:
            pkt[scapy.IP].chksum = 0
        pkts2.append(str(pkt))

    fail = False

    for input in pcap1:
        if scapy.IP in input:
            input[scapy.IP].chksum = 0
        if str(input) in pkts2:
            del pkts2[pkts2.index(str(input))]
        else:
            print("FAIL: Packet %s is not in dst" % (input.show2(dump=True)))
            fail = True

    if not fail:
        print("Success! All packets from src in dst")


if __name__ == '__main__':
	comparePcaps(sys.argv[1], sys.argv[2])
