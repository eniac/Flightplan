"""
Generate pcaps for testing compressor / decompressor functionality.
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess
import shutil

def main(pcapF1):
	cleanPcaps(pcapF1)

def cleanPcaps(pcapF1):
	pcap1 = dpkt.pcap.Reader(open(pcapF1))
	pcap2 = dpkt.pcap.Writer(open("clean.pcap", "w+"))
	pcap1Bufs = []
	for ts, buf in pcap1:
		eth = dpkt.ethernet.Ethernet(buf)
		ip = eth.data
		if ip.p != dpkt.ip.IP_PROTO_UDP:
			continue
		udp = ip.data
		ip.sum = 0
		ip.id = 0
		udp.sum = 10
		pcap2.writepkt(eth,ts=ts)
	shutil.move("clean.pcap", pcapF1)
if __name__ == '__main__':
	main(sys.argv[1])
