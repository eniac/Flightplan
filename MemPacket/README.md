# Memcached Hardware Testing

## Generate packets
Use scripts generate\_packets.sh to generate testing packets and standard response from actual memcached service. The length of KEY and DATA could be modified in config file .memaslap.cnf

## Testing
### C testing
Use C\_test.sh for C simulation. Before the first test, he script ../FPGA/MemcachedP4/Encoder/XilinxSwitch/XilinxSwitch.TB/compile.bash must be executed. <br/>
The script requries 2 arguments: Input pcap file and Standard pcap file for comparison.<br/>
If no arguments assigned, the script will execute generate\_packets.sh first. The input would then be TX.pcap. The reference pcap file would be RX.pcap
### Hardware testing
Use Hardware\_test.sh for hardware testing. The scripts require 3 arguments: NIC interface name, Pcap file for TX and Pcap file for saving captured pcap.
### Payload Extraction
Payload.py could be used to extract Memcached payload and sorted by the Identification field of Memcached header. For example: python3 payload.py test.pcap. It will extract the payload of each packet in the test.pcap and save it into test.pcap.txt.
