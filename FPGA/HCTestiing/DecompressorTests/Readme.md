# Unit Tests
This test is FPGA and software co-simulation. 
## Prerequisite
To run the test, the bitstream must be launched on the FPGA and the CompressorP4 must be built.
The Interfaces for sending and recving packets must be specified in the `Hadrware_test.sh`.
## Run Test
Simply run `sudo ./Hardware_test.sh $TEST_NAME`.
The Csimulation trace is `CSimulation.pcap`. The send and receive packets are `send.pcap` and `recv.pcap`
## Other Utility
The `cleanPcap.py input_pcap` is used to remove the packets that are neither compressed nor tcp packets. 
The `comparePcaps.py 1.pcap 2.pcap` could be used to compare the difference between two pcap traces.
## Add Test cases
Add a separate folder in the `UnitTest` that contains two pcap file: `Send.pcap` and `ref.pcap`.
