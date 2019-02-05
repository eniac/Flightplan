# E2E testing documentation

E2E testing using the three FPGAs connected to the tofino
consists of five experiments:

* Baseline
* `+ Header Compression`
* `+ 5% drop rate`
* `+ FEC`
* `+ KV cache`

## Set-up

### Topology

The tofino is connected to four servers, three FPGAs, and a loopback cable that extends from onecore of the tofino into another.

The tofino laid out schematically is accessible here:
![Tofino Topology](tofino.png?raw=true "Tofino Topology")

### Moongen

One component is missing from this schematic: the contribution of MoonGen.

In reality, the Memcached Client is made up of two machines -- one which is running tcpreplay, sending packets to MoonGen, and then MoonGen itself, which captures the packets and forwards them to the tofino. Moongen also captures the packets received from the tofino.

### Packet generation

Generate packets using the following command:
```
python2 /home/iped/dcomp/P4Boosters/MemPacket/generate_safer_memcached.py --out ./200k_tc7_get_pkts.pcap --hashlog 200k_tc7_pktlog.json --smac 00:02:c9:3a:84:00 --sip 10.0.0.7 --dmac 7c:fe:90:1c:36:81 --dip 10.0.0.4 --n-get 200000 --n-set 10000 --collision-prob .1 --get-pct .95 --pre-set --set-out ./200k_tc7_set_pkts.pcap
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
    * Potentially has to be set in arp on memcached server
    * Mac address should be used for generation of packets
* Memcached Server
  * tclust4
  * Attached via ens1f1 to tofino:4
  * ip: 10.0.0.4
  * mac: 7c:fe:90:1c:36:81
    * Mac address should be used for generation of packets
  * May have to set arp with `arp -s 10.0.0.7 00:02:c9:3a:84:00 --dev ens1f1` but not sure if this in mandatory
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

Tests are executed with Shremote, checked out here as a git submodule.

### Config

The shremote config file `tc7_e2e_iperf_and_mcd.yml` makes reference to `200k_tc7_get_pkts.pcap` and `200k_tc7_set_pkts.pcap`, but should have no other local dependencies.

The config file also depends on a built version of MoonGen living on tclust7 at `~/dcomp/MoonGen`.

The config file accepts two command line arguments, `drop_rate` and `dataplane_flags`. `Drop_rate` specifies the rate at which packets over the loopback are dropped, `dataplane_flags` should be some combination of `-f -h -k` for FEC encoding/decoding, header compression, and key-value store, respectively.

### Running

The run script, `run_tc7.sh` should be able to be run to get a fresh run of the data. Data is by default output to `tc7_output/` but that may be changed in `run_tc7.sh`
