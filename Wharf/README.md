# P4 Behavioral Model - wharf and sample p4 files

## Dependencies

Building the p4 files for bmv2 requires global installation of p4c (https://github.com/p4lang/p4c)

## Building for SDNet

SDNet build is not yet added to the makefile.

Building for SDNet requires adding `-DTARGET_SDNET` to to `p4c` command to enable the
appropriate target-specific code.

## Building for bmv2

Sample and fec booster bmv2 inputs can both be built with `make bmv2`

- Sources/Complete.p4 : Program to be run on all switches
  - Performs Memcached'ing, fec-encoding, and/or fec-decoding depending on traffic type
  - Run one in mininet with `make run-Complete`
- Sources/targets.h : Target-specific definitions used by fec encoder and decoder
- Sources/FEC.p4 : Calls to encode, decode, or retrieve parameters based on fec encoding
- Sources/Forwarding.p4 : Determines the egress port out of which a packet should be sent
- Sources/Parsing.p4 : Parsing and deparsing of packets
- Sources/LLDP.p4 : Activation of FEC on ports through LLDP
- Sources/Encoder.p4 : Definition of `main` switch target for encoder
  - Run in mininet with `make run-Encoder`
- Sources/Decoder.p4 : Definition of `main` switch target for decoder
  - Run in mininet with `make run-Decoder`
- Sources/Dropper.p4 : A `main` target that will drop a configurable number of packets
  - Run in mininet with `make run-Dropper`
- Sources/Sample.p4 : Sample use of a simple exetern that creates a modified copy of a packet
  - Run in mininet with `make run-Sample`

Executing `make run` will start up a network:
```
h1 <--> Encoder (s0) <--> Dropper (s1) <--> Decoder (s2) <--> h2
```

## Testing in bmv2

Two test files exist for checking functionality in mininet/bmv2:

```shell
$ ./bmv2/complete_fec_e2e.sh <input.pcap>
$ ./bmv2/complete_mcd_e2e.sh <input.pcap> <expected.pcap>
```

The first tests just the FEC functionality. A representative input file is
located in `bmv2/pcaps/tcp_100.pcap`

The second tests FEC + memcached functionality. Good input files are:
- `bmv2/pcaps/Memcached_in.pcap` and `bmv2/pcaps/Memcached_expected.pcap`
- `bmv2/pcaps/Memcached_in_short.pcap` and `bmv2/pcaps/Memcached_expected_short.pcap` 
- `bmv2/pcaps/Memcached_in_shortest.pcap` and `bmv2/pcaps/Memcached_expected_shortest.pcap`
