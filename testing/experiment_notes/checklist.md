1) I/P throughput cannot exceed line rate.

2) HC compressor should reduce output throughput

3) FEC decoder should reduce output throughput

4) FEC encoder should increase output throughput

5) HC decompressor should increase output throughput

6) FPGA booster latency should be lower than CPU booster latency 

7) As line rate increases, the packet throughput should increase.

8) The ratio of input:output packets for fec encoder should be 5:6

9) The ratio of input:output packets for fec decoder should be 6:5

10) The ratio of input:output packets for compressor and decompressor should be 1:1

11) The ratio of input:output packets for kv inline cache should be 1:1
