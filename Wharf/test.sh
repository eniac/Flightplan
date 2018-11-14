#!/bin/bash
# Syntax-checks our example P4 program
P4TEST=~/p4c/build/p4test
$P4TEST -DTARGET_BMV2 -I ~/P4B/P4Boosters/FPGA/RSEConfig/ -I ~/Xilinx/SDNet/2017.4/data/p4include/ -I bmv2_p4/Sources/ -I ~/P4B/P4Boosters/FPGA/MemcachedP4/ Example.p4
