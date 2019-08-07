For FPGA:

Test pcaps are located in testing/memcached/execution/pcaps. 

Make sure that test pcap has around 10000 packets, as there were issues with huge page availability on the pktgen generator for larger packet numbers.

Warmup packets are all SET packets of size 545 bytes

Test packets are of GET:SET ratio of 9:1. The GET packets are 22 bytes and SET packets are 545 bytes.

The test packet limit sent from pktgen is 10000.

On a cache hit, the SET packets should become of size udp length 549 bytes, hence o/p throughput > i/p throughput wrt inline cache booster. To obtain o/p packets redirect packets to another tclust machine and write incoming packets on that machine to a pcap file. The o/p file is for reference.

Make sure to program fpga device on every test run.

The inline cache booster began dropping packets at 35% line rate.

To run the analysis, copy the raw2ip.py script into the moongen folder, which houses the moongen.pcap file. The script outputs a new pcap called new_moongen.pcap. This file is used in the analysis. It converts the eth.type from 1234 to 0800 for easier analysis. 
