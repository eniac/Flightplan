#!/bin/bash -e
# Tests the P4-generated module + integrated modules (including from HLS code) on ASCII AXI inputs using SDNet's interface.

if [ "RSEP4" != "$(basename `pwd`)" ]
then
  echo "Run this from the RSEP4 directory"
  exit 1
fi

cd Wharf/XilinxSwitch
./Generate_packets.sh
cd XilinxSwitch.TB
./compile.bash
cd ..
XilinxSwitch.TB/XilinxSwitch
./vivado_sim_waveform.bash
