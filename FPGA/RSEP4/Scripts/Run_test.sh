#!/bin/bash -e
# Tests the P4-generated module + integrated modules (including from HLS code) on ASCII AXI inputs using SDNet's interface.

if [ "RSEP4" != "$(basename `pwd`)" ]
then
  echo "Run this from the RSEP4 directory"
  exit 1
fi

PROJECT_DIR=$1
if [ -z "${PROJECT_DIR}" ]
then
  PROJECT_DIR="Encoder"
  echo "No project directory given, defaulting to ${PROJECT_DIR}/"
fi

cd ${PROJECT_DIR}/XilinxSwitch
./Generate_packets.sh
cd XilinxSwitch.TB
./compile.bash
cd ..
XilinxSwitch.TB/XilinxSwitch
./vivado_sim.bash
