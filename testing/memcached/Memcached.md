# Memcached Booster Profiling Documentation

Broadly, profiling of the memcached booster consists of timing
the delay between a sent memcached request and its response,
with and without the booster in-line.

## Set-up

### Machine topology

The test topology consists of:
* A switch
* The FPGA running the booster
* The server to program the bitsream to the fpga
  * the "Bitstream" server, johnshack
* A server running memcached
  * the "Memcached" server, tclust10 (10.0.0.3)
* A server running tcpdump/moongen
  * the "Tcpdump" server, tclust8
* A server running pktgen
  * the "DPDK" server, tclust4
* A server to coordinate experiments from
  * the "Coordination" server, tclust11

To ease the transition between booster/nonbooster experiments,
the origin IP address of packets loaded into pktgen
determines whether the packet will be served by the
booster or memcached alone.

In the following configuration, a source IP address of
`10.0.0.10` implies the packet is destined for
the booster, while a source IP of `10.0.0.20`
implies the packet is destined for memcached alone.

The switch, an Arista running directflow, is programmed
with the following configuration:

```
localhost(config-directflow)#show active
 directflow
   no shutdown
   flow dpdk-moon
      match input interface Ethernet5/1
      action output interface Ethernet18/1
   !
   flow fpga-memcached
      match input interface Ethernet7/1
      match ethertype ip
      match destination ip 10.0.0.3
      action output interface Ethernet20/1
   !
   flow fpga-moon
      match input interface Ethernet7/1
      match ethertype ip
      match destination ip 10.0.0.10
      action output interface Ethernet18/1
   !
   flow memcached-fpga
      match input interface Ethernet20/1
      match ethertype ip
      match destination ip 10.0.0.10
      action output interface Ethernet7/1
   !
   flow memcached-moon
      match input interface Ethernet20/1
      match ethertype ip
      match destination ip 10.0.0.20
      action output interface Ethernet18/1
   !
   flow moon-drop
      match input interface Ethernet18/1
      action drop
   !
   flow moon-fpga
      priority 1
      match input interface Ethernet18/1
      match ethertype ip
      match source ip 10.0.0.10
      action output interface Ethernet7/1
   !
   flow moon-memcached
      priority 1
      match input interface Ethernet18/1
      match ethertype ip
      match source ip 10.0.0.20
      action output interface Ethernet20/1
```



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
    * Run dpdkScripts/installDpdk.sh (NO SUDO)
    * Run dpdkScripts/installPktgen.sh (NO SUDO)
    * Start dpdk-pktgen with dpdkScripts/runScripts/connectx3/pktGen.sh (You may want to copy and adjust this script)
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
* `~/dcomp/moongen/MoonGen/`
  * On "tcpdump" host
  * The directory into which MoonGen was cloned and built
  * **Ensure `build/MoonGen` has the suid bit set** as explained [here](../e2e/e2e.md#Shremote-Privileges)
* `~/dcomp/dpdk/run_lua.sh`
  * On "DPDK" host
  * Assumes it is placed in the parent directory of dpdkScripts
  * **Ensure `dpdkScripts/dpdkInstall/pktgen-3.4.9/app/x86_64-native-linuxapp-gcc/pktgen`
    has the suid bit set for the running user**

### Local files

The following files are used by the testing coordination tool (shremote),
and should be placed in the directory from which shremote.py is run

* `pktgen_template.lua`
  * template lua script for pktgen, into which rate is inserted
* `bounce.lua`
  * The script run by moongen which logs and redirects packets from DPDK or memcached

## Shremote Configuration

There are three shremote configuration files used in this experiment:

* [booster_alone_preset.yml](execution/cfgs/booster_alone_preset.yml)
* [mcd_alone_preset.yml](execution/cfgs/mcd_alone_preset.yml)
* [booster_mcd_preset.yml](execution/cfgs/booster_mcd_preset.yml)

(The `preset` refers to the fact that the SET commands are sent prior to the start
 of the experiment)

These config files perform the following steps:
* Creates the GET pcap file
* Program the memcached FPGA
* Start Memcached
* Start MoonGen
* Send the SET commands over tcpreplay
* Start pktgen sending the GET commands

## Running

### Single Experiment

You can start a single experiment using Shremote with:

```shell
python ../../Shremote/shremote.py <cfg.yml> <label> \
           --args="mcd_ip:<src_ip>;p_collision:<prob>;rate:<rate>" \
           --out=<output_dir>
```

Where cfg.yml is one of the config yml files,
`src_ip` is `10.0.0.10` to use the booster, and `10.0.0.20` to not use the booster,
`prob` is the probability of collision,
and `rate` is the rate (in percent of total capacity) at which GET packets should
be sent.

### All rates

An aggregation script `run_rates.py` automates the running of multiple
rates of a single experiment. Start with:

```shell
python run_rates.py <label> <cfg.yml> \
           --args "mcd_ip:<src_ip>;p_collision:<prob>" \
           --out <output_dir> \
           --rates "0.10,0.25,..."
```
To run at the rates 0.10, 0.25, etc.

Finally, three scripts exist which run the full sets of booster, nobooster, and
10% miss experiments. Those files can be run with

```shell
bash run_all_booster_alone.sh <label>
bash run_all_mcd_alone.sh <label>
bash run_all_booster_misses.sh <p_collision> <label>
```
