############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
open_project MemcachedHLS
set_top Memcore
add_files MemHLS.cpp
add_files MemHLS.h
open_solution "solution2"
set_part {xczu9eg-ffvb1156-1-i-es1} -tool vivado
create_clock -period 6.4 -name default
#source "./MemcachedHLS/solution2/directives.tcl"
#csim_design -compiler gcc
csynth_design
#cosim_design
export_design -format ip_catalog
