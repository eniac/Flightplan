All: Encoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet Packet.user Tuple.user fec_0_t.hpp rse.cpp rse.h loop_0_t.hpp fec_0_t.v loop_0_t.v vivado_sim.bash vivado_sim_waveform.bash
	sdnet Encoder.sdnet -skipEval -busType axi -busWidth 64 -UE -clk_line -workDir Encoder
	@cp Packet.user Tuple.user Encoder/XilinxSwitch
	@cp fec_0_t.hpp rse.cpp rse.h Encoder/XilinxSwitch/fec_0_t.TB
	@cp loop_0_t.hpp Encoder/XilinxSwitch/loop_0_t.TB
	@cp fec_0_t.v Encoder/XilinxSwitch/fec_0_t.HDL
	@cp loop_0_t.v Encoder/XilinxSwitch/loop_0_t.HDL
# Fix backpressure.
	@sed -ie 's/\(~(backpressure_in)\)/\1 \& packet_out_PACKET6_RDY/' Encoder/XilinxSwitch/S_SYNCERs.HDL/S_SYNCER_for_fec_0.v
# Fix timing bug in testbench.
	@cp TB_System_Stim.v Encoder/XilinxSwitch/Testbench
	@cp ../RSEVivadoHLS/solution1/syn/vhdl/*.vhd Encoder/XilinxSwitch/fec_0_t.HDL
	@cp vivado_sim*.bash Encoder/XilinxSwitch
# Set the correct target FPGA.
	@sed -ie 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' Encoder/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

Encoder.sdnet: encoder.p4
	p4c-sdnet encoder.p4 -o Encoder.sdnet
	./sdnet_patch.sh

clean:
	rm -fr Encoder.sdnet Encoder

