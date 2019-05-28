"""
Generate pcaps for testing compressor / decompressor functionality.
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess

def main(pcapF1):
	splitpkts(pcapF1)

def splitpkts(pcapF1):
	pcap1 = dpkt.pcap.Reader(open(pcapF1))
	pcap2 = dpkt.pcap.Writer(open("@server.pcap", "w+"))
	pcap3 = dpkt.pcap.Writer(open("@client.pcap", "w+"))
	pcap1Bufs = []
	pcap2Bufs = []
	for ts, buf in pcap1:
		eth = dpkt.ethernet.Ethernet(buf)
		ip = eth.data
		udp = ip.data
		if udp.sport == 11211:
			pcap2Bufs.append(buf)
			continue
		if udp.dport == 11211:
			pcap1Bufs.append(buf)
			continue
	for i in range(len(pcap1Bufs)):
		pcap2.writepkt(pcap1Bufs[i])
	for i in range(len(pcap2Bufs)):
		pcap3.writepkt(pcap2Bufs[i])

if __name__ == '__main__':
	main(sys.argv[1])
