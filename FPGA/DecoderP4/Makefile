.PHONY: All Simulation clean

All: Decoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Decoder

Decoder/XilinxSwitch/XilinxSwitch_vivado: Decoder
	cd $(realpath Decoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Decoder: Decoder.sdnet Scripts/Patch_backpressure.pl
	@rm -fr Decoder
	sdnet Decoder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Decoder
#	@ln -s ../../Scripts/Generate_packets.sh Decoder/XilinxSwitch/Generate_packets.sh
#	@ln -s ../../../Sources/fec_0_t.hpp Decoder/XilinxSwitch/fec_0_t.TB/fec_0_t.hpp
#	@ln -s ../../../Sources/rse.cpp Decoder/XilinxSwitch/fec_0_t.TB/rse.cpp
#	@ln -s ../../../Sources/rse.h Decoder/XilinxSwitch/fec_0_t.TB/rse.h
#	@ln -s ../../../Sources/fec_0_t.v Decoder/XilinxSwitch/fec_0_t.HDL/fec_0_t.v
#	@cp ../RSEVivadoHLS/Batch/RSEVivadoHLS/solution1/syn/vhdl/*.vhd Decoder/XilinxSwitch/fec_0_t.HDL
#	patch -p0 < Patches/Decoder.patch
# Convert configuration file to Verilog.
	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Decoder/XilinxSwitch/Decoder_0_t.HDL/Configuration.v
# Fix backpressure.
	@FILE=$$(mktemp) && ./Scripts/Patch_backpressure.pl > $${FILE} && mv $${FILE} Decoder/XilinxSwitch/XilinxSwitch.v

Decoder.sdnet: Sources/Decoder.p4
	p4c-sdnet -I ../RSEVivadoHLS Sources/Decoder.p4 -o Decoder.sdnet
	patch Decoder.sdnet Patches/Decoder.sdnet.patch

clean:
	rm -fr Decoder.sdnet Decoder

Update_patches:
	p4c-sdnet -I ../RSEVivadoHLS Sources/Decoder.p4 -o Decoder.sdnet.original
	sdnet Decoder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Decoder.original
	Scripts/Create_patches.bash

