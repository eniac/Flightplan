# Examples

## ALV
This example shows two disaggregations of the look-up
sequence. Both these disaggregations only work on
the Full runtime, for different reasons: the first
because it attempts to update special state during
the offload, and the second because it requires
transferring context.

## ALV_FW
This example shows a disaggregation that works for
both the Full and HL runtimes: it splits off the
routing part of the program from the stateful firewall.

## basic_tunnel
In this example the tunneled traffic gets processed
off-switch by offloading the related table.
The disaggregated variant of this example only works on
the Full runtime.

## qos
In this example we offload the processing of two types of
traffic. This processing consists of a small header
transformation as well as routing. Routing of remaining
traffic stays on the switch.
The disaggregated variant of this example only works on
the Full runtime.

## Crosspod
This example implements the use-case described in
section 2 of the Flightplan paper, offloading
various functions from the larger program.
Different approaches to implement this are show-cased
in the repo, and this example uses that variation to
compare the two runtimes.

# Running the tools
The simplest is to run the following script:
```
./run_everything.sh
```
Reading the script will show how to invoke specific
examples.

You can also send extra parameters to the Flightplan
tools as shown below to emit JSON output:
```
./Crosspod_test.sh -v 1 -s 1 -r HL -p "--flightplan_emit_JSON program.json"
```

# Automated splitting
To use this mode give Flightplan the `--flightplan_mode split` parameter
(e.g., replacing the `--flightplan_mode analyse` parameter in
[run_v2.sh](run_v2.sh)), and the suitable value for `--flightplan_focus_block`.
For an example of the latter, add `--flightplan_focus_block Process` to
`MORE_PARAMS` in [ALV_test.sh](ALV_test.sh).
