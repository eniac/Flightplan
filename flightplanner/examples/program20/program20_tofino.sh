#!/bin/bash
#Nik Sultana, UPenn, August 2020
set -e

./flightplanner \
  ${FP_TEST_PARAMS} \
  --focus tofino1 \
  --planner_config_json planner_config.json \
  --devices_json examples/devices.json \
  --network_json examples/network_tofino.json \
  --performance_json examples/performance_tclust.json \
  --program_json examples/program20/program20.json
