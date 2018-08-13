import os
import sys
from sys import argv
os.sys.path.append('/usr/local/lib/python2.7/dist-packages')

script, pcap_file = argv
print ('Read packets from ' + pcap_file)
txt_file = pcap_file + '.txt'
print ('Write payload in to ' + txt_file)
from scapy.all import *
pcap = rdpcap(pcap_file)
data = [pkt[Raw].load for pkt in pcap]
data = sorted(data)
with open(txt_file, 'w') as f:
	for pkt_num, payload in enumerate(data):
		print ("Packet",pkt_num, file = f)		
		print (payload, file = f)
