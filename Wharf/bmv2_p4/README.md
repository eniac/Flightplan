# P4 Behavioral Model - wharf and sample p4 files

Sample and fec booster bmv2 inputs can both be built with `make`

- Sources/Encoder.p4 : Fec encoder. Output is suitable for passing into decoder.
  - Run in mininet with `make run-Encoder`
- Sources/Decoder.p4 : Fec decoder. Can decode the output of the Encoder.
  - Run in mininet with `make run-Decoder`
- Sources/Dropper.p4 : Inspects the ethernet and fec headers. If it is a fec packet, the dropper
  will drop packet (k - 1) of each block.
  - Run in mininet with `make run-Dropper`
- Sources/Sample.p4 : an example of extern usage
  - Creates copy of incoming packets with specified bytes of payload modified
  - Run in mininet with `make run-Sample`
