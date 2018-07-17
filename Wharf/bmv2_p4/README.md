# P4 Behavioral Model - wharf and sample p4 files

Sample and fec booster bmv2 inputs can both be built with `make`

- Sources/Encoder.p4 : P4 file for the fec encoder
  - Run in mininet with `make run`
- Sources/Sample.p4 : an example of extern usage
  - Creates copy of incoming packets with specified bytes of payload modified
  - Run in mininet with `make run-sample`
