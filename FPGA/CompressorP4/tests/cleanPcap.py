"""
Generate pcaps for testing compressor / decompressor functionality.
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess

def main(pcapF1):
	cleanPcaps(pcapF1)

def cleanPcaps(pcapF1):
	pcap1 = dpkt.pcap.Reader(open(pcapF1))
	pcap2 = dpkt.pcap.Writer(open("clean.pcap", "w+"))
	pcap1Bufs = []
	for ts, buf in pcap1:
		eth = dpkt.ethernet.Ethernet(buf)
		if eth.type == 0x1234:
			pcap1Bufs.append(buf)
			continue
		if eth.type != dpkt.ethernet.ETH_TYPE_IP:
			continue
		ip = eth.data
		if ip.p != dpkt.ip.IP_PROTO_TCP:
			continue
		pcap1Bufs.append(buf)
	for i in range(len(pcap1Bufs)):
		pcap2.writepkt(pcap1Bufs[i])

if __name__ == '__main__':
	main(sys.argv[1])
