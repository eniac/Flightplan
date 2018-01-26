"""
Functions to send a test stream of packets into the network. 
Uses click to send accurately.
Call this after you start the timing probes. 

Usage: 
# generate the click config file for your attacker host.
prepareSender(interface="h1-eth0")

# generate a workload PCAP file, dumpped to the default file.
generateRandomPackets(duration=10, rate=100)

# (code to start timing probes or whatever goes here)

# send the workload in the default file.
sendWorkload()

# code to analyze timing probes goes here.

"""
import sys, time, random, socket, os, struct
import threading
import binascii
import dpkt
import subprocess

default_pktTmpFile = 'sample.pcap'

def main():
	generateRandomIpPackets()

pktId = 1
def generateRandomIpPackets(duration = 1, rate = 100, dumpFile = default_pktTmpFile):
	"""
	Generates random TCP packet with a source and destination IP and ethernet address.
	"""
	global pktId
	# other parameters.
	# payloadlen = 10 # 54 for header, 10 to make 64
	payloadlen = 44
	activeFlowCt = 180
	flowInterArrival = .15
	# print ("generating %s TCP packets per second for %s seconds, with %s byte payloads and %s packets per flow"%(rate, duration, payloadlen, packetsPerFlow))
	eth_src = '\x22\x22\x22\x22\x22\x11'
	eth_dst = '\x22\x22\x22\x22\x22\x22'
	payload = "".join([str(i%10) for i in range(payloadlen)]) # for debugging.

	packetCt = rate * duration
	f = startPcapFile(dumpFile)
	current_time = 0.0

	activeFlows = [random.randint(0, 2147483647) for i in range(activeFlowCt)]
	lastFlowArrival = 0.0

	packetsInCurrentFlow = 0
	for i in range(packetCt):
		current_time += 1.0 / rate
		# select a flow.
		flowId = random.randint(0, activeFlowCt-1)
		pktId = activeFlows[flowId]
		# replace the flow if its time.
		if (current_time-lastFlowArrival)>flowInterArrival:
			activeFlows[flowId] = random.randint(0, 2147483647)
		# build a new packet. 
		packetsInCurrentFlow += 1
		ip_src = struct.pack("!I", ((pktId%128)+128)) # use the ip source as the replica you want to dump.
		ip_dst = struct.pack("!I", pktId)
		udp_sport = socket.htons(pktId)
		udp_dport = socket.htons(pktId)
		udpOut = dpkt.tcp.TCP()
		# if this is the last packet of the flow, add a fin flag.
		if (current_time-lastFlowArrival)>flowInterArrival:
			udpOut.flags = dpkt.tcp.TH_FIN
		udpOut.data = payload
		udpOut.sport = udp_sport
		udpOut.dport = udp_dport
		udpOut.ulen = len(udpOut)
		ipOut = dpkt.ip.IP(src=ip_src, dst=ip_dst)
		ipOut.p = 0x06 # protocol.
		ipOut.data = udpOut
		ipOut.v = 4
		# print len(ipOut)
		ipOut.len = len(ipOut)		
		ethOut = dpkt.ethernet.Ethernet(src=eth_src, dst = eth_dst, \
			type = dpkt.ethernet.ETH_TYPE_IP, data = ipOut)
		ethOutStr = ethOut	
		writePktToFile(ethOutStr, current_time, f)
		current_time += 1.0 / rate
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

