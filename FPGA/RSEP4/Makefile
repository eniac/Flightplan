.PHONY: All Simulation clean

All: Wharf/XilinxSwitch/XilinxSwitch_vivado

Simulation: Wharf

Wharf/XilinxSwitch/XilinxSwitch_vivado: Wharf
	cd $(realpath Wharf/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Wharf: Wharf.sdnet Scripts/Generate_packets.sh Scripts/Patch_backpressure.pl \
         Sources/fec_0_t.hpp Sources/rse.cpp Sources/rse.h Sources/fec_0_t.v
	@rm -fr Wharf
	sdnet Wharf.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Wharf
	@ln -s ../../Scripts/Generate_packets.sh Wharf/XilinxSwitch/Generate_packets.sh
	@ln -s ../../../Sources/fec_0_t.hpp Wharf/XilinxSwitch/fec_0_t.TB/fec_0_t.hpp
	@ln -s ../../../Sources/rse.cpp Wharf/XilinxSwitch/fec_0_t.TB/rse.cpp
	@ln -s ../../../Sources/rse.h Wharf/XilinxSwitch/fec_0_t.TB/rse.h
	@ln -s ../../../Sources/fec_0_t.v Wharf/XilinxSwitch/fec_0_t.HDL/fec_0_t.v
	@cp ../RSEVivadoHLS/Batch/RSEVivadoHLS/solution1/syn/vhdl/*.vhd Wharf/XilinxSwitch/fec_0_t.HDL
	patch -p0 < Patches/Encoder.patch
# Convert configuration file to Verilog.
	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Wharf/XilinxSwitch/fec_0_t.HDL/Configuration.v
# Fix backpressure.
	@FILE=$$(mktemp) && ./Scripts/Patch_backpressure.pl -i Wharf/XilinxSwitch/XilinxSwitch.v -d 3 -p fec -t fec_0_t -m fec_0 > $${FILE} && mv $${FILE} Wharf/XilinxSwitch/XilinxSwitch.v

Wharf.sdnet: Sources/Wharf.p4
	p4c-sdnet -I ../RSEVivadoHLS Sources/Wharf.p4 -o Wharf.sdnet
	patch Wharf.sdnet Patches/Encoder.sdnet.patch

clean:
	rm -fr Wharf.sdnet Wharf

Update_patches:
	p4c-sdnet -I ../RSEVivadoHLS Sources/Wharf.p4 -o Wharf.sdnet.original
	sdnet Wharf.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Wharf.original
	Scripts/Create_patches.bash

