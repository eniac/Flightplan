# Flightplan
Our [project](https://flightplan.cis.upenn.edu/) develops a tool-chain for the flexible decomposition of P4 programs and their allocation to heterogeneous hardware to improve performance, reliability and utilisation of software-defined networks.

## Using the repo
To understand what the various things below do, or see their output, look at the
[Flightplan paper](https://flightplan.cis.upenn.edu/flightplan.pdf).

There are several things you can get out of the repo:
- our [planner](flightplanner)
- our P4 code [analysis+transformation](flightplan)
- Flightplan [Full](Wharf/Sources/FPRuntime.p4) runtime
- our simulation system, which provides FDP's back-end 
- our fat-tree topology [generator](Wharf/generate_alv_network.py). See example output for [k=4](Wharf/bmv2/topologies/alv_k\=4.yml).
- our boosters: FEC, memcached, header compression, running on [CPU](cpuBoosters) or [FPGA](FPGA)
- our [P4 programs](Wharf/Sources/)
- our testbed experiment methodology, automation, and/or data.
[1](testing/README.md), [2](testing_docs).
Contact us if raw data is needed, it's big.
- our [simulated experiments](Wharf) including for Fig7 in the paper.
- our [power measurement](power_measurements/README.md) [setup](power_measurements/wemo_instructions.md)

## License
[Apache 2.0](LICENSE)
