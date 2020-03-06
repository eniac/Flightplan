#!/bin/bash -e
if [[ $SDSOC_ROOT=="" ]]; then
    export SDSOC_ROOT=/opt/Xilinx/SDx/2017.1
fi 
source "$SDSOC_ROOT/settings64.sh"

[ $# != 2 ] && echo "Usage: $0 <Project> <Cable ID>"

PROJECT=$1
CABLE_ID=$2

if [ $# == 0 ]
then
  echo
  echo "Retrieving valid cable IDs..."
  sdx -batch -source ./List_cables.tcl | tr ' ' '\n' |
    awk '{ if (OUTPUT == 1) print $1; OUTPUT = 0 } /jtag_cable_ctx/ { OUTPUT = 1 }' |
    uniq | sort | tr '\n' ' '
  exit
elif [ $# == 2 ]
then
  sdx -batch -source ./Run_project.tcl "$PWD" "$PROJECT" "$CABLE_ID"
fi

