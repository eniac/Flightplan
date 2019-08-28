FPGA FEC Encoder:

System dataplane:

1 ----> 121 ----> 2
      |    |
      |    |
      |    |
      v    v
      5    5


Input pcap: fec_new_test_in.pcap 

Make sure the fpga is reprogrammed on every single experiment.

Expected behaviour: There should be a 5:6 ratio for input:output packet counts.

FPGA FEC Decoder:

System dataplane:

1 ----> 122 ----> 2
      |    |
      |    |
      |    |
      v    v
      5    5


Input pcap: fpga_fec_test_enc_60.pcap 

Make sure the fpga is reprogrammed on every single experiment.

Expected behaviour: There should be a 6:5 ratio for input:output packet counts.

CPU FEC Encoder:

System dataplane:

1 ----> 112 
      |    |
      |    |
      |    |
      v    v
      5    5


Input pcap: fec_new_test_in.pcap (Class 1 for CPU use case, as defined in tag_all.txt)

Expected behaviour: There should be a 5:6 ratio for input:output packet counts.

CPU FEC Decoder:

System dataplane:

1 ----> 112 
      |    |
      |    |
      |    |
      v    v
      5    5


Input pcap: cpu_fec_test_enc.pcap (Class 1 for CPU use case, as defined in tag_all.txt)

Expected behaviour: There should be a 6:5 ratio for input:output packet counts.

General: 

In the config.yml files, it may happen that:
1) The dataplane is not entirely up by the time the counters are captured.
2) The dataplane is killed before counter_1.out is updated.
3) dataplane is up and running, pktgen is sending packets before moongen binary can capture the packets.

Basically as noted from the above points, the inference is that the timings of each sequence of operations should be checked for
possible errors.  


The script should be run as:
e.g.
./run_fpga_fec_encoder.sh test_output fpga_fec_encoder <name of pcap in pcaps directory> <rate at which experiment is to be run>

100.00 rate is equivalent to 10Gbps input rate. 

For multiple runs of the same experiment use the run_multiple script as follows:
e.g.

./run_multiple.sh run_fpga_fec_encoder.sh fpga_fec_encoder <name of pcap file residing in pcap directory> 


