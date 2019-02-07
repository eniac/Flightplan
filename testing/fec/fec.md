# FEC Testing documentation

FEC testing depends on the same tofino setup as in the end-to-end tests.
View [e2e.md](../e2e/e2e.md) for more information on the tofino and topology.

The sections that are different here are [Shremote Config](#Shremote-Config) and [Running](#Running)

## Set-up

### Topology
View [Topology](../e2e/e2e.md#Topology) section of e2e.md.
Only iperf3 client and server (tclust1 and tclust2) are necessary.

### Machine Specifications
View [Machine Specifications](../e2e/e2e.md#Machine-Specifications) section of e2e.md.
Only Iperf client and Iperf server are necessary.


### FPGAs
View [FPGAS](../e2e/e2e.md#FPGAs) section of e2e.md.
Only encoder and decoder are necessary

## Test Execution
View [Test Execution](../e2e/e2e.md#Test-Execution) section of e2e.md

### Shremote
View [Shremote Description](../e2e/e2e.md#Shremote-Description), and
[Shremote Program Dependencies](../e2e/e2e.md#Shremote-Program-Dependencies)

### Shremote Config
For these experiments, shremote is run with the config:
[iperf.yml.yml](execution/cfgs/iperf.yml).

This configuration file uses the scripts to [start](execution/start_iperf_servers.sh)
and [stop](execution/stop_iperf_servers.sh) N iperf servers and clients necessary for
the experiment.

These scripts are copied to the target machines automatically.

Final experiments were run with N=10 clients & servers.

**The config necessarily requires the following modification:**
In the section `ssh:`, change the username and the ssh key
to those that allow passwordless access to the machines
necessary to run the tests.

In the section `hosts:tofino:ssh`, there is an additional
ssh key referenced, which logs onto the tofino. Be sure
to change that as well.

### Shremote Config Dependencies
View [Shremote Config Dependencies](../e2e/e2e.md#Shremote-Config-Dependencies),
only the following are necessary:
* files: johnshack, tofino
* programs: iperf3
* ssh config: tofino, johnshack, tclust1, tclust2


### Shremote Privileges
No special privileges are required for Shremote to run.

### Running

The Shremote configuration requires two command line arguments `drop_rate` and `dataplane_flags`. `Drop_rate` specifies the rate at which packets over the loopback are dropped, `dataplane_flags` should be some combination of `-f` for FEC encoding/decoding, or empty for no FEC.

An example command that sets up 5% drop rate with FEC enabled is:

```shell
cd execution
python ../../Shremote/shremote.py
    cfgs/tc7_e2e_iperf_and_mcd.yml test_label \
    --out "test_output"\
    --args "drop_rate:0.05;dataplane_flags:-f"
```

The bash script [run_iperf.sh](execution/run_iperf.sh)
experiments using each of the following rates 10 times:
```
0 0.0001 0.001 0.01 0.02 0.03 0.04 0.05 0.1
```
with and without FEC.

Run `bash run_iperf.sh` to record to the folder `iperf_output`,
or change the script to record elsewhere.
