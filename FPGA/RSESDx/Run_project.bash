#!/bin/bash -e
source "$SDSOC_ROOT/settings64.sh"
if [ $# == 0 ]
then
  echo "Usage: $0 <Cable ID>"
  echo
  echo "Retrieving valid cable IDs..."
  sdx -batch -source ./List_cables.tcl | tr ' ' '\n' |
    awk '{ if (OUTPUT == 1) print $1; OUTPUT = 0 } /jtag_cable_ctx/ { OUTPUT = 1 }' |
    uniq | sort | tr '\n' ' '
  exit
fi
sdx -batch -source ./Run_project.tcl "$PWD" "$1"

