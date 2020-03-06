# E2E testing documentation

E2E testing using the three FPGAs connected to the tofino
consists of five experiments:

* Baseline
* `+ Header Compression`
* `+ 5% drop rate`
* `+ FEC`
* `+ KV cache`

The experiment traffic consists of 10 iperf (TCP) clients server pairs,
and 10,000 pkts/sec memcached (UDP) packets.

## Set-up

### Topology

The tofino is connected to four servers, five FPGAs, and a loopback cable that extends from one core of the tofino into another.

The tofino laid out schematically is accessible here:
![Tofino Topology](tofino.png?raw=true "Tofino Topology")

### Moongen

One component is missing from this schematic: the collection server running Moongen.

The tofino is set up to place a timestamp in the src MAC address field of packets
which arrive or depart on a specific port (in this case, the memcached client port),
and forward the first 100 bytes of those packets to a machine running MoonGen, which
captures the packets to a pcap file.

### Packet generation

A random set of packets are generated for each test, using the script located in the
[MemcachedFPGATest](../../MemcachedFPGATest) directory of this repo.

The command used to generate the pcaps creates 500,000 packets --
450,000 get packets, 50,000 set packets.

Each get packet chooses one of 10,000 keys from a zipf distribution with an exponent of 1.

Set packets are chosen from a uniform distribution.

The cache is warmed up with the same keys as the GET packets in reverse order of popularity,
such that the most popular packets are still in the cache when the experiment starts.

The specific command used to generate the packets is:

```shell
python2 ../..//MemcachedFPGATest/generate_memcached.py
    --smac {mcd_client.mac} --sip {mcd_client.ip}
    --dmac {mcd_server.mac} --dip {mcd_server.ip}
    --out {mcd_pcap} --warmup-out {mcd_warmup_pcap}
    --n-get 450000  --n-set 50000
    --key-space 10000 --zipf 1.00
```

### Machine specifications

Due to a limitation of the FEC, some MAC addresses had to be changed. Also, some MAC addresses were hardcoded in the tofino. Here is a list of the machines that were used for each part of the experiment, their addresses, their roles, and their specifications.

* FPGA programmer
  * tclust2
  * Attached to the FPGAs, reprogramming them before each experiment
* Power monitor
  * tclust8
  * Attached to power monitors, gathering power utilization
* Memcached Client (tcpreplay)
  * tclust7
    * ip: 10.0.0.7
    * mac: 00:02:c9:3a:84:00 (MUST BE SET MANUALLY)
  * ens3 --> tofino:7
* Memcached Server
  * tclust4
    * ip: 10.0.0.4
    * mac: 7c:fe:90:1c:36:81
  * ens1f1 --> tofino:4
* Iperf Client
  * tclust1
    * ip: 10.0.0.1
    * mac: 24:8a:07:8f:eb:00 (MUST BE SET MANUALLY)
  * ens1f1 --> tofino:1
* Iperf Server
  * tclust2
    * ip: 10.0.0.2
    * mac: 24:8a:07:5b:15:35
  * ens1f1 --> tofino:2

### FPGAs

The three FPGAs are:

* KV cache
  * Tofino port 12/0
  * cable: `jsn-JTAG-SMT2NC-210308A46CBE`
* Encoder
  * Tofino port 12/1
  * cable: `jsn-JTAG-SMT2NC-210308A47676`
* Decoder
  * Tofino port 12/2
  * cable: `jsn-JTAG-SMT2NC-210308A5F0D3`
* Compressor
  * Tofino port 13/1
  * cable: `jsn-JTAG-SMT2NC-210308A4712F`
* Decompressor
  * Tofino port 13/2
  * cable: `jsn-JTAG-SMT2NC-210308A7A487`

## Test Execution
Tests were orchestrated from tclust6, though the orchestrator should not
make a difference as long as it has passwordless access to all other
necessary machines.

Tests are executed with Shremote, checked out [here](..) as a git submodule.

If the submodule is not checked out, initialize it with:
```shell
git submodule update --init
```

### Shremote Description
Documentation on Shremote config files is available [here](https://github.com/isaac-ped/Shremote).
The specific configs used for this experiment is documented below.

In brief, Shremote is a program which allows for the timed execution of commands over SSH.

The config file defines a list of programs that can be executed,
and then a list of instances of those programs which will
be started at specific times with specific parameters.

### Shremote Program Dependencies
The only dependency of shremote itself is `pyyaml`. Install with:
```shell
pip install pyyaml
```

### Shremote Config
For most of these experiments, shremote is run with the config:
[tofino_e2e_500k.yml](execution/cfgs/tofino_e2e_500k.yml)

**The config necessarily requires the following modification:**
In the section `ssh:`, change the username and the ssh key
to those that allow passwordless access to the machines
necessary to run the tests.

In the section `hosts:tofino:ssh`, there is an additional
ssh key referenced, which logs onto the tofino. Be sure
to change that as well.


### Shremote Config Dependencies
#### Files
The shremote config file makes requires a number of
specific directories, files, or repos outside of the scope of this repo.

Those are as follows, on the following machines:

* johnshack
  * This repository checked out at `~/dcomp/P4Boosters`
* tofino (158.130.4.218)
  * `~fpadmin/gits/TofinoP4Boosters`
    * Contains code to start and stop the dataplane
    * Should already be in place
* tclust7
  * `~/dcomp/MoonGen`
    * Contains the MoonGen repository
    * Should be cloned and compiled in this directory
  * `~/bin/tcpreplay`
    * A copy of the tcpreplay executable with appropriate permissions
    * See below for details

All other files will be copied over automatically

#### Programs
In addition to the files above:
* `memcached` should be installed on tclust4
* `iperf3` should be installed on tclust1 and tclust2
* `tcpreplay` should be installed on tclust7

#### SSH config
The current shremote config file also depends on hostnames being set
in `~/.ssh/config` to log on to all of the necessary machines.


If you have not already, append the following to `~/.ssh/config`

```shell
Host tofino
Hostname 158.130.4.218
IdentityFile ~/.ssh/YOUR_SSH_KEY

Host tclust*
IdentityFile ~/.ssh/YOUR_SSH_KEY

Host tclust1
Hostname 158.130.4.231
Host tclust2
Hostname 158.130.4.232
Host tclust4
Hostname 158.130.4.234
Host tclust5
Hostname 158.130.4.235
Host tclust7
Hostname 158.130.4.237

# Adding other tclusts is nice too, for getting around more quickly
```

The config file can also be changed to replace the hostnames
provided in `hosts:` with IP addresses.

### Shremote Privileges

There is one important point for these particular experiments:

**NB: SHREMOTE CANNOT EXECUTE COMMANDS THAT REQUIRE SUDO PRIVILEGES**

To allow the experiments to be run in an automated fashion, the [setuid bit](https://en.wikipedia.org/wiki/Setuid) must be enabled on executables that require sudo. For the sake of these experiments, those programs are `MoonGen` and `tcpreplay`.

As MoonGen is checked out locally, you can change the permissions of the executable directly.

For tcpreplay, it is suggested you make a copy of the executable to avoid changing
permissions globally. Do so with:
```shell
mkdir ~/bin
cp `which tcpdump` ~/bin
```

The following set of commands will set the the setuid bit
on an arbitrary executable `my_exec`:
```shell
sudo chown root:$USER my_exec
sudo chmod gu+s,o-x my_exec # Set SUID for you, non-executable for others
```

Thus, to set the correct privelages on both files,
assuming MoonGen is checked out in `~/dcomp/MoonGen`,
and tcpdump has been copied to `~/bin`:

```shell
sudo chown root:$USER ~/dcomp/Moongen/build/MoonGen ~/bin/tcpdump
sudo chmod gu+s,o-x ~/dcomp/Moongen/build/MoonGen ~/bin/tcpdump
```
### Running

The Shremote configuration requires two command line arguments `drop_rate` and `dataplane_flags`. `Drop_rate` specifies the rate at which packets over the loopback are dropped, `dataplane_flags` should be some combination of `-f -h -k` for FEC encoding/decoding, header compression, and key-value store, respectively.

Thus, a command that runs the config, and outputs a test labeled `test_label` to the directory `test_output`, drops no packets, and enables header compression, would be:

```shell
cd execution
python ../../Shremote/shremote.py \
    cfgs/tc7_e2e_iperf_and_mcd.yml test_label \
    --out "test_output" \
    --args "drop_rate:0;dataplane_flags:-c"
```

The full set of end-to-end experiments, containing
five repetitions of each experiment,
can be run with the `run_all_e2e.sh` script:

```shell
cd execution && bash run_all_e2e.sh 1
```

Where the `1` is a label that will be appended to all labels.

The experiments can also be run using the arista rather than the tofino,
with the CPU as header compressor, or with the FPGA as header compressor,
using the respective scripts:

```shell
run_all_arista_e2e.sh
run_all_cpu_hc_e2e.sh
run_all_fpga_hc_e2e.sh
```
