# P4 Behavioral Model - wharf and sample p4 files

## Dependencies

Compiling P4 programs into JSON files for BMv2 requires p4c (https://github.com/p4lang/p4c).
Running the resulting compiled programs requires installation of BMv2 (https://github.com/p4lang/behavioral-model/),
with the additional `booster_switch` as explained [here](../cpuBoosters/bmv2/README.md).

The recommended p4c and behavirol-model version are:
* commit `c67f85d45feea5c31312c9a1e8a7063a976a1469` of the [behavioral_model](https://github.com/p4lang/behavioral-model/) repo
* commit `730986bd4dce83a121159d06beb08ffa961afdc7` of the [p4c](https://github.com/p4lang/p4c) repo

The code modules and submodles can be synched to the above commit HASH as follows:
* `git clone --recursive https://github.com/p4lang/p4c.git`
* git checkout HASH
* `git submodule update`

## Building booster_switch

Build the `booster_switch` by following [these instructions](../cpuBoosters/bmv2/README.md).

Then set the environment variable `BMV2_REPO` to point the directory
containing the behavioral model repository.

## `BMV2_REPO`

The environment variable `BMV2_REPO` mentioned in the previous step is also needed when running some configuration scripts,
otherwise you'll get failures with accompanying output that looks like this:
```
Cannot import RUNTIME_CLI: Traceback (most recent call last):
  File "/home/nsultana/.../Wharf/bmv2/flightplan_p4_mininet.py", line 40, in <module>
    from runtime_CLI import thrift_connect, load_json_config, RuntimeAPI
ImportError: No module named runtime_CLI
```
and
```
Commands requested, but Runtime CLI not present! Ensure $BMV2_REPO/tools is on PYTHONPATH
Traceback (most recent call last):
  File "/home/nsultana/.../Wharf/bmv2/send_bmv2_commands.py", line 39, in <module>
    main()
  File "/home/nsultana/.../Wharf/bmv2/send_bmv2_commands.py", line 34, in main
    send_commands(thrift_port, cfg_path, [command])
  File "/home/nsultana/.../Wharf/bmv2/flightplan_p4_mininet.py", line 50, in send_commands
    raise Exception("Could not execute commands: Runtime API not present")
Exception: Could not execute commands: Runtime API not present
```

**WARNINGS** The `BMV2_REPO` variable is hardcoded in several scripts, beware.

## Building P4 programs to run on booster_switch

If the `booster_switch` was built with only certain boosters enabled
then those same boosters (and only those boosters) will have to be
enabled in the build process for P4 programs, described here.
Build may have to be cleaned with `make clean` before changing enabled
boosters.

To build Complete.p4 with only FEC enabled, run:
```
make BOOSTERS=FEC
```

To build Complete.p4 with only FEC And Compression boosters, run
```
make BOOSTERS="FEC COMPRESSION"
```

To build with all boosters, simply run `make`.

You can also specify compilation targets `bmv2` or `Sample`.
`bmv2` will compile all the sources mentioned below except for [Sources/Sample.p4](Sources/Sample.p4):

- [Sources/Complete.p4](Sources/Complete.p4) : Program to be run on all switches
  - Performs Memcached'ing, fec, and/or header compression depending on traffic type
- [Sources/targets.h](Sources/targets.h) : Target-specific definitions used by fec encoder and decoder
- [Sources/FEC.p4](Sources/FEC.p4) : Calls to encode, decode, or retrieve parameters based on fec encoding
- [Sources/Forwarding.p4](Sources/Forwarding.p4) : Determines the egress port out of which a packet should be sent
- [Sources/Parsing.p4](Sources/Parsing.p4) : Parsing and deparsing of packets
- [Sources/LLDP.p4](Sources/LLDP.p4) : Activation of FEC on ports through LLDP
- [Sources/Encoder.p4](Sources/Encoder.p4) : Definition of `main` switch target for encoder
- [Sources/Decoder.p4](Sources/Decoder.p4) : Definition of `main` switch target for decoder
- [Sources/Dropper.p4](Sources/Dropper.p4) : A `main` target that will drop a configurable number of packets
  - The dropper's drop rate can be configured using the `set_drop_rate(a, b)` action, which will
  drop one out of every `(a+b)` packets, but will never drop more than one of `b` packets.
- [Sources/Sample.p4](Sources/Sample.p4) : Sample use of a simple exetern that creates a modified copy of a packet

A network of Encoders, Droppers, Decoders, and "Complete"s can be started with
`sudo -E python bmv2/start_flightplan_mininet.py <config.yml>`
as described in the [testing](README.md#testing_in_mininet) section below.


### BMv2 configuration rewriting

The `booster_switch` requires slightly different handling of extern
functions than is possible with the normal bmv2 compiler.
To mitigate this, the json output by the compiler is slightly
modified with the script [split_extern_event.py](split_extern_event.py)
to achieve the proper functionality.

In brief, the reason for the rewriting is as follows:
* The bmv2 compiler puts each logical unit of the P4 file
into an "action", which may consist of one or more "primitives".
* The `booster_switch` enables the possibility that externs (a type of primitive)
may create new packets, which begin processing in the same extern that generated
them (the extern thus returning two values, one after another)
* In bmv2, actions are treated as a single unit, not primitives,
thus, the primitives must be placed in their own action to ensure
correct functionality.

With this modification, externs used in the `booster_switch` can call the
function `is_generated()` to determine if the packet that is currently
being processed is one that was just generated by that extern.

For more details on the splitting process, view [rewriting_README.md](rewriting_README.md)

## Building for SDNet

SDNet-targetted compilation is not yet supported.
Adding `-DTARGET_SDNET` to the `p4c` command to enables the appropriate
target-specific code, but this doesn't do much at the moment.


# Testing in Mininet
Install `mininet`.

Perform `sudo apt install net-tools` to avoid the following error:
```
Cannot find required executable ifconfig.

Please make sure that Mininet is installed and available in your $PATH:...'
```
Install `pyyaml` using `pip install pyyaml`
Install `dpkt` using `sudo apt-get install python-dpkt`
Install `tcpreplay` from `https://launchpad.net/ubuntu/bionic/+package/tcpreplay` or any other link that you prefer.

# Memcached
Install `memcached`
First, make sure that your local package index is updated:
`sudo apt-get update`

Next, install the official package as follows:
`sudo apt-get install memcached`

Install libmemcached-tools, a library that provides several tools to work with your Memcached server:
`sudo apt-get install libmemcached-tools`

## Tclust tests
For information on the tests that mimic the tclust topology,
view [tclust_README.md](tclust_README.md).


## Complete.p4
The [./Sources/Complete.p4](./Sources/Complete.p4) program encompasses the encoder, decoder, and memcached, executing them on the same switch
(except if such features are disabled via `#define`'s).


## Execution
To execute one or more P4 programs -- possibly but not necessarily related to Flightplan -- on BMv2 nodes in Mininet, use the command:

```shell
sudo -E python bmv2/start_flightplan_mininet.py <cfg_file.yml>
```
where the `cfg_file` specifies the topology and initial state of mininet.

[./bmv2/start_flightplan_mininet.py](./bmv2/start_flightplan_mininet.py) sets
up simulation using Mininet by instantiating the topology and configuring the
hosts and switches defined in a config file that is provided as a parameter,
such as
[./bmv2/topologies/complete_topology.yml](./bmv2/topologies/complete_topology.yml).

[./bmv2/start_flightplan_mininet.py](./bmv2/start_flightplan_mininet.py)
depends on [flightplan_p4_mininet.py](./bmv2/flightplan_p4_mininet.py) which
borrows very heavily from the
[p4_mininet.py](https://github.com/p4lang/behavioral-model/blob/master/mininet/p4_mininet.py)
file located in the P4 behavioral model repository.

[./bmv2/start_flightplan_mininet.py](./bmv2/start_flightplan_mininet.py)
accepts a variety of command line arguments. The full list can be viewed with:
```
sudo -E python bmv2/start_flightplan_mininet.py --help
```

Below is the snippet for an example topology consisting of one switch and two hosts.
Note that the switch (`s1`) is running the [./Sources/Forwarder.p4](./Sources/Forwarder.p4) program that generated `Forwarder.json`.

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
          -table_add forward set_egress 0 => 1
          -table_add forward set_egress 1 => 0

```

A detailed list of configurable features is given in the [example_topology.yml](./bmv2/topologies/example_topology.yml)

The most complete topology at this time used for running the test experiments is defined in [./bmv2/topologies/complete_topology.yml](./bmv2/topologies/complete_topology.yml).

Running [./bmv2/start_flightplan_mininet.py](./bmv2/start_flightplan_mininet.py) with config file [./bmv2/topologies/complete_topology.yml](./bmv2/topologies/complete_topology.yml) will start up a topology:
```
h1 <--> s1(Complete.p4) <--> s2(Dropper.p4) <--> s3(Complete.p4) <--> h2
```

The config file also enables FEC from `s1->s2` and `s3->s2`
by replaying the appropriate packets from s2 to s3 & s1 -- look for the
entries under `replay:` in the YAML file:
```
s2:
    cfg: ../../build/bmv2/Dropper.json
    interfaces:
...
    replay:
        s1: ../pcaps/lldp_enable_fec.pcap
        s3: ../pcaps/lldp_enable_fec.pcap
...
```
It also sets up the forwarding tables on the different switches
by sending the commands in the `cmds` files.

The data packets (K paramater) and parity packets (H parameter) to determine the
operation of FEC can be defined in the `fec_encoder_commands.txt` and
`fec_decoder_commands.txt` files for error correction.
If up to H packets out of a set of H+K packets are dropped,  then FEC will be able to recover the data over the faulty links.
More information on the FEC booster can be found [FEC Booster](https://www.seas.upenn.edu/~nsultana/files/netcompute.pdf).

**NB:** MAC addresses are assigned dynamically to the host nodes if their MAC addresses are not specified in the `<cfg_file>`.

**NB:** The MAC address assigned to host nodes may differ from the MAC address specified in the `cfg_file`.
If the error message `SIOCSIFHWADDR: Cannot assign requested address` is
produced when Mininet attempts to set the MAC address of a virtual interface
then this means that the MAC address specifed in the config file is invalid.
Make sure to use a valid 48 bit MAC address.

The command `sudo -E python bmv2/start_flightplan_mininet.py --cli` opens the Mininet CLI through which you can confirm or tune the configurations of nodes in the `cfg_file`.


### End-to-end tests

Two end-to-end tests exist, one for the FEC functionality and one for Memcached:
```shell
$ ./bmv2/complete_fec_e2e.sh <input.pcap>
$ ./bmv2/complete_mcd_e2e.sh <input.pcap> <expected.pcap>
```

**NB** Host programs run for these experiments are iperf for Test 1 and Memcached for Test 2.

**NB1** Ensure that environment variable `BMV2_REPO` has been set up as mentioned
in the [Building booster_switch](README.md#building-booster_switch) section.


#### Test 1: FEC
```
$ ./bmv2/complete_fec_e2e.sh <input.pcap>
```
This test checks that the packets received by h2 are identical to those sent by
h1, even in the presence of drops.

This test involves the following steps:
1. Replay special packets between switches to activate the FEC booster (faulty links from s2->s1 and s2->s3) in the simulation environment.
2. Execute control plane commands on switches to add records to the tables, used for forwarding and FEC configuration (parameters H and K).
3. Start programs on the hosts.
4. Replay packets -- a sample input file for the FEC functionality test is `bmv2/pcaps/tcp_100.pcap`.
5. Check to ensure that the packets received by h2 are identical to those sent by h1, even in the presence of drops.

##Debugging
```
$ ./bmv2/complete_fec_e2e.sh <input.pcap>
```
This is the simplest test and should be your first test.
In case the test is declared failed, go through the messages that get printed on the console. In case there is nothing obviously wrong in the console messages, then switch to log files. Go through the log files, scanning particularly for errors and missing things. For example, in case you missed to install tcpreplay from the previos steps, then the log file portion will read as:
```
bash: tcpreplay: command not found
```

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


#### Test 2: Memcached
```
$ ./bmv2/complete_mcd_e2e.sh <input.pcap> <expected.pcap>
```
This second tests the Memcached cache, checking that the Memcached
replies received by h1 are as expected. We used the input files
`bmv2/pcaps/Memcached_in_short.pcap` and `bmv2/pcaps/Memcached_expected_short.pcap`.

**NB** For testing Memcached functionality the MAC addresses in [bmv2/pcap_tools/pcap_sub.py](bmv2/pcap_tools/pcap_sub.py) must match those used in the config file [./bmv2/topologies/complete_topology.yml](./bmv2/topologies/complete_topology.yml).


# Adding new boosters
New boosters can be invoked from existing P4 files, by modifying those files
to make the extern call, or writing new P4 files. Further the desired topology
needs to be written or adapted from an existing one.

It might be useful to reuse the [Makefile](Makefile) to manage the compilation
of additional files. Reuse could consist of the following modifications:
1) Add the source to the `DEPS` variable (`DEPS=... Sources/XXX.p4`)
2) Add the output as a dependency of the `bmv2` target (`bmv2: ... $(BLD_BMV2)/XXX.json`)
3) Add relevant externs to the list `EXTERNS` that are split by `split_extern_events.py`
(`EXTERNS=... XXX`)


# Other experiments
* `P4Boosters/Wharf$ ./bmv2/start_checked_topology.sh` runs an experiment involving the extended Flightplan header which apply program-integrity preservation. This uses the "checked" versions of [P4](Sources/CheckedFragment.p4) and [topology](bmv2/topologies/complete_topology_checked.yml) files.
**NOTE** This requires recompiling the switch (`make configure_runtime BOOSTERS="..."`) to include the stateful extern objects (
[ReceiverNakState.h](../cpuBoosters/bmv2/booster_switch/ReceiverNakState.h),
[SenderSeqState.h](../cpuBoosters/bmv2/booster_switch/SenderSeqState.h),
[ReceiverNakState.cpp](../cpuBoosters/bmv2/booster_switch/ReceiverNakState.cpp),
[SenderSeqState.cpp](../cpuBoosters/bmv2/booster_switch/SenderSeqState.cpp))
