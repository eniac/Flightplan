The Flightplanner is used to find allocations for disaggregated dataplane
programs in a network. The Flightplan paper describe its backgrounds and
motivations.

In addition to providing the tool's sources here, we describe its usage and
provide example inputs and outputs of its usage.


# Usage
To use the Flightplanner you need to have the input files that it'll use. Some
of this input is generated automatically by the Flightplan analyser, others are
hand-written but mostly reusable.

Steps to follow:
1. Write/adapt `planner_config.json`, `devices.json` and `network.json`.
2. Generate program.json using the Flightplan analyser.
3. Have the performance rules written down in CSV, as in `performance_tclust.csv`
4. Use `perf_rule.py`  to generate `perfomance.json` from the CSV.
5. Run the Flightplanner:
```
$ ./flightplanner --focus tofino1 --program_json program2.json --performance_json performance2.json --ctrl_prog_profile
```
Vary the parameters of the Flightplanner or the information in
`planner_config.json` to have the tool explore different plans for you.


# Parameters
The Flightplanner accepts a variety of inputs, which are described by the following command:
```
$ ./flightplanner --help
```
The contents of each input are described in the Flightplan paper, but the next section describes various examples which show the expected syntax.


# Examples
The input files, configuration and command-line arguments for several examples are provided in the `examples/` directory.
All of these examples are emitted by the Flightplan analyser through its tests in `run_everything.sh`, which in turn are based on new and third-party P4 program examples.

Most of these examples can be executed as follows:
```
$ FP_TEST_PROG=examples/test_programs/programX.json  examples/test_program.sh target
```
where `X` ranges from `1` to `19`, and `target` is `fpga1` for X={15,17,18} and `tofino1` for everything else.
You can run that set of tests using the `examples/test_all_programs.sh` script.
The original P4 programs that the `programX.json` files refer to can be determined by looking at `run_everything.sh`.

`program20.json` is a bit more special since it was featured more fully in the
evaluation section of the Flightplan paper, so we scripted its various
invocations to make it easier to reproduce the paper's results. The basic
invocation can be made as follows:
```
$ ./examples/program20/program20_arista.sh
$ ./examples/program20/program20_tofino.sh
```

Other invocations have been scripted-up as follows:
```
$ examples/program20/max_perf.sh
$ examples/program20/legacy_extender.sh
$ examples/program20/server_offload_tofino.sh
$ examples/program20/server_offload_arista.sh
```

Those scripts are used to generate the entries of [fig7output.csv](fig7output.csv),
in the order given above, which is rendered using [fig7output.R](fig7output.R).
This produces the diagram shown in Fig.9 in section 7.2.2 of the [Flightplan paper](https://flightplan.cis.upenn.edu/flightplan.pdf#subsubsection.7.2.2).
(The files references "fig7" because that was the figure's number in the then-current draft of the paper at the time the code was written.)


# Results
The `results` directory contains example outputs we obtained when running the
tool in greedy and non-greedy modes. It also contains indicative run-time
durations of the tool on each problem in the
[times_greedy](results/times_greedy) and
[times_nongreedy](results/times_nongreedy) files.
