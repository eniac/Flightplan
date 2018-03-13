.PHONY: All Simulation clean

All: Encoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet Packet.user Tuple.user Packet_feedback_in.axi \
         fec_0_t.hpp rse.cpp rse.h loop_0_t.hpp fec_0_t.v loop_0_t.v \
         vivado_sim.bash vivado_sim_waveform.bash \
         vivado_sim_feedback_waveform.bash XilinxSwitch_feedback_tb.sv
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Encoder
	@cp Packet.user Tuple.user Packet_feedback_in.axi Encoder/XilinxSwitch
	@cp fec_0_t.hpp rse.cpp rse.h Encoder/XilinxSwitch/fec_0_t.TB
	@cp loop_0_t.hpp Encoder/XilinxSwitch/loop_0_t.TB
	@cp fec_0_t.v Encoder/XilinxSwitch/fec_0_t.HDL
	@cp loop_0_t.v Encoder/XilinxSwitch/loop_0_t.HDL
	@mkdir -p Encoder/XilinxSwitch/Feedback
	@cp ../RSEFeedbackVivado/Sources/RSEFeedback.vhd Encoder/XilinxSwitch/Feedback
	@cp ../RSEFeedbackVivado/Sources/Config.vhd Encoder/XilinxSwitch/Feedback/Config.vhd
	@cp ../RSEFeedbackVivado/Sources/fifo_generator_0/sim/fifo_generator_0.v Encoder/XilinxSwitch/Feedback
	@cp XilinxSwitch_feedback_tb.sv TB_System_feedback_Stim.v Encoder/XilinxSwitch/Testbench
	@cp ../RSEVivadoHLS/Batch/RSEVivadoHLS/solution1/syn/vhdl/*.vhd Encoder/XilinxSwitch/fec_0_t.HDL
	@cp vivado_sim*.bash Encoder/XilinxSwitch
	@cp compile.bash Encoder/XilinxSwitch/XilinxSwitch.TB
# Convert configuration file to Verilog.
	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Encoder/XilinxSwitch/loop_0_t.HDL/Configuration.v
	@cp Encoder/XilinxSwitch/loop_0_t.HDL/Configuration.v Encoder/XilinxSwitch/fec_0_t.HDL/Configuration.v
# Fix backpressure.
	@sed -i 's/\(~(backpressure_in)\)/\1 \& packet_out_PACKET6_RDY/' Encoder/XilinxSwitch/S_SYNCERs.HDL/S_SYNCER_for_fec_0.v
# Fix timing bug in testbench.
	@cp TB_System_Stim.v Encoder/XilinxSwitch/Testbench
# Set the correct target FPGA.
	@sed -i 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' Encoder/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

Encoder.sdnet: encoder.p4
	p4c-sdnet -I ../RSEVivadoHLS encoder.p4 -o Encoder.sdnet
	./sdnet_patch.sh

clean:
	rm -fr Encoder.sdnet Encoder

