#!/bin/bash
#Nik Sultana, UPenn, August 2020
set -e

function test_prog {
  PROG=$1
  TARGET=$2
  echo "  ${PROG}"
  FP_TEST_PROG=examples/test_programs/${PROG} examples/test_program.sh ${TARGET} > /dev/null
}

echo "Testing with program[1-19]"
test_prog program1.json tofino1
test_prog program2.json tofino1
test_prog program3.json tofino1
test_prog program4.json tofino1
test_prog program5.json tofino1
test_prog program6.json tofino1
test_prog program7.json tofino1
test_prog program8.json tofino1
test_prog program9.json tofino1
test_prog program10.json tofino1
test_prog program11.json tofino1
test_prog program12.json tofino1
test_prog program13.json tofino1
test_prog program14.json tofino1
test_prog program15.json fpga1
test_prog program16.json tofino1
test_prog program17.json fpga1
test_prog program18.json fpga1
test_prog program19.json fpga1

echo "Testing with program20"
examples/program20/program20_arista.sh > examples/program20/program20_arista.stdout 2> examples/program20/program20_arista.stderr
examples/program20/program20_tofino.sh > examples/program20/program20_tofino.stdout 2> examples/program20/program20_tofino.stderr

echo "Generating fig7 inputs"
examples/program20/max_perf.sh > /dev/null
examples/program20/legacy_extender.sh > /dev/null
examples/program20/server_offload_tofino.sh > /dev/null
examples/program20/server_offload_arista.sh > /dev/null

echo "All OK"
