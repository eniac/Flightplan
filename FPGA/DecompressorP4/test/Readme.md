# Unit Tests
This test is FPGA and software co-simulation. 
## Run Test
Run `./C_Test.sh $TEST_NAME` for C simulation. 
Add `-RTL` for RTL simulation
The Csimulation trace is `CSimulation.pcap`. The send and receive packets are `send.pcap` and `recv.pcap`
## Other Utility
The `cleanPcap.py input_pcap` is used to remove the packets that are neither compressed nor tcp packets. 
The `comparePcaps.py 1.pcap 2.pcap` could be used to compare the difference between two pcap traces.
## Add Test cases
Add a separate folder in the `UniteTest` that contains two pcap file: `Send.pcap` and `ref.pcap`.
