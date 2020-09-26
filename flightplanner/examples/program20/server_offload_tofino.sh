#!/bin/bash
set -e

FP_TEST_PARAMS="--initial_state Data::Bound::InputRate=20000000 --exclude_device fpga1 --exclude_device fpga2 --exclude_device fpga3 --exclude_device fpga4 --exclude_device fpga5" ./examples/program20/program20_tofino.sh > examples/program20/server_offload/stdout_tofino
mv output.csv examples/program20/server_offload/output.csv_tofino
mv output.max examples/program20/server_offload/output.max_tofino
