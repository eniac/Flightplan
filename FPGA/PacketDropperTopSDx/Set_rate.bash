#!/bin/bash -e
if [ $# == 0 ]
then
  echo "Usage: $0 <Error rate> <Cable ID>"
  exit
fi

if [[ $(bc -l <<< "$1 >= 0 && $1 <= 1") -ne 1 ]]
then
  echo "The error rate must be in the interval [0, 1]." >&2
  exit 1
fi

if [ -z "$DISPLAY" ]
then
  echo "Despite running SDx in batch mode, you have to set the DISPLAY environment variable."
  exit 1
fi

mkdir -p Sources
sed "s/RATE/$1/" Dropper_init_template.c > Sources/Dropper_init.c
source $SDSOC_ROOT/settings64.sh
sdx -batch -source ./Recompile_software.tcl $PWD "$2"

#./Run_project.bash $2

