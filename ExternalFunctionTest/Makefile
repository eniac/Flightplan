All: Test

Test: Test.sdnet
	sdnet Test.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Test
	@cp change_addr_0_t.v Test/XilinxSwitch/change_addr_0_t.HDL
	@cp change_addr_0_t.hpp Test/XilinxSwitch/change_addr_0_t.TB
	@cp Packet.user Test/XilinxSwitch
# Deal with issue that crti.o cannot be found during linking phase of simulation.
	@sed -ie 's:\(g++ -std=gnu++11 -Wa,-W\):LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \1:' Test/XilinxSwitch/vivado_sim.bash
# Add warning that XILINX_VIVADO environment variable has to be set before simulation.
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' Test/XilinxSwitch/vivado_sim.bash
# Set the correct target FPGA.
	@sed -ie 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' Test/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

Test.sdnet: Test.p4
	p4c-sdnet Test.p4 -o Test.sdnet

clean:
	rm -fr Test.sdnet Test

