# Flightplan
Our [project](https://flightplan.cis.upenn.edu/) develops a tool-chain for the flexible decomposition of P4 programs and their allocation to heterogeneous hardware to improve performance, reliability and utilisation of software-defined networks.

## Using the repo
To understand what the various things below do, or see their output, look at the
[Flightplan paper](https://flightplan.cis.upenn.edu/flightplan.pdf).

There are several things you can get out of the repo:
- [Analyser+transformer](flightplan) for P4 code with segment annotations, from which disaggregated programs are derived.
- [Flightplanner](flightplanner) produces execution plans for disaggregated P4 programs.
- Examples of [segment annotation usage](https://github.com/eniac/Flightplan/blob/master/Wharf/Sources/ALV.p4#L92), [analysis tool invocation](https://github.com/eniac/Flightplan/blob/master/flightplan/analyser_scripts/run_everything.sh#L5) and [output](https://github.com/eniac/Flightplan/blob/master/flightplan/analyser_scripts/flightplan_output/program3.json), which are fed to the planner which reasons about the disaggregated dataplane program to produce (among other things) [allocations](https://github.com/eniac/Flightplan/blob/master/flightplanner/results/greedy/program20/program20_tofino.stdout#L12) of segments to devices on the network.
- various new [P4 programs](Wharf/Sources/), including [Crosspod](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_Complete/ALV_Complete.p4#L117) that invokes our network boosters.
- network boosters: [FEC](https://flightplan.cis.upenn.edu/netcompute2018.pdf), memcached, header compression, running on [CPU](cpuBoosters) or [FPGA](FPGA).
- Flightplan [Full](Wharf/Sources/FPRuntime.p4) runtime for running disaggregated programs, the associated [fpctl](https://github.com/eniac/Flightplan/blob/master/Wharf/fpctl.py) control program, and [usage examples](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_split1/step2.sh).
- a fairly mature [simulation system and our simulated experiments](Wharf) including that for [Fig7](splits2/ALV_Complete_All/) in the paper.
- a fat-tree topology and configuration [generator](Wharf/generate_alv_network.py). See example output for [k=4](Wharf/bmv2/topologies/alv_k\=4.yml).
- our testbed experiment methodology, automation, and/or data.
[1](testing/README.md), [2](testing_docs).
Contact us if raw data is needed, it's big.
- the power measurement [method](power_measurements/README.md) and [setup](power_measurements/wemo_instructions.md) used in our testbed experiments.

## License
[Apache 2.0](LICENSE)
