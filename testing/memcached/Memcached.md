# Memcached Booster Profiling Documentation

Broadly, profiling of the memcached booster consists of timing
the delay between a sent memcached request and its response,
with and without the booster in-line.

## Set-up

### Machine topology

The test topology consists of:
* The tofino, running the dataplane
* The FPGA running the booster
  * Tofino port 12/0
* A server running memcached
  * the "Memcached" server, tclust4 (10.0.0.4)
  * Tofino port 4/0
* A server running moongen and tcpreplay
  * the "Moongen" server, tclust5
  * Tofino port 5/0
* A server running pktgen
  * the "DPDK" server, tclust7
  * Tofino port 3/0
* A server to coordinate experiments from
  * the "Coordination" server, tclust6
* The server to program the bitsream to the fpga
  * the "Bitstream" server, tclust2

The tofino is started up with the arguments `-t -mi3 -me3`,
which sends telemetry data (the first 100 bytes) of each packet
that ingresses or egresses on port 3/0 to output 5 of the tofino.

Optionally, the tofino can be started with `-k`, which
puts the key-value cache inline on the way to the memcached server.

### Program Dependencies

The following applications are necessary on these machines:

* Bitstream server:
  * Xilinx installation toolchain
* Memcached server
  * Memcached (can be installed with `apt install memcached`)
* Tcpdump server
  * [Moongen](https://github.com/emmericp/MoonGen)
  * tcpreplay ( `apt install tcpreplay` )
* DPDK server:
  * pktgen
    * Clone https://github.com/jsonch/dpdkScripts
      * (To avoid having to change paths in the shremote config, clone this into ~/dcomp/dpdk/dpdkScripts)
    * Run dpdkScripts/installDpdk.sh (NO SUDO)
    * Run dpdkScripts/installPktgen.sh (NO SUDO)
* Coordination server:
  * [Shremote](https://github.com/isaac-ped/Shremote), checked out [here](..) as a git submodule
    * If the submodule is not checked out, initialize with: `git submodule init && git submodule update`


### File Dependencies

The shremote configuration file
assumes certain applications are in designated locations
and permissions are set accordingly.

Applications should be placed in the same directory as listed here,
or the config should be modified accordingly.

They are:

* `~/P4Boosters/FPGA/RSESDx/Run_project.bash`
  * Necessary on "Bistream" host
  * Should be configured to load the memcached bitstream to the FPGA
* `~/dcomp/MoonGen/`
  * On "tcpdump" host
  * The directory into which MoonGen was cloned and built
  * **Ensure `build/MoonGen` has the suid bit set** as explained [here](../e2e/e2e.md#Shremote-Privileges)
* `~/dcomp/dpdk/dpdkScripts/
  * Checked-out copy of dpdkScripts repo referenced above
  * **Ensure `dpdkScripts/dpdkInstall/pktgen-3.4.9/app/x86_64-native-linuxapp-gcc/pktgen`
    has the suid bit set for the running user**

## Shremote Configuration

The shremote configuration file used in this experiment is:

* [tofino_moongen.yml](execution/cfgs/tofino_moongen.yml)

This config file performs the following steps:
* Creates the pcap files to be sent
* Creates the lua file to be used by pktgen
* Programs the memcached FPGA
* Starts the tofino dataplane
* Starts memcached
* Sends the pcap file to warm up the cache
* Starts moongen
* Starts pktgen sending the test pcap
* Gets counters to ensure moongen recorded everything passed through the dataplane

## Running

### Single Experiment

You can start a single experiment using Shremote with:

```shell
cd execution
python ../../Shremote/shremote.py cfgs/tofino_moongen.yml <label> \
           --args="rate:<rate>;dataplane_flags:[-k]" \
           --out=<output_dir>
```

Where:
* `label` is a label for the experiment
* `rate` is the rate (in percent of total capacity) at which test packets should
be sent.
* `-k` is present if the inline cache is to be tested

### All rates

Two scripts exist to automate the running of all of a type of experiment:
```shell
cd execution
bash run_no_booster.sh <out_dir> <label> ["rate1 rate2 ..."]
```
and
```shell
cd execution
bash run_collisions.sh <out_dir> <label> ["rate1 rate2 ..."]
```
Will run the experiments without and with the booster, respectively.

If no rates are provided, the scripts will run all rates:
1%, and then 2% - 30% in steps of 2%
