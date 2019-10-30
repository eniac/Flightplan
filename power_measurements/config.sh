#!/bin/bash
# Nik Sultana, UPenn, July 2019

export MACs=( 94:10:3e:3c:f4:e9 94:10:3e:3c:f4:11 94:10:3e:39:9c:35 94:10:3e:3a:3d:69 94:10:3e:3a:21:f9 94:10:3e:39:ec:21 14:91:82:B5:93:39 94:10:3E:3A:24:4D
94:10:3e:39:a7:25 94:10:3e:3c:d9:6d )
export RANGE="$(seq 0 $(( ${#MACs[@]} - 1 )) )"
export NAME=( fpga12/1 dcomp1 tofino tclust2 tclust4 fpga12/2 fpga13/0 fpga13/1 fpga12/0 arista )
export PORT=( 49153 49153 49153 49153 49153 49153 49154 49153 49153 49153 )
