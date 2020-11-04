# Flightplan
Our [project](https://flightplan.cis.upenn.edu/) develops a tool-chain for the flexible decomposition of P4 programs and their allocation to heterogeneous hardware to improve performance, reliability and utilisation of software-defined networks.

## Using the repo
Look at the [Flightplan paper](https://flightplan.cis.upenn.edu/flightplan.pdf)
to better understand what the various things below do.

There are several things you can get out of this repo:
- The **Flightplan system**:
    <br /> <img src="https://flightplan.cis.upenn.edu/outline.png" height="150"/>
    - [Analyser+transformer](flightplan) for P4 code with segment annotations, from which disaggregated programs are derived.
    - The [Flightplanner](flightplanner) produces execution plans for disaggregated P4 programs.
    - Examples of [segment annotation usage](https://github.com/eniac/Flightplan/blob/master/Wharf/Sources/ALV.p4#L92), [analysis tool invocation](https://github.com/eniac/Flightplan/blob/master/flightplan/analyser_scripts/run_everything.sh#L5) and [output](https://github.com/eniac/Flightplan/blob/master/flightplan/analyser_scripts/flightplan_output/program3.json), which are fed to the planner. The planner about the disaggregated dataplane program to produce (among other things) [allocations](https://github.com/eniac/Flightplan/blob/master/flightplanner/results/greedy/program20/program20_tofino.stdout#L12) of segments to devices on the network.
    - Flightplan's [Full](Wharf/Sources/FPRuntime.p4) **runtime** for running disaggregated programs, the associated [fpctl](https://github.com/eniac/Flightplan/blob/master/Wharf/fpctl.py) **control program**, and [usage examples](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_split1/step2.sh).
- Network boosters: [FEC](https://flightplan.cis.upenn.edu/netcompute2018.pdf), memcached, header compression, running on [CPU](cpuBoosters) or [FPGA](FPGA).
- Various **new [P4 programs](Wharf/Sources/)**, including [Crosspod](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_Complete/ALV_Complete.p4#L117) that invokes our network boosters.
- Examples of applying Flightplan to **third-party P4 programs**, e.g., [basic_tunnel](Wharf/splits3/ALV_bt/).
- A fairly mature [simulation system and our simulated experiments](Wharf). Among other things, this was used to [simulate](splits2/ALV_Complete_All/) the setup shown in [Fig7](https://flightplan.cis.upenn.edu/flightplan.pdf#figure.caption.13) in the paper.
- A [fat-tree](Wharf/ALV/README.md) **topology and configuration [generator](Wharf/generate_alv_network.py)**. You can see example output for [k=4](Wharf/bmv2/topologies/alv_k\=4.yml) and its visualisation in [FDP](https://drive.google.com/file/d/149YrRqJxQ6aNmO6FqlRTm5p4N_QvQ-U6/view?usp=sharing).
<br /><a href="https://drive.google.com/file/d/149YrRqJxQ6aNmO6FqlRTm5p4N_QvQ-U6/view" target="_blank"><img src="https://www.seas.upenn.edu/~nsultana/fdp.png" alt="FDP video" height="200"/></a>
- Our **testbed experiment** methodology, automation, and/or data.
[1](testing/README.md), [2](testing_docs).
Contact us if raw data is needed, it's big.
- The **power measurement** [method](power_measurements/README.md) and [setup](power_measurements/wemo_instructions.md) used in our testbed experiments.

## License
[Apache 2.0](LICENSE)
