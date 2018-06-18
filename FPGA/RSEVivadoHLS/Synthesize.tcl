open_project RSEVivadoHLS
set_top RSE_core
add_files ../Configuration.h
add_files ../Encoder.c -cflags "-std=c99"
add_files ../Encoder.h
add_files ../RSECore.c -cflags "-std=c99"
add_files ../rse.h
open_solution "solution1"
set_part {xczu9eg-ffvb1156-1-i-es1} -tool vivado
create_clock -period 6.4 -name default
csynth_design

