import sys
from scapy.all import *

if len(sys.argv) != 4:
    print("Usage: %s <input.pcap> <out.pcap> <dir=[0,1]>" % sys.argv[0])
    exit()

scapy_cap  = rdpcap(sys.argv[1])

out = []
print("Swapping out IP addresses for mininet from {} to {} ".format(sys.argv[1], sys.argv[2]))

src_mac = '11:11:11:11:11:11'
dst_mac = '22:22:22:22:22:22'
src_ip = '10.0.0.11'
dst_ip = '10.0.0.12'

if sys.argv[3] == '1':
    tmp = dst_mac
    dst_mac = src_mac
    src_mac = tmp
    tmp = src_ip
    src_ip = dst_ip
    dst_ip = tmp

for pkt in scapy_cap:
    try:
        pkt[Ether].src = src_mac
        pkt[Ether].dst = dst_mac
        pkt[IP].src = src_ip
        pkt[IP].dst = dst_ip
        del pkt[IP].chksum
        if UDP in pkt:
            del pkt[UDP].chksum
        out.append(pkt)
        #out.append(packet_without_trailer[UDP].payload)
        #out.append(packet_without_trailer)
    except Exception as e:
        print("Error: %s"%e)
        out.append(pkt)



wrpcap(sys.argv[2], out)
