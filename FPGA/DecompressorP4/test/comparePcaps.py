"""
Generate pcaps for testing compressor / decompressor functionality.
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess

def main(pcapF1, pcapF2):
	comparePcaps(pcapF1, pcapF2)

def comparePcaps(pcapF1, pcapF2):
	pcap1 = dpkt.pcap.Reader(open(pcapF1))
	pcap1Bufs = []
	for ts, buf in pcap1:
		eth = dpkt.ethernet.Ethernet(buf)
		if eth.type != dpkt.ethernet.ETH_TYPE_IP:
			continue
		ip = eth.data
		if ip.p != dpkt.ip.IP_PROTO_TCP:
			continue
		pcap1Bufs.append(buf)
	pcap2 = dpkt.pcap.Reader(open(pcapF2))
	pcap2Bufs = []
	for ts, buf in pcap2:
		eth = dpkt.ethernet.Ethernet(buf)
		if eth.type != dpkt.ethernet.ETH_TYPE_IP:
			continue
		ip = eth.data
		if ip.p != dpkt.ip.IP_PROTO_TCP:
			continue
		pcap2Bufs.append(buf)
	
	success = True
	for i in range(len(pcap1Bufs)):
		if pcap1Bufs[i] != pcap2Bufs[i]:
			print("\tpacket " + str(i) +" doesn't match")
			success = False
	if (success):
		print ("PASS: all packets in %s and %s are identical"%(pcapF1, pcapF2))
	else:
		print ("FAIL: packets in %s and %s are NOT identical"%(pcapF1, pcapF2))


if __name__ == '__main__':
	main(sys.argv[1], sys.argv[2])
