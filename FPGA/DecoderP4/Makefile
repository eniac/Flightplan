.PHONY: All Simulation clean

All: Decoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Decoder

Decoder/XilinxSwitch/XilinxSwitch_vivado: Decoder
	cd $(realpath Decoder/XilinxSwitch); \
	bash -c 'source $$SDSOC_ROOT/settings64.sh && vivado -mode batch -source XilinxSwitch_vivado_packager.tcl'

Decoder: Decoder.sdnet Scripts/Patch_backpressure.pl
	@rm -fr Decoder
	bash -c 'source $$SDNET_ROOT/settings64.sh && sdnet Decoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Decoder'
	@ln -s ../../../Sources/Decoder_0_t.hpp Decoder/XilinxSwitch/Decoder_0_t.TB/Decoder_0_t.hpp
	@ln -s ../../../Sources/Decoder_0_t.v Decoder/XilinxSwitch/Decoder_0_t.HDL/Decoder_0_t.v
	@cp Input/Packet.user Decoder/XilinxSwitch/Packet.user
	patch -p0 < Patches/Decoder.patch
# Convert configuration file to Verilog.
	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Decoder/XilinxSwitch/Decoder_0_t.HDL/Configuration.v
# Fix backpressure.
	@FILE=$$(mktemp) && ./Scripts/Patch_backpressure.pl -i Decoder/XilinxSwitch/XilinxSwitch.v -d 3 -p Decoder -t Decoder_0_t -m Decoder_0 > $${FILE} && mv $${FILE} Decoder/XilinxSwitch/XilinxSwitch.v

Decoder.sdnet: Sources/Decoder.p4
	bash -c 'source $$SDNET_ROOT/settings64.sh && p4c-sdnet -I ../RSEVivadoHLS Sources/Decoder.p4 -o Decoder.sdnet'
	patch Decoder.sdnet Patches/Decoder.sdnet.patch

clean:
	rm -fr Decoder.sdnet Decoder

Update_patches:
	bash -c 'source $$SDNET_ROOT/settings64.sh && p4c-sdnet -I ../RSEVivadoHLS Sources/Decoder.p4 -o Decoder.sdnet.original'
	bash -c 'source $$SDNET_ROOT/settings64.sh && sdnet Decoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Decoder.original'
	Scripts/Create_patches.bash

