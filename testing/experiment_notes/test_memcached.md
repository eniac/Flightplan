For FPGA:

Test pcaps are located in P4Boosters/testing/memcached/execution/pcaps.
The 2 files used are:
	mcd_warmup.pcap as warmup packets
	mcd_test_new.pcap as test packets 

Make sure that test pcap has around 10000 packets, as there were issues with huge page availability on the pktgen generator for larger packet numbers.

Warmup packets are all SET packets of size 545 bytes

Test packets are of GET:SET ratio of 9:1. The GET packets are 22 bytes of UDP data and SET packets are 545 bytes of UDP data.

The test packet limit sent from pktgen is 10000.

On a cache hit, the GET packets of udp data length 22 bytes should become size udp data length 549 bytes, hence o/p throughput > i/p throughput wrt inline cache booster. To obtain o/p packets redirect packets to another tclust machine and write incoming packets on that machine to a pcap file. The o/p file is for reference.

Make sure to program fpga device on every test run.

The inline cache booster began dropping packets at 35% line rate.

To run the analysis, copy the raw2ip.py script into the moongen folder, which houses the moongen.pcap file. The script outputs a new pcap called new_moongen.pcap. This file is used in the analysis. It converts the eth.type from 1234 to 0800 for easier analysis. 

The script should be run as:
e.g.
./run_fpga_inline_cache.sh test_output fpga_inline <name of pcap in pcaps directory> <rate at which experiment is to be run>

100.00 rate is equivalent to 10Gbps input rate. 

For multiple runs of the same experiment use the run_multiple script as follows:
e.g.

./run_multiple.sh run_fpga_inline_cache.sh fpga_inline <name of pcap file residing in pcap directory> 

ANALYSIS FILE:

	P4Boosters/testing/memcached/analysis/inlinecache.ipynb
