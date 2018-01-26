All: RSE/XilinxSwitch/XilinxSwitch_vivado

RSE/XilinxSwitch/XilinxSwitch_vivado: RSE
	cd $(realpath RSE/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

RSE: RSE.sdnet
	sdnet RSE.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir RSE
	@cp fec_0_t.v RSE/XilinxSwitch/fec_0_t.HDL
	@mkdir -p RSE/XilinxSwitch/RSECore
	@cp ../RSEVivadoHLS/solution1/syn/vhdl/*.vhd RSE/XilinxSwitch/RSECore
	@sed -ie 's:\(mkdir -p xsim.dir/xsc\):find -name "*.vhd" | { xargs -I % ${XILINX_VIVADO}/bin/xvhdl % || true; }\n\1:' RSE/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(mkdir -p xsim.dir/xsc\):find -name "*.vhd" | { xargs -I % ${XILINX_VIVADO}/bin/xvhdl % || true; }\n\1:' RSE/XilinxSwitch/vivado_sim_waveform.bash
# Deal with issue that crti.o cannot be found during linking phase of simulation.
	@sed -ie 's:\(g++ -std=gnu++11 -Wa,-W\):LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \1:' RSE/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(g++ -std=gnu++11 -m64\):LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \1:' RSE/XilinxSwitch/vivado_sim_waveform.bash
# Add warning that XILINX_VIVADO environment variable has to be set before simulation.
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' RSE/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' RSE/XilinxSwitch/vivado_sim_waveform.bash
# Set the correct target FPGA.
	@sed -ie 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' RSE/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

RSE.sdnet: RSE.p4
	p4c-sdnet RSE.p4 -o RSE.sdnet

clean:
	rm -fr RSE.sdnet RSE

