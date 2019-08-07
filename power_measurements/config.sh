#!/bin/bash
# Nik Sultana, UPenn, July 2019

export MACs=( 94:10:3e:40:ac:15 14:91:82:b5:96:49 14:91:82:b5:82:f3 94:10:3e:3a:3d:69 94:10:3E:39:A7:25 94:10:3E:39:EC:21 14:91:82:B5:93:39 94:10:3E:3A:24:4D )
export RANGE="$(seq 0 $(( ${#MACs[@]} - 1 )) )"
export NAME=( fpga12/1 dcomp1 tofino tclust2 tclust4 fpga12/2 fpga13/0 fpga13/1 )
export PORT=( 49154 49154 49154 49153 49154 49153 49154 49153 )
