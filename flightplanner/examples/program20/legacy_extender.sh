#!/bin/bash
set -e

FP_TEST_PARAMS="--initial_state Data::Bound::InputRate=2000000000" ./examples/program20/program20_arista.sh > examples/program20/legacy_extender/stdout
mv output.csv output.max examples/program20/legacy_extender
