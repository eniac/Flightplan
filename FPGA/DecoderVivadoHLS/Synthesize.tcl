open_project DecoderVivadoHLS
set_top Decode
add_files ../Configuration.h
add_files ../Decoder.cpp
add_files ../Decoder.h
open_solution "solution1"
set_part {xczu9eg-ffvb1156-1-i-es1} -tool vivado
create_clock -period 6.4 -name default
csynth_design

