#!/bin/bash -e
FILES=""

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

