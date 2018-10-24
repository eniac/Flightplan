#!/bin/bash -e
if [ -z "$DISPLAY" ]
then
  echo "Despite running SDx in batch mode, you have to set the DISPLAY environment variable."
  exit 1
fi

rm -fr $PWD/RSESDx
source $SDSOC_ROOT/settings64.sh
sdx -batch -source ./Build_project.tcl $PWD

