.PHONY: All Simulation clean

All: Encoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet Generate_packets.sh \
         fec_0_t.hpp rse.cpp rse.h fec_0_t.v \
         vivado_sim.bash vivado_sim_waveform.bash
	@rm -fr Encoder
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Encoder
	@ln -s ../../Generate_packets.sh Encoder/XilinxSwitch/Generate_packets.sh
	@ln -s ../../../fec_0_t.hpp Encoder/XilinxSwitch/fec_0_t.TB/fec_0_t.hpp
	@ln -s ../../../rse.cpp Encoder/XilinxSwitch/fec_0_t.TB/rse.cpp
	@ln -s ../../../rse.h Encoder/XilinxSwitch/fec_0_t.TB/rse.h
	@ln -sf ../../../XilinxSwitch.hpp Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.hpp
	@ln -sf ../../../XilinxSwitch.cpp Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch.cpp
	@ln -s ../../../fec_0_t.v Encoder/XilinxSwitch/fec_0_t.HDL/fec_0_t.v
	@cp ../RSEVivadoHLS/Batch/RSEVivadoHLS/solution1/syn/vhdl/*.vhd Encoder/XilinxSwitch/fec_0_t.HDL
	@ln -sf ../../vivado_sim.bash Encoder/XilinxSwitch/vivado_sim.bash
	@ln -sf ../../vivado_sim_waveform.bash Encoder/XilinxSwitch/vivado_sim_waveform.bash
	@ln -sf ../../../compile.bash Encoder/XilinxSwitch/XilinxSwitch.TB/compile.bash
	@ln -sf ../../../XilinxSwitch_tb.v Encoder/XilinxSwitch/Testbench/XilinxSwitch_tb.v
# Convert configuration file to Verilog.
	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Encoder/XilinxSwitch/fec_0_t.HDL/Configuration.v
# Fix backpressure.
	@FILE=$$(mktemp) && ./Patch_backpressure.pl > $${FILE} && mv $${FILE} Encoder/XilinxSwitch/XilinxSwitch.v
# Fix timing bug in testbench.
	@ln -sf ../../../TB_System_Stim.v Encoder/XilinxSwitch/Testbench/TB_System_Stim.v
# Set the correct target FPGA.
	@sed -i 's:xcvu095-ffva2104-2-e:xczu9eg-ffvb1156-2-i:' Encoder/XilinxSwitch/XilinxSwitch_vivado_packager.tcl

Encoder.sdnet: encoder.p4
	p4c-sdnet -I ../RSEVivadoHLS encoder.p4 -o Encoder.sdnet
	./sdnet_patch.sh

clean:
	rm -fr Encoder.sdnet Encoder

