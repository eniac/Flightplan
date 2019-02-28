# P4 Behavioral Model - wharf and sample p4 files

## Dependencies

Building the p4 files for bmv2 requires global installation of p4c (https://github.com/p4lang/p4c),
testing requires installation of the behavioral model (https://github.com/p4lang/behavioral-model/),
with the additional `booster_switch`, as explained
[here](../cpuBoosters/bmv2/README.mdyy).

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
  - The dropper's drop rate can be configured using the `set_drop_rate(a, b)` action, which will
  drop one out of every `(a+b)` packets, but will never drop more than one of `b` packets.
- Sources/Sample.p4 : Sample use of a simple exetern that creates a modified copy of a packet
  - Run in mininet with `make run-Sample`

Executing `make run` will start up a network:
```
h1 <--> Encoder (s0) <--> Dropper (s1) <--> Decoder (s2) <--> h2
```

### Bmv2 configuration rewriting
The behavioral model repository does not support creation of packets
in the same manner that our boosters do.

Specifically, boosters return multiple packets from the same extern call, while
the behavioral model only supports the insertion of new packets at the beginning
of a stage.

To ameliorate this problem, the json output by p4c is rewritten before it
is loaded into the behavioral model, such that the extern functions which may
create packets are moved into a unique action.

This allows the `booster_switch` to pass over all action prior to the one in which
the packet was created, and pass the new packet directly to the booster that
created it.

The booster can then use the function `is_generated()` to see if it was the one that
generated that packet, and then it can deal with it accordingly.

## Testing in bmv2

Complete.p4 test scripts start up a topology:
```
h1 <--> Complete (s0) <--> Dropper (s1) <--> Complete (s2) <--> h2
```

The scripts also ensure that the pcap file located in `bmv2/lldp_enable_fec.pcap` is sent from s1 to s0 and s2, which enables FEC over the faulty link.


Two test files exist for checking complete.p4 functionality in mininet/bmv2:

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

**NB:** Before running these files, you must set the environment variable:
`BMV2_REPO` to point to a copy of the behavioral model repository which has
been built with the `booster_switch`, as detailed:
[here](../cpuBoosters/bmv2/README.md).

### Mininet file

The file that runs the mininet simulation is ultimately
[fec_demo.py](./bmv2/fec_demo.py), which depends on
[wharf_p4_mininet.py](./bmv2/wharf_p4_mininet.py).

The `wharf_p4_mininet` file borrows very heavily from the
[p4_mininet.py](https://github.com/p4lang/behavioral-model/blob/master/mininet/p4_mininet.py)
file located in the P4 behavioral model repository.

`fec_demo.py` accepts a variety of command line arguments specifying
which P4 configuration to load on which of s0, s1, and s2, among other
configurations.

The full list of arguments can be viewed with:
```
cd bmv2
PYTHONPATH=$BMV2_REPO/tools python fec_demo.py --help
```
