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

In the config.yml files, it may happen that:
1) The dataplane is not entirely up by the time the counters are captured.
2) The dataplane is killed before counter_1.out is updated.
3) dataplane is up and running, pktgen is sending packets before moongen binary can capture the packets.

Basically as noted from the above points, the inference is that the timings of each sequence of operations should be checked for
possible errors.  

#TODO: Add script file to be run and command format for running experiments.
