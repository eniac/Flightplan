#!/bin/bash -e
FILES="Decoder/XilinxSwitch/vivado_sim.bash \
       Decoder/XilinxSwitch/XilinxSwitch.TB/compile.bash \
       Decoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.hpp \
       Decoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.cpp"

function Restore_decoder
{
  rm -fr Decoder.sdnet.original Decoder.original
}

trap Restore_decoder EXIT

diff -u Decoder.sdnet.original Decoder.sdnet > Patches/Decoder.sdnet.patch || true

for FILE in $FILES
do
  echo $FILE
  ORIGINAL=${FILE/Decoder/Decoder.original}
  diff -u $ORIGINAL $FILE || true
done > Patches/Decoder.patch

TEMP_FILE=$(mktemp)
Scripts/Remove_date.pl > $TEMP_FILE
mv $TEMP_FILE Patches/Decoder.patch

