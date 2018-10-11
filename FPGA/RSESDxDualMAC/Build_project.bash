#!/bin/bash -e
rm -fr $PWD/RSESDx
source $SDSOC_ROOT/settings64.sh
sdx -batch -source ./Build_project.tcl $PWD

