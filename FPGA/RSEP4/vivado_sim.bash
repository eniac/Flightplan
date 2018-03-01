#!/bin/bash
[ -z "$XILINX_VIVADO" ] && echo "Please set the XILINX_VIVADO environment variable." && exit 1

PATH=${XILINX_VIVADO}/bin:${XILINX_VIVADO}/tps/lnx64/gcc-6.2.0/bin:${XILINX_VIVADO}/tps/lnx64/binutils-2.26/bin:$PATH 

# Clean up any old files 
rm -rf xsim.dir

set -euo pipefail
set -x
find -name "*.v" -o -name "*.vp" -o -name "*.sv" | { xargs -I % ${XILINX_VIVADO}/bin/xvlog -sv % || true; } 
find -name "*.vhd" | { xargs -I % ${XILINX_VIVADO}/bin/xvhdl % || true; }
mkdir -p xsim.dir/xsc
find -name "*.c" | xargs ${XILINX_VIVADO}/bin/xsc -mt off -v 1
LIBRARY_PATH=/usr/lib/x86_64-linux-gnu g++ -c -fPIC -I ../../../RSEConfig -o xsim.dir/xsc/rse.o fec_0_t.TB/rse.cpp
g++ -std=gnu++11 -c -m64 -Wa,-W -fPIC ./XilinxSwitch.TB/XilinxSwitch.cpp -o xsim.dir/xsc/XilinxSwitch.o -I./XilinxSwitch.TB/ -I./Parser_t.TB/ -I./Forward_lvl_t.TB/ -I./Forward_lvl_0_t.TB/ -I./loop_0_t.TB/ -I./Forward_lvl_1_t.TB/ -I./fec_0_t.TB/ -I./Forward_lvl_2_t.TB/ -I./Deparser_t.TB/ -I ../../../RSEConfig -D__USE_XOPEN2K8 -DHAVE_DECL_BASENAME=1 
g++ -std=gnu++11 -c -m64 -Wa,-W -fPIC ./XilinxSwitch.TB/sdnet_lib.cpp -o xsim.dir/xsc/sdnet_lib.o -I./XilinxSwitch.TB/ -I./Parser_t.TB/ -I./Forward_lvl_t.TB/ -I./Forward_lvl_0_t.TB/ -I./loop_0_t.TB/ -I./Forward_lvl_1_t.TB/ -I./fec_0_t.TB/ -I./Forward_lvl_2_t.TB/ -I./Deparser_t.TB/  -D__USE_XOPEN2K8 -DHAVE_DECL_BASENAME=1 
LIBRARY_PATH=/usr/lib/x86_64-linux-gnu g++ -std=gnu++11 -Wa,-W  -O -fPIC  -m64  -shared  -o xsim.dir/xsc/dpi.so xsim.dir/xsc/*.o ${XILINX_VIVADO}/lib/lnx64.o/librdi_simulator_kernel.so -D__USE_XOPEN2K8 -DHAVE_DECL_BASENAME=1 
${XILINX_VIVADO}/bin/xelab -L work --debug all -sv_lib dpi.so XilinxSwitch_tb  
${XILINX_VIVADO}/bin/xsim --runall XilinxSwitch_tb    
