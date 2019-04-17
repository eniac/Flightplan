import sys
from scapy.all import *

if len(sys.argv) != 3:
    print("Removes ethernet padding from pcap of IP packets")
    print("Usage: %s <input.pcap> <output.txt>" % sys.argv[0])
    exit()

scapy_cap  = rdpcap(sys.argv[1])
print("Printing {} to {}".format(sys.argv[1], sys.argv[2]))

out = open(sys.argv[2],'w')
for i, pkt in enumerate(scapy_cap):
    try:
        #pkt[IP].chksum = 0
        #pkt[IP].id = 0
        #pkt[UDP].chksum = 0
        pkt_notrail=Ether(str(pkt)[0:14 + pkt[IP].len])
        #out.append(packet_without_trailer)
        out.write(pkt_notrail.show(dump=True))
    except Exception as e:
        out.write(pkt.show(dump=True))

out.close()


