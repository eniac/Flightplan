All: RSE/XilinxSwitch/XilinxSwitch_vivado

Simulation: RSE

RSE/XilinxSwitch/XilinxSwitch_vivado: RSE
	cd $(realpath RSE/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

RSE: RSE.sdnet Packet.user Tuple.user fec_0_t.hpp rse.cpp rse.h loop_0_t.hpp fec_0_t.v loop_0_t.v vivado_sim.bash vivado_sim_waveform.bash
	sdnet RSE.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir RSE
	@cp Packet.user Tuple.user RSE/XilinxSwitch
	@cp fec_0_t.hpp rse.cpp rse.h RSE/XilinxSwitch/fec_0_t.TB
	@cp loop_0_t.hpp RSE/XilinxSwitch/loop_0_t.TB
	@cp fec_0_t.v RSE/XilinxSwitch/fec_0_t.HDL
	@cp loop_0_t.v RSE/XilinxSwitch/loop_0_t.HDL
# Fix timing bug in testbench.
	@cp TB_System_Stim.v RSE/XilinxSwitch/XilinxSwitch.TB
	@cp ../RSEVivadoHLS/solution1/syn/vhdl/*.vhd RSE/XilinxSwitch/fec_0_t.HDL
	@cp vivado_sim*.bash RSE/XilinxSwitch
# Set the correct target FPGA.
	@sed -ie 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' RSE/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

RSE.sdnet: RSE.p4
	p4c-sdnet RSE.p4 -o RSE.sdnet

clean:
	rm -fr RSE.sdnet RSE

