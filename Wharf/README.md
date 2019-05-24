# P4 Behavioral Model - wharf and sample p4 files

## Dependencies

Building the p4 files for bmv2 requires global installation of p4c (https://github.com/p4lang/p4c),
testing requires installation of the behavioral model (https://github.com/p4lang/behavioral-model/),
with the additional `booster_switch`, as explained
[here](../cpuBoosters/bmv2/README.md).

## Selecting Boosters

If the booster switch was built with only certain boosters enabled, those same
boosters (and only those boosters) will have to be enabled in the build process
here.

To build Complete.p4 with only FEC enabled, run:
```
make BOOSTERS=FEC
```

To build Complete.p4 with only FEC And Compression boosters, run
```
make BOOSTERS="FEC COMPRESSION"
```

To build with all boosters, simply run `make`.

**NB:** Build may have to be cleaned with `make clean` before changing enabled boosters.

## Building for SDNet

SDNet build is not yet added to the makefile.

Building for SDNet requires adding `-DTARGET_SDNET` to to `p4c` command to enable the
appropriate target-specific code.

## Building for bmv2

Sample and fec booster bmv2 inputs can both be built with `make bmv2`

- Sources/Complete.p4 : Program to be run on all switches
  - Performs Memcached'ing, fec, and/or header compression depending on traffic type
- Sources/targets.h : Target-specific definitions used by fec encoder and decoder
- Sources/FEC.p4 : Calls to encode, decode, or retrieve parameters based on fec encoding
- Sources/Forwarding.p4 : Determines the egress port out of which a packet should be sent
- Sources/Parsing.p4 : Parsing and deparsing of packets
- Sources/LLDP.p4 : Activation of FEC on ports through LLDP
- Sources/Encoder.p4 : Definition of `main` switch target for encoder
- Sources/Decoder.p4 : Definition of `main` switch target for decoder
- Sources/Dropper.p4 : A `main` target that will drop a configurable number of packets
  - The dropper's drop rate can be configured using the `set_drop_rate(a, b)` action, which will
  drop one out of every `(a+b)` packets, but will never drop more than one of `b` packets.
- Sources/Sample.p4 : Sample use of a simple exetern that creates a modified copy of a packet

A network of Encoders, Droppers, Decoders, and "Complete"s can be started with
`sudo -E python bmv2/start_flightplan_mininet.py <config.yml>`
as described in the testing section below.

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

## Testing in bmv2 and mininet

The `Complete.p4` program starts up the encoder, decoder, and memcached on the same switch
(except if such features are disabled via `#define`'s).

To run a topology for flightplan in bmv2 and mininet, use the command:

```shell
sudo -E python bmv2/start_flightplan_mininet.py <cfg_file.yml>
```

Where the `cfg_file` specifies the topology and initial state of mininet.

The most complete topology at this time is defined in `bmv2/topologies/complete_topology.yml`.

Below is the snippet for an example of a simple one switch, two host toplogy.

``` yaml
hosts:
    h1 : {}
    h2 : {}

switches:
    s1:
        cfg: ../../build/bmv2/Forwarder.json
        interfaces:
          -link: h1
          -link: h2
        cmds: 
          -table_add forward set_egress 0 =>1
          -table_add forward set_egress 1 =>0

```

A detailed list of configurable features is given in the [example_topology](./bmv2/topologies/example_topology.yml)

Running `start_flightplan_mininet.py` with this config file will start up a topology:
```
h1 <--> Complete (s0) <--> Dropper (s1) <--> Complete (s2) <--> h2
```

The config file also enables FEC from `s0->s1` and `s2->s1`
(by replaying the appropriate packets from s2 to s1 & s3), in addition
to setting up the forwarding tables on the different switches
(by sending the commands in the `cmds` files).


### End-to-end tests

Two end-to-end tests exist, one for the FEC functionality and one for memcached.
They are:

```shell
$ ./bmv2/complete_fec_e2e.sh <input.pcap>
$ ./bmv2/complete_mcd_e2e.sh <input.pcap> <expected.pcap>
```

The first tests just the FEC functionality, ensuring that the packets received by
h2 are identical to those sent by h1, even in the presence of drops.

A sample input file is `bmv2/pcaps/tcp_100.pcap`

The second tests FEC + memcached functionality, ensuring that the memcached
responses received by h1 are as expected. Good input files are:
- `bmv2/pcaps/Memcached_in_short.pcap` and `bmv2/pcaps/Memcached_expected_short.pcap`

**NB:** Before running these files, you must set the environment variable:
`BMV2_REPO` to point to a copy of the behavioral model repository which has
been built with the `booster_switch`, as detailed:
[here](../cpuBoosters/bmv2/README.md).

#### Running different programs on switches
The default test runs the same program on switches. The "two halves" tests run
different programs on different switches, but has the same effect of running
the same program on all switches.

To use simpler test add `TWO_HALVES=1` to the environment:
```shell
TWO_HALVES=1 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap
```

The more complex test further offloads header compression to a separate switch. To run this test add `TWO_HALVES=2` to the environment:
```shell
TWO_HALVES=2 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap
```

### Mininet file
The file that runs the mininet simulation is ultimately
[start_flightplan_mininet.py](./bmv2/start_flightplan_mininet.py), which depends on
[flightplan_p4_mininet.py](./bmv2/flightplan_p4_mininet.py).

The `flightplan_p4_mininet.py` file borrows very heavily from the
[p4_mininet.py](https://github.com/p4lang/behavioral-model/blob/master/mininet/p4_mininet.py)
file located in the P4 behavioral model repository.

`start_flightplan_mininet.py` accepts a variety of command line arguments specifying
which P4 configuration to load on which of s0, s1, and s2, among other
configurations.

The full list of arguments can be viewed with:
```
sudo -E python bmv2/start_flightplan_mininet.py --help
```

# Adding new boosters
New p4 files may be added to the build process in two steps:

First, add the necessary functionality to `Complete.p4`, or to a standalone p4 file which
implements the booster

Modify the makefile to track the new dependencies and targets.

The modifications to the makefile must be made in three locations:

1) Add the source to the `DEPS` variable (`DEPS=... Sources/XXX.p4`)
2) Add the output as a dependency of the `bmv2` target (`bmv2: ... $(BLD_BMV2)/XXX.json`)
3) Add relevant externs to the list `EXTERNS` that are split by `split_extern_events.py`
(`EXTERNS=... XXX`)
