"""
Generate pcaps for testing compressor / decompressor functionality.
"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess

default_pktTmpFile = 'emptyPackets.pcap'

def main():
	generateUfwFlow()


def generateUfwFlow(interArrival = .1, count = 1000, dumpFile = "pcaps/ufw_dcomp.pcap"):
	udp_sport = 55000
	udp_dport = 11230
	ip_src = '\x0a\x00\x00\x01'
	ip_dst = '\x0a\x00\x00\x69'
	eth_src = '\x24\x8a\x07\x8f\xeb\x00'
	eth_dst = '\xe4\x43\x4b\x1e\x40\x44'
	#ip_src = struct.pack("!I", pktId)
	#ip_dst = struct.pack("!I", pktId)
	#udp_sport = socket.htons(sport)
	#udp_dport = socket.htons(dport)

#'\x48\x65\x6c\x6c\x6f\x20\x57\x6f\x72\x6c\x64\00'
	payload = '\x48\x65\x6c\x6c\x6f\x20\x57\x6f\x72\x6c\x64\00' * 80
	f = startPcapFile(dumpFile)
	current_time = 0
	for i in range(count):	
		# UDP header
		udpOut = dpkt.udp.UDP()
		udpOut.sport = udp_sport
		udpOut.dport = udp_dport
		udpOut.data = payload
		udpOut.ulen = len(udpOut)
		# IP header
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x11 # protocol.
		ipOut.v = 4
		ipOut.len = len(ipOut)		
		ipOut.data = udpOut
		# Eth header
		ethOut = dpkt.ethernet.Ethernet(src=eth_src, dst = eth_dst, \
			type = dpkt.ethernet.ETH_TYPE_IP, data = ipOut)
		ethOutStr = ethOut	
		# dump
		writePktToFile(ethOutStr, current_time, f)
		current_time += interArrival
	f.close()

# pcap helpers.
#Global header for pcap 2.4
pcap_global_header="d4c3b2a1".decode("hex") + struct.pack("H",2) + struct.pack("H",4) + struct.pack("I", 0) + struct.pack("I", 0) + struct.pack("I", 1600) + struct.pack("I", 1)
pcap_packet_header = "AA779F4790A20400".decode("hex") # then put the frame size twice in little endian ints.

def appendByteStringToFile(bytestring, f):
	f.write(bytestring)

def startPcapFile(filename):
	f = open(filename, "wb")
	f.write(pcap_global_header)
	return f

def writePktToFile(pkt, ts, f):
	"""
	Writes an ethernet packet to a file. Prepends the pcap packet header.
	"""
	pcap_len = len(pkt)
	seconds = int(ts)
	microseconds = int((ts - int(ts)) * 1000000)
	bytes = struct.pack("<i",seconds) + struct.pack("<i",microseconds) + struct.pack("<i", pcap_len) + struct.pack("<i", pcap_len) + str(pkt)
	# bytes = pcap_packet_header + struct.pack("<i", pcap_len) + struct.pack("<i", pcap_len) + pkt
	appendByteStringToFile(bytes, f)


if __name__ == '__main__':
	main()
