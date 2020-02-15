FPGA HC compressor:

System dataplane:

1 ----> 121 ----> 2
      |    |
      |    |
      |    |
      v    v
      5    5


Input pcap for compressor: P4Boosters/testing/HdrCompression/execution/pcaps/oneFlow1000.pcap 

Input pcap for decompressor: P4Boosters/testing/HdrCompression/execution/pcaps/oneFlow1000.pcap.compress.pcap

Make sure the fpga is reprogrammed on every single experiment.

Expected behaviour: header should compress by 24 bytes.

Input/Ouput ratio: 1:1  

In the config.yml files, it may happen that:
1) The dataplane is not entirely up by the time the counters are captured.
2) The dataplane is killed before counter_1.out is updated.
3) dataplane is up and running, pktgen is sending packets before moongen binary can capture the packets.

Basically as noted from the above points, the inference is that the timings of each sequence of operations should be checked for
possible errors.  

The script should be run as:
e.g.
./run_cpu_compressor.sh test_output cpu_compressor <name of pcap in pcaps directory> <rate at which experiment is to be run>

100.00 rate is equivalent to 10Gbps input rate. 

For multiple runs of the same experiment use the run_multiple script as follows:
e.g.

./run_multiple.sh run_cpu_compressor.sh cpu_compressor <name of pcap file residing in pcap directory> 


ANALYSIS FILE:
	
  P4Boosters/testing/HdrCompression/analysis/tofinoHdrCompression.ipynb 

