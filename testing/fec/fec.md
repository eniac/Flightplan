# FEC Testing documentation

FEC testing depends on the e2e setup.
View [e2e.md](../e2e/e2e.md) for more information on the tofino and topology.

## Test Execution
Tests are executed with Shremote, checked out here as a git submodule.

### Config

The shremote config file `iperf.yml` makes reference to local files `start_iperf_servers.sh`
and `start_iperf_clients.sh` which start the N iperf servers and clients necessary for the experiment.

The final experiments were run with 10 clients + servers.

The config file also depends on a file located at:
`~/P4Boosters/FPGA/TopLevelSDx/program_all.sh` which programs the encoder and decoder
FPGAs in parallel.

The config file accepts two command line arguments, `drop_rate` and `dataplane_flags`. `Drop_rate` specifies the rate at which packets over the loopback are dropped, `dataplane_flags` should be some combination of `-f` for FEC encoding/decoding.
### Running

The run script, `run_iperf.sh`, runs experiments at rates of:
`0 0.0001 0.001 0.01 0.02 0.03 0.04 0.05 0.1`
with FEC And without FEC.

Each experiment is repeated 10 times.

Run with `bash run_iperf.sh` to record to the folder `iperf_output`, or change
the script to record to somewhere else.
