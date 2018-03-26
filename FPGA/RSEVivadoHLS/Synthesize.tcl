############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
open_project RSEVivadoHLS
set_top RSE_core
add_files ../Configuration.h
add_files ../Encoder.c -cflags "-std=c99 -I ../../RSEConfig -I ../../../RSECode"
add_files ../Encoder.h
add_files ../RSECore.c -cflags "-std=c99 -I ../../RSEConfig -I ../../../RSECode"
add_files ../../../RSECode/rse.h
open_solution "solution1"
set_part {xczu9eg-ffvb1156-1-i-es1} -tool vivado
create_clock -period 3 -name default
csynth_design

