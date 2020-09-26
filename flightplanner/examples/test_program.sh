#!/bin/bash
#Nik Sultana, UPenn, August 2020
#
# NOTE when using this script, --focus parameter should appear in examples/network_tofino.json
set -e

FP_TEST_FOCUS=$1

CMD="command time ./flightplanner \
  ${FP_TEST_PARAMS} \
  --focus ${FP_TEST_FOCUS} \
  --planner_config_json planner_config.json \
  --devices_json examples/devices.json \
  --network_json examples/network_tofino.json \
  --performance_json examples/performance_tclust.json \
  --program_json ${FP_TEST_PROG}"

eval ${CMD} | tee "${FP_TEST_PROG}_stdout" 2> "${FP_TEST_PROG}_stderr"
exit ${PIPESTATUS[0]}
