#!/bin/bash -e
if [ -z "$DISPLAY" ]
then
  echo "Despite running SDx in batch mode, you have to set the DISPLAY environment variable."
  exit 1
fi

rm -fr $PWD/PacketDropperTopSDx
mkdir -p Sources
sed "s/RATE/0/" Dropper_init_template.c > Sources/Dropper_init.c
source $SDSOC_ROOT/settings64.sh
sdx -batch -source ./Build_project.tcl $PWD

