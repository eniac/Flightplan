"""
Generate pcaps for testing compressor / decompressor functionality.
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess

default_pktTmpFile = 'emptyPackets.pcap'
pcapF1 = "oneFlow.pcap.compressor.in.pcap"
pcapF2 = "oneFlow.pcap.compressor.out.pcap"

def main():
	comparePcaps(pcapF1, pcapF2)

def comparePcaps(pcapF1, pcapF2):
	pcap1 = dpkt.pcap.Reader(open(pcapF1))
	pcap1Bufs = []
	for ts, buf in pcap1:
		pcap1Bufs.append(buf)
	pcap2 = dpkt.pcap.Reader(open(pcapF2))
	pcap2Bufs = []
	for ts, buf in pcap2:
		pcap2Bufs.append(buf)
	
	print("comparing %s pcaps"%len(pcap1Bufs))
	for i in range(len(pcap1Bufs)):
		if pcap1Bufs[i] != pcap2Bufs[i]:
			print("packets %s don't match")
	print("done.")


if __name__ == '__main__':
	main()
