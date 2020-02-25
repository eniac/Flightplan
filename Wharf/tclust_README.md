# Tclust topology tests

P4 and topology.yml files exist which mimic the topology of the tclust test setup.

These files are contained in the following locations:

* `Sources/Tclust_*.p4`: The P4 files emulating the configuration of the Tofino and FPGAs in the Tclust testbed.
* `bmv2/topologies/tclust`: Various Tclust-based topologies that configure the virtual P4 switches running in Mininet to execute the P4 programs mentioned in the previous entry.
* `bmv2/tclust`: Scripts to run and test Tclust-based topologies in Mininet.


## Building

Compile the P4 programs by running this command in the `Wharf` directory:
```
make tclust
```


## P4 Programs

The main P4 file is `Tclust_tofino.p4`. It runs on a switch that offloads
functionality to FPGA devices connected to the switch.
Switches and FPGAs are all run virtually in Mininet.

This P4 file contains the following tables, some abstracted as control blocks:
* `BoostedLink`: used for tables `ingress_compression`, `egress_compression`, `egress_encoding`,
  and `snort_cloning`.
  This is used to enable forwarding to the FPGA from the switch, thus enabling part of the program that's been offloaded to the FPGA.
* `BoostedProtocol`: used for `kv_booster`. This forwards to an FPGA when a packet matches a certain
  protocol and source/dest port.
* `mac_forwarding`: Matches the dst MAC address of a packet to the port which the packet should
  ultimately egress from.
* `offload`: Specifies the port at which a segment of code, hosted on an FPGA, is located.
  If a booster is enabled (via, e.g. `ingress_compression`) the corresponding code segment should
  also be defined in this map.
  The code segments are:
  * `0x2`: FEC Decoding
  * `0x4`: Decompression
  * `0x6`: KV Store
  * `0x8`: Compression
  * `0xa`: FEC Encoding
  * `0xc`: Forwarding (0xc should always be mapped to the action `strip_fp_hdr`)

The other P4 files are small snippets that run various boosters on virtual FPGAs.
They consist of the encoder/decoder, compressor/decompressor, mcd cache, and a special
file `Tclust_noop.p4` which simply forwards packets through (used for testing).


## Extern Topologies

The directory `bmv2/topologies/tclust` contains (at this time) 7 topology files that enable
different functionality on the basic tclust topology (as well as 6 topology files that
include legacy boosters, described briefly below).

All files use the same [./Sources/Tclust_tofino.p4](./Sources/Tclust_tofino.p4) switch, with different features enabled
via control-plane rules.

The most complete topologies are [./bmv2/topologies/tclust/tclust_complete.yml](./bmv2/topologies/tclust/tclust_complete.yml) and
[./bmv2/topologies/tclust/tclust_mcd_complete.yml](./bmv2/topologies/tclust/tclust_mcd_complete.yml).
They both enable the FEC, KV-store, and Header Compression. The difference
between these files is that
[./bmv2/topologies/tclust/tclust_complete.yml](./bmv2/topologies/tclust/tclust_complete.yml)
also enables FEC encoding of Memcached packets - a feature which ensures all
Memcached packets are successfully delivered, but is less true to the actual
tclust topology.

Other topology files enable a subset of these features.


## Legacy network functions

Several legacy network functions have also been enabled in the tclust mininet topology setup:
mcrouter (and `memtier_benchmark` for testing), snort, and ufw.
Once the relevant programs have been installed, topologies that utilize these programs
can be started up using the corresponding topology files in `bmv2/topologies/tclust`

Commands to install the programs are as follows:
```shell
# Mcrouter: (from https://github.com/facebook/mcrouter)
sudo wget -O - https://facebook.github.io/mcrouter/debrepo/bionic/PUBLIC.KEY | sudo apt-key add
echo "deb [arch=amd64] https://facebook.github.io/mcrouter/debrepo/bionic bionic contrib" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install mcrouter

# memtier_benchmark: (from https://github.com/RedisLabs/memtier_benchmark)
sudo apt-get install build-essential autoconf automake libpcre3-dev libevent-dev pkg-config zlib1g-dev libssl-dev
git clone https://github.com/RedisLabs/memtier_benchmark.git
cd memtier_benchmark
autoreconf -ivf
./configure
make -j11
sudo make install

# snort
# You may delete the interfaces in the prompt that follows so it does not automatically apply
sudo apt install snort

# ufw
sudo apt install ufw
```


## Test Programs

The directory `bmv2/tclust` contains programs for testing various combinations of
boosters on the mininet tclust topologies.

There are four basic files for running these tests:
* [./bmv2/tclust/tclust_replay.sh](./bmv2/tclust/tclust_replay.sh): Replays a file from the host `iperf_c` to the host `iperf_s`, ensuring that the packets received match those that were sent.
* [./bmv2/tclust/tclust_mcd.sh](./bmv2/tclust/tclust_mcd.sh): Replays memcached packets from the host `mcd_c` to the host `mcd_s`, and ensures that `mcd_c` receives the proper packets in response.
* [./bmv2/tclust/tclust_iperf.sh](./bmv2/tclust/tclust_iperf.sh): Runs iperf between `iperf_c` and `iperf_s`. In this test, no checks are
performed, and the output must be manually inspected.
* [./bmv2/tclust/tclust_e2e.sh](./bmv2/tclust/tclust_e2e.sh): Runs iperf and memcached streams simultaneously. Does not perform checks,
but data is then present for offline analysis of latency, etc.

In addition, [./bmv2/tclust/tclust_snort.sh](./bmv2/tclust/tclust_snort.sh), [./bmv2/tclust/tclust_ufw.sh](./bmv2/tclust/tclust_ufw.sh),
 and [./bmv2/tclust/tclust_mcrouter.sh](./bmv2/tclust/tclust_mcrouter.sh) test the legacy boosters.
All other test programs utilize one of these basic scripts with specific topologies or inputs.


## End-to-end testing

* As described above, [./bmv2/tclust/tclust_e2e.sh](./bmv2/tclust/tclust_e2e.sh) runs iperf and mcd traffic simultaneously.
* To run a full  set of end-to-end experiments, use [./bmv2/tclust/all_tclust_e2e.sh](./bmv2/tclust/all_tclust_e2e.sh), which will
run with each booster enabled in turn.
* Results can be analyzed with the notebook contained in [analysis/e2e_analysis.ipynb](analysis/e2e_analysis.ipynb).

### Dependencies
Running [./bmv2/tclust/all_tclust_e2e.sh](./bmv2/tclust/all_tclust_e2e.sh) invokes a number of scripts, including
[generate_memcached.py](../MemcachedFPGATest/generate_memcached.py), which may have other dependencies. In the
case of [generate_memcached.py](../MemcachedFPGATest/generate_memcached.py), it depends on the numpy package,
without which you'll get the following output:
```
nsultana@tclust9:~/P4Boosters/Wharf$ ./bmv2/tclust/all_tclust_e2e.sh
Generating 9900 get 1100 set packet trace bmv2/test_output/tclust_e2e/bw_none_q_none_dur_100/tclust_noop/test.pcap
Traceback (most recent call last):
  File "bmv2/../../MemcachedFPGATest/generate_memcached.py", line 10, in <module>
    import numpy.random
ImportError: No module named numpy.random
tcpdump: bmv2/test_output/tclust_e2e/bw_none_q_none_dur_100/tclust_noop/warmup.pcap: No such file or directory
...
```
This can be fixing by installing numpy as follows:
```
nsultana@tclust9:~/P4Boosters/Wharf$ pip install numpy
Collecting numpy
  Downloading https://files.pythonhosted.org/packages/3a/5f/47e578b3ae79e2624e205445ab77a1848acdaa2929a00eeef6b16eaaeb20/numpy-1.16.6-cp27-cp27mu-manylinux1_x86_64.whl (17.0MB)
    100% |████████████████████████████████| 17.0MB 41kB/s
Installing collected packages: numpy
Successfully installed numpy-1.16.6
```


# Regression tests

Whenever a significant change is made to the code then these scripts should be
run to ensure that current features are not broken:

* [run_e2e_tests.sh](run_e2e_tests.sh): Runs tests on the original Complete.p4 topology (not the tclust topology)
* [run_tclust_tests.sh](run_tclust_tests.sh): Runs tests with different combinations of boosters on the tclust topology
* [run_legacy_tests.sh](run_legacy_tests.sh): Runs tests with the legacy boosters on the tclust topology
