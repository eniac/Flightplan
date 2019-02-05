# E2E testing documentation

E2E testing using the three FPGAs connected to the tofino
consists of five experiments:

* Baseline
* `+ Header Compression`
* `+ 5% drop rate`
* `+ FEC`
* `+ KV cache`

The experiment traffic consists of 10 iperf (TCP) clients server pairs,
and 100,000 pkts/sec memcached (UDP) packets.

## Set-up

### Topology

The tofino is connected to four servers, three FPGAs, and a loopback cable that extends from onecore of the tofino into another.

The tofino laid out schematically is accessible here:
![Tofino Topology](tofino.png?raw=true "Tofino Topology")

### Moongen

One component is missing from this schematic: the contribution of MoonGen.

In reality, the Memcached Client is made up of two machines -- one which is running tcpreplay, sending packets to MoonGen, and then MoonGen itself, which captures the packets and forwards them to the tofino. Moongen also captures the packets received from the tofino.

For the SIGCOMM submission, MoonGen was run using revision: `ee8f575`

Shremote expects MoonGen to be cloned and compiled on `tclust7` in the directory: `~/dcomp/MoonGen`.

### Packet generation

The generated packets for the memcached testing have already been created, and are located
in this repo at `./execution/200k_tc7_get_pkts.pcap` and `./execution/200k_tc7_set_pkts.pcap`.

Packets have hardcoded IP addresses, MAC addresses, and collision rate.
If these parameters or the number of packets need to be changed, packet regeneration can be
rerun with the script located in the [MemPacket](../../MemPacket) directory of this repo.

The command that was used to generate the initial set of packets is:

```shell
python2 ../../MemPacket/generate_memcached.py \
            --out ./execution/200k_tc7_get_pkts.pcap \
            --hashlog ./execution/200k_tc7_pktlog.json \
            --smac 00:02:c9:3a:84:00 --sip 10.0.0.7 \
            --dmac 7c:fe:90:1c:36:81 --dip 10.0.0.4 \
            --n-get 200000 --n-set 10000 --collision-prob .1 \
            --pre-set --set-out ./execution/200k_tc7_set_pkts.pcap
```

### Machine specifications

Due to a limitation of the FEC, some MAC addresses had to be changed. Also, some MAC addresses were hardcoded in the tofino. Here is a list of the machines that were used for each part of the experiment, their addresses, their roles, and their specifications.

* Memcached Client (tcpdump)
  * tclust5
  * Attached via ens1f0 to tclust7:ens3
  * Sends `200k_tc7_set_pkts.pcap` followed by `200k_tc7_get_pkts.pcap` over ens1f0
* Memcached Client (moongen)
  * tclust7
  * Attached via ens3 to tclust7:ens1f0
  * Attached via ens3d1 to tofino:3
  * ip: 10.0.0.7
  * mac: 00:02:c9:3a:84:00
    * Mac address should be used for generation of packets
* Memcached Server
  * tclust4
  * Attached via ens1f1 to tofino:4
  * ip: 10.0.0.4
  * mac: 7c:fe:90:1c:36:81
    * Mac address should be used for generation of packets
  * _NOTE_: I had set ARP on the memcached server so that it knew which on device and MAC to send packets responding to the memcached client. This may not be necessary, but if packets are not making it back to the memcached client, you may try executing: `arp -s 10.0.0.7 00:02:c9:3a:84:00 --dev ens1f1`.
* Iperf client
  * tclust1
  * Attached via ens1f1 to tofino:1
  * ip: 10.0.0.1
  * mac: 24:8a:07:8f:eb:00
    * Must be set manually!
* Iperf server
  * tclust2
  * Attached via ens1f1 to tofino:2
  * ip: 10.0.0.2
  * mac: unchanged, not directly used

### FPGAs

The three FPGAs are:

* KV cache
  * Bottom
  * Power # 2
  * Tofino port 17/1
  * Johnshack cable: `jsn-JTAG-SMT2NC-210308A46CBE`
* Encoder
  * Middle
  * Power # 3
  * Tofino port 17/2
  * Johnshack cable: `jsn-JTAG-SMT2NC-210308A47676`
* Decoder
  * Top
  * Power # 4
  * Tofino port 17/3
  * Johnshack cable: `jsn-JTAG-SMT2NC-210308A5F0D3`


## Test Execution
Tests were orchestrated from tclust6, though the orchestrator should not
make a difference as long as it has passwordless access to all other
necessary machines.

Tests are executed with Shremote, checked out [here](../Shremote) as a git submodule.

If the submodule is not checked out, initialize it with:
```shell
git submodule init
git submodule update
```

### Shremote Description
Documentation on Shremote config files is available [here](https://github.com/isaac-ped/Shremote). The specific configs used for this experiment is documented below.

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
For these experiments, shremote is run with the config:
[tc7_e2e_iperf_and_mcd.yml](execution/cfgs/tc7_e2e_iperf_and_mcd.yml).

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
  * `~/P4Boosters/FPGA/TopLevelSDx/program_all.sh`
    * Programs all three FPGAs with the appropriate bitstreams
    * **TODO: ISAAC MUST ADD THIS FILE TO REPO**
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
* `tcpreplay` should be installed on tclust5

#### SSH config
The current shremote config file also depends on hostnames being set
in `~/.ssh/config` to log on to all of the necessary machines.


If you have not already, append the following to `~/.ssh/config`

```shell
# Adding identity files is nice for getting around,
# But not strictly necessary for shremote

Host tofino
Hostname 158.130.4.218
# IdentityFile ~/.ssh/YOUR_SSH_KEY

Host johnshack
Hostname johnshack.cis.upenn.edu
# IdentityFile ~/.ssh/YOUR_SSH_KEY

Host tclust*
# IdentityFile ~/.ssh/YOUR_SSH_KEY

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
can be run with the `run_tc7.sh` script:

```shell
cd execution && bash run_tc7.sh
```
