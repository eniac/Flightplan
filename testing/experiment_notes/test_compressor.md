FPGA HC compressor:

System dataplane:

1 ----> 121 ----> 2
      |    |
      |    |
      |    |
      v    v
      5    5


Input pcap: oneFlow.pcap 

Make sure the fpga is reprogrammed on every single experiment.

Expected behaviour: header should compress by 24 bytes.

Input/Ouput ratio: 1:1  
