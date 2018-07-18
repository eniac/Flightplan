# P4 Behavioral Model - wharf and sample p4 files

Sample and fec booster bmv2 inputs can both be built with `make`

- Sources/FEC.p4 : General code for FEC-enabled p4 switches. Handles parsing and calling of FEC externs
- Sources/FecBM.p4 : Wrappers to FEC.p4 code specifically for being called the v1model of bmv2
- Sources/EncoderBM.p4 : Fec encoder for bmv2. Output is suitable for passing into decoder.
  - Run in mininet with `make run-EncoderBM`
- Sources/DecoderBM.p4 : Fec decoder for bmv2. Can decode the output of the Encoder.
  - Run in mininet with `make run-DecoderBM`
- Sources/Dropper.p4 : Inspects the ethernet and fec headers. If it is a fec packet, the dropper
  will drop packet (k - 1) of each block.
  - Run in mininet with `make run-Dropper`
- Sources/Sample.p4 : an example of extern usage
  - Creates copy of incoming packets with specified bytes of payload modified
  - Run in mininet with `make run-Sample`

Executing `make run` will start up a network:
```
h1 <--> Encoder (s0) <--> Dropper (s1) <--> Decoder (s2) <--> h2
```

Execution of `bash e2etest.sh <pcap_file.pcap>` will start the network,
replay the pcap file on h1, and then check that identical output
is received by h2.
