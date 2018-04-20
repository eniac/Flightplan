#!/bin/bash -e
FILES="Encoder/XilinxSwitch/vivado_sim.bash \
       Encoder/XilinxSwitch/vivado_sim_waveform.bash \
       Encoder/XilinxSwitch/XilinxSwitch.TB/compile.bash \
       Encoder/XilinxSwitch/Testbench/XilinxSwitch_tb.sv \
       Encoder/XilinxSwitch/Testbench/TB_System_Stim.v \
       Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.hpp \
       Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.cpp \
       Encoder/XilinxSwitch/XilinxSwitch_vivado_packager.tcl"

function Restore_encoder
{
  rm -fr Encoder.sdnet.original Encoder.original
}

trap Restore_encoder EXIT

diff -u Encoder.sdnet.original Encoder.sdnet > Patches/Encoder.sdnet.patch || true

for FILE in $FILES
do
  echo $FILE
  ORIGINAL=${FILE/Encoder/Encoder.original}
  diff -u $ORIGINAL $FILE || true
done > Patches/Encoder.patch

TEMP_FILE=$(mktemp)
Scripts/Remove_date.pl > $TEMP_FILE
mv $TEMP_FILE Patches/Encoder.patch

