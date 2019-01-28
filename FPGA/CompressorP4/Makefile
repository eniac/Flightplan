.PHONY: All Simulation clean

All: Encoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet ../RSEP4/Scripts/Patch_backpressure.pl \
         Sources/headerCompress_0_t.hpp Sources/headerCompress_0_t.v
	@rm -fr Encoder
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Encoder
	@ln -s ../../../Sources/headerCompress_0_t.hpp Encoder/XilinxSwitch/headerCompress_0_t.TB/headerCompress_0_t.hpp
	@ln -s ../../../Sources/headerCompress_0_t.v Encoder/XilinxSwitch/headerCompress_0_t.HDL/headerCompress_0_t.v
	@ln -s ../../Scripts/run_C.sh Encoder/XilinxSwitch/run_C.sh
	@ln -s ../../Scripts/run_RTL.sh Encoder/XilinxSwitch/run_RTL.sh
	@ln -s ../../../../CompressorVivadoHLS/Compressor.h Encoder/XilinxSwitch/XilinxSwitch.TB/Compressor.h
	@ln -s ../../../../CompressorVivadoHLS/Compressor.cpp Encoder/XilinxSwitch/XilinxSwitch.TB/Compressor.cpp
	@cp ../CompressorVivadoHLS/Batch/MemcachedVivadoHLS/solution2/syn/verilog/*.v Encoder/XilinxSwitch/headerCompress_0_t.HDL
	patch -p0 < Patches/Encoder.patch
	@FILE=$$(mktemp) && ../RSEP4/Scripts/Patch_backpressure.pl -i Encoder/XilinxSwitch/XilinxSwitch.v -d 3 -p headerCompress -t headerCompress_0_t -m headerCompress_0 > $${FILE} && mv $${FILE} Encoder/XilinxSwitch/XilinxSwitch.v

Encoder.sdnet: Sources/Encoder.p4
	p4c-sdnet -I ../CompressorP4 -I ../RSEVivadoHLS Sources/Encoder.p4 -o Encoder.sdnet
	patch Encoder.sdnet Patches/Encoder.sdnet.patch
clean:
	rm -fr Encoder.sdnet Encoder

Update_patches:
	p4c-sdnet -I ../RSEVivadoHLS -I ../CompressorP4 Sources/Encoder.p4 -o Encoder.sdnet.original
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Encoder.original
	@echo "WARNING: This part of the Makefile has NOT been updated for Memcached" >&2
	Scripts/Create_patches.bash
