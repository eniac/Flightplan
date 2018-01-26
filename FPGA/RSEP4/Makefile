All: RSE/XilinxSwitch/XilinxSwitch_vivado

RSE/XilinxSwitch/XilinxSwitch_vivado: RSE
	cd $(realpath RSE/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

RSE: RSE.sdnet fec_0_t.hpp rse.c rse.h loop_0_t.hpp fec_0_t.v loop_0_t.v
	sdnet RSE.sdnet -skipEval -busType axi -busWidth 64 -UE -clk_line -workDir RSE
	@cp Packet.user Tuple.user RSE/XilinxSwitch
	@cp fec_0_t.v RSE/XilinxSwitch/fec_0_t.HDL
	@cp loop_0_t.v RSE/XilinxSwitch/loop_0_t.HDL
	@cp ../RSEVivadoHLS/solution1/syn/vhdl/*.vhd RSE/XilinxSwitch/fec_0_t.HDL
	@sed -ie 's:\(mkdir -p xsim.dir/xsc\):find -name "*.vhd" | { xargs -I % ${XILINX_VIVADO}/bin/xvhdl % || true; }\n\1:' RSE/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(mkdir -p xsim.dir/xsc\):find -name "*.vhd" | { xargs -I % ${XILINX_VIVADO}/bin/xvhdl % || true; }\n\1:' RSE/XilinxSwitch/vivado_sim_waveform.bash
# Add warning that XILINX_VIVADO environment variable has to be set before simulation.
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' RSE/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' RSE/XilinxSwitch/vivado_sim_waveform.bash
# Set the correct target FPGA.
	@sed -ie 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' RSE/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

RSE.sdnet: RSE.p4
	p4c-sdnet RSE.p4 -o RSE.sdnet

clean:
	rm -fr RSE.sdnet RSE

