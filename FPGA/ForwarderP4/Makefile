All: Forwarder/XilinxSwitch/XilinxSwitch_vivado

Forwarder/XilinxSwitch/XilinxSwitch_vivado: Forwarder
	cd $(realpath Forwarder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Forwarder: Forwarder.sdnet
	sdnet Forwarder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Forwarder
	@cp Packet.user Forwarder/XilinxSwitch
# Deal with issue that crti.o cannot be found during linking phase of simulation.
	@sed -ie 's:\(g++ -std=gnu++11 -Wa,-W\):LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \1:' Forwarder/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(g++ -std=gnu++11 -m64\):LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \1:' Forwarder/XilinxSwitch/vivado_sim_waveform.bash
# Add warning that XILINX_VIVADO environment variable has to be set before simulation.
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' Forwarder/XilinxSwitch/vivado_sim.bash
	@sed -ie 's:\(#!/bin/bash\):\1\n[ -z "$$XILINX_VIVADO" ] \&\& echo "Please set the XILINX_VIVADO environment variable." \&\& exit 1:' Forwarder/XilinxSwitch/vivado_sim_waveform.bash
# Set the correct target FPGA.
	@sed -ie 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' Forwarder/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

Forwarder.sdnet: Forwarder.p4
	p4c-sdnet Forwarder.p4 -o Forwarder.sdnet

clean:
	rm -fr Forwarder.sdnet Forwarder

