open_project MemcachedVivadoHLS
set_top Decompressor
add_files ../Decompressor.h
add_files ../Decompressor.cpp
open_solution "solution2"
set_part {xczu9eg-ffvb1156-1-i-es1} -tool vivado
create_clock -period 6.4 -name default
config_rtl -disable_start_propagation
csynth_design

