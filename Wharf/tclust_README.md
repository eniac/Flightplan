# Tclust topology tests

P4 and topology.yml files exist which mimic the topology of the tclust test setup.

These files are contained in the following locations:

* `Sources/Tclust_*.p4`: The P4 files emulating the tofino, and external FPGAs
* `bmv2/topologies/tclust`: Topologies that configure the P4 switches running in mininet
to perform the various functionality
* `bmv2/tclust`: Programs to run and test topologies


## Building

Build the switches' JSON from the P4 files by running:
```
make tclust
```
from the `Wharf` folder


## P4 Files

The main p4 file is `Tclust_tofino.p4`, which is the main switch.
It is capable of runnin offloaded functionality on various external "FPGA"s.
It contains the following table types:
* `BoostedLink` : used for `ingress_compression`, `egress_compression`, `egress_encoding`,
  and `snort_cloning`.
  Turns on a feature (sends to the FPGA) when a packet is received or is being sent over a link
* `BoostedProtocol`: used for `kv_booster` : sends to an FPGA when a packet meets a certain
  protocol and source/dest port
* `mac_forwarding`: Matches the dst MAC address of a packet to the port which the packet should
  ultimately egress from
* `offload`: Specifies the port at which a segment of code is located.
  If a booster is enabled (via, e.g. `ingress_compression`, the corresponding code segment should
  also be defined in this map.
  The code segments are:
  * `0x2`: FEC Decoding
  * `0x4`: Decompression
  * `0x6`: KV Store
  * `0x8`: Compression
  * `0xa`: FEC Encoding
  * `0xc`: Forwarding (0xc should always be mapped to the action `strip_fp_hdr`)

The other P4 files are small snippets which run various boosters on external FPGAS.
They consist of the encoder/decoder, compressor/decompressor, mcd, and a special
file `Tclust_noop.p4` which simply forwards packets through, and is to be used for testing.


## Extern Topologies

The directory `bmv2/topologies/tclust` contains (at this time) 7 topology files that enable
different funcitonality on the basic tclust topolopgy (as well as 6 topology files which
include legacy boosters, described briefly below).

All files use the same `tclust_tofino.p4` switch, with different features enabled
via control-plane rules.

The most complete topologies are `tclust_complete.yml` and `tclust_mcd_complete.yml`,
which both enable the FEC, KV-store, and Header Compression. The difference between
these files is that `tclust_mcd_complete.yml` also enables FEC encoding of memcached packets -
a feature which ensures all memcached packets are successfully delivered, but is less
true to the actual tclust topology.

Other topology files enable a subset of these features.


## Legacy Topologies

Several legacy boosters have also been enabled in the tclust mininet topology setup:
mcrouter, snort, and ufw.
Once the relevant programs have been installed, topologies that utilize these programs
can be started up using the corresponding topology files in `bmv2/topologies/tclust`


## Test Programs

The directory `bmv2/tclust` contains programs for testing various combinations of
boosters on the mininet tclust topologies.

There are four basic files for running these tests:
* `tclust_replay.sh`: Replays a file from `iperf_c` to `iperf_s`, ensuring that the packets
received match those that were sent
* `tclust_mcd.sh`: Replays memcached packets from `mcd_c` to `mcd_s`, and ensures that
`mcd_c` receives the proper packets in response
* `tclust_iperf.sh` : Runs iperf between `iperf_c` and `iperf_s`. In this test, no checks are
performed, and the output must be manually inspected.
* [./bmv2/tclust/tclust_e2e.sh](./bmv2/tclust/tclust_e2e.sh): Runs iperf and memcached streams simultaneously. Does not perform checks,
but data is then present for offline analysis of latency, etc.

In addition, `tclust_snort.sh`, `tclust_ufw.sh`, and `tclust_mcrouter.sh` test the legacy boosters.
All other test programs utilize one of these basic programs with specific topologies or inputs.


## End-to-end testing

As described above, [./bmv2/tclust/tclust_e2e.sh](./bmv2/tclust/tclust_e2e.sh) runs iperf and mcd traffic simultaneously.

To run a full  set of end-to-end experiments, use [./bmv2/tclust/all_tclust_e2e.sh](./bmv2/tclust/all_tclust_e2e.sh), which will
run with each booster enabled in turn.

Results can be analyzed with the notebook contained in [analysis/e2e_analysis.ipynb](analysis/e2e_analysis.ipynb).


# Regression tests

Whenever a significant change is made to the code then these scriprts should be
run to ensure that current features are not broken

* [run_e2e_tests.sh](run_e2e_tests.sh): Runs tests on the complete.p4 topology (not the tclust topology)
* [run_tclust_tests.sh](run_tclust_tests.sh): Runs tests with different combinations of boosters on the tclust topology
* [run_legacy_tests.sh](run_legacy_tests.sh): Runs tests with the legacy boosters on the tclust topology
