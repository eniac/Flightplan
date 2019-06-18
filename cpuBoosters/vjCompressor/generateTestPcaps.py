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
	generateOneFlow()
	generateCollidingFlows()
	generateTwoFlows()


def generateOneFlow(interArrival = .1, count = 10, dumpFile = "pcaps/oneFlow.pcap"):
	pktId = 1
	eth_src = '\x24\x2a\x07\x8f\xeb\x00'
	eth_dst = '\x24\x8a\x07\x5b\x15\x34'
	ip_src = struct.pack("!I", pktId)
	ip_dst = struct.pack("!I", pktId)
	tcp_sport = socket.htons(pktId)
	tcp_dport = socket.htons(pktId)

	payload = "\x00"*46
	f = startPcapFile(dumpFile)
	current_time = 0
	for i in range(count):	
		# TCP header
		tcpOut = dpkt.tcp.TCP()
		tcpOut.sport = tcp_sport
		tcpOut.dport = tcp_dport
		tcpOut.ulen = len(tcpOut)
		tcpOut.data = payload
		# IP header
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x06 # protocol.
		ipOut.v = 4
		ipOut.len = len(ipOut)		
		ipOut.data = tcpOut
		# Eth header
		ethOut = dpkt.ethernet.Ethernet(src=eth_src, dst = eth_dst, \
			type = dpkt.ethernet.ETH_TYPE_IP, data = ipOut)
		ethOutStr = ethOut	
		# dump
		writePktToFile(ethOutStr, current_time, f)
		current_time += interArrival
	f.close()

def generateTwoFlows(interArrival = .1, count = 10, dumpFile = "pcaps/twoFlows.pcap"):

	pktId = 5
	eth_src = '\x22\x22\x22\x22\x22\x11'
	eth_dst = '\x22\x22\x22\x22\x22\x22'
	ip_src = struct.pack("!I", pktId)
	ip_dst = struct.pack("!I", pktId)
	tcp_sport = socket.htons(pktId)
	tcp_dport = socket.htons(pktId)

	payload = "\x00"*50
	f = startPcapFile(dumpFile)
	current_time = 0
	# generate flow 1.
	for i in range(count/2):	
		# TCP header
		tcpOut = dpkt.tcp.TCP()
		tcpOut.sport = tcp_sport
		tcpOut.dport = tcp_dport
		tcpOut.ulen = len(tcpOut)
		tcpOut.data = payload
		# IP header
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x06 # protocol.
		ipOut.v = 4
		ipOut.len = len(ipOut)		
		ipOut.data = tcpOut
		# Eth header
		ethOut = dpkt.ethernet.Ethernet(src=eth_src, dst = eth_dst, \
			type = dpkt.ethernet.ETH_TYPE_IP, data = ipOut)
		ethOutStr = ethOut	
		# dump
		writePktToFile(ethOutStr, current_time, f)
		current_time += interArrival
	# generate flow 2 with src incremented in a way that avoids collision with flow 1.
	ip_src = struct.pack("!I", pktId+1)
	for i in range(count/2):	
		# TCP header
		tcpOut = dpkt.tcp.TCP()
		tcpOut.sport = tcp_sport
		tcpOut.dport = tcp_dport
		tcpOut.ulen = len(tcpOut)
		tcpOut.data = payload
		# IP header
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x06 # protocol.
		ipOut.v = 4
		ipOut.len = len(ipOut)		
		ipOut.data = tcpOut
		# Eth header
		ethOut = dpkt.ethernet.Ethernet(src=eth_src, dst = eth_dst, \
			type = dpkt.ethernet.ETH_TYPE_IP, data = ipOut)
		ethOutStr = ethOut	
		# dump
		writePktToFile(ethOutStr, current_time, f)
		current_time += interArrival
	f.close()


def generateCollidingFlows(interArrival = .1, count = 10, dumpFile = "pcaps/collidingFlows.pcap"):

	pktId = 5
	eth_src = '\x22\x22\x22\x22\x22\x11'
	eth_dst = '\x22\x22\x22\x22\x22\x22'
	ip_src = struct.pack("!I", pktId)
	ip_dst = struct.pack("!I", pktId)
	tcp_sport = socket.htons(pktId)
	tcp_dport = socket.htons(pktId)

	payload = "\x00"*50
	f = startPcapFile(dumpFile)
	current_time = 0
	# generate flow 1.
	for i in range(count/2):	
		# TCP header
		tcpOut = dpkt.tcp.TCP()
		tcpOut.sport = tcp_sport
		tcpOut.dport = tcp_dport
		tcpOut.ulen = len(tcpOut)
		tcpOut.data = payload
		# IP header
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x06 # protocol.
		ipOut.v = 4
		ipOut.len = len(ipOut)		
		ipOut.data = tcpOut
		# Eth header
		ethOut = dpkt.ethernet.Ethernet(src=eth_src, dst = eth_dst, \
			type = dpkt.ethernet.ETH_TYPE_IP, data = ipOut)
		ethOutStr = ethOut	
		# dump
		writePktToFile(ethOutStr, current_time, f)
		current_time += interArrival
	# generate flow 2 with 1 field incremented by 1 to cause a collision.
	ip_dst = struct.pack("!I", pktId+1)
	for i in range(count/2):	
		# TCP header
		tcpOut = dpkt.tcp.TCP()
		tcpOut.sport = tcp_sport
		tcpOut.dport = tcp_dport
		tcpOut.ulen = len(tcpOut)
		tcpOut.data = payload
		# IP header
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x06 # protocol.
		ipOut.v = 4
		ipOut.len = len(ipOut)		
		ipOut.data = tcpOut
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
