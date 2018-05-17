#!/bin/bash -e
FILES="Wharf/XilinxSwitch/vivado_sim.bash \
       Wharf/XilinxSwitch/vivado_sim_waveform.bash \
       Wharf/XilinxSwitch/XilinxSwitch.TB/compile.bash \
       Wharf/XilinxSwitch/Testbench/XilinxSwitch_tb.sv \
       Wharf/XilinxSwitch/Testbench/TB_System_Stim.v \
       Wharf/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.hpp \
       Wharf/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.cpp \
       Wharf/XilinxSwitch/XilinxSwitch_vivado_packager.tcl"

function Restore_encoder
{
  rm -fr Wharf.sdnet.original Wharf.original
}

trap Restore_encoder EXIT

diff -u Wharf.sdnet.original Wharf.sdnet > Patches/Encoder.sdnet.patch || true

for FILE in $FILES
do
  echo $FILE
  ORIGINAL=${FILE/Wharf/Wharf.original}
  diff -u $ORIGINAL $FILE || true
done > Patches/Encoder.patch

TEMP_FILE=$(mktemp)
Scripts/Remove_date.pl > $TEMP_FILE
mv $TEMP_FILE Patches/Encoder.patch

