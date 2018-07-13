.PHONY: All Simulation clean

P4C=~/dcomp/p4c/build/p4c-bm2-ss

All: EncoderNew

run_simple: Encoder.json
	sudo python ~/dcomp/behavioral-model/mininet/1sw_demo.py --behavioral-exe ~/dcomp/behavioral-model/targets/simple_switch/simple_switch --json Encoder.json  --pcap-dump dump.pcap

run: Encoder.json
	sudo python ~/dcomp/behavioral-model/mininet/1sw_demo.py --behavioral-exe ~/dcomp/behavioral-model/targets/booster_switch/simple_switch --json Encoder.json  --pcap-dump dump.pcap

EncoderNew: Encoder.json

Sample.json:
	p4c Sources/Sample.p4

Encoder.json: Makefile Sources/Encoder.p4
	#p4c -I ../RSEVivadoHLS/ -Idata/p4include Sources/Encoder.p4 
	p4c-bm2-ss --emit-externs -I  ../RSEVivadoHLS/ -Idata/p4include  Sources/Encoder.p4 -o $@ --target bmv2 --arch v1model

simple.json: Makefile simple.p4
	p4c-bm2-ss simple.p4 -o $@ --target bmv2 --arch v1model


Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet Scripts/Generate_packets.sh Scripts/Patch_backpressure.pl \
         Sources/fec_0_t.hpp Sources/rse.cpp Sources/rse.h Sources/fec_0_t.v
	@rm -fr Encoder
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Encoder
	@ln -s ../../Scripts/Generate_packets.sh Encoder/XilinxSwitch/Generate_packets.sh
	@ln -s ../../../Sources/fec_0_t.hpp Encoder/XilinxSwitch/fec_0_t.TB/fec_0_t.hpp
	@ln -s ../../../Sources/rse.cpp Encoder/XilinxSwitch/fec_0_t.TB/rse.cpp
	@ln -s ../../../Sources/rse.h Encoder/XilinxSwitch/fec_0_t.TB/rse.h
	@ln -s ../../../Sources/fec_0_t.v Encoder/XilinxSwitch/fec_0_t.HDL/fec_0_t.v
	@cp ../RSEVivadoHLS/Batch/RSEVivadoHLS/solution1/syn/vhdl/*.vhd Encoder/XilinxSwitch/fec_0_t.HDL
	patch -p0 < Patches/Encoder.patch
# Convert configuration file to Verilog.
	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Encoder/XilinxSwitch/fec_0_t.HDL/Configuration.v
# Fix backpressure.
	@FILE=$$(mktemp) && ./Scripts/Patch_backpressure.pl -i Encoder/XilinxSwitch/XilinxSwitch.v -d 3 -p fec -t fec_0_t -m fec_0 > $${FILE} && mv $${FILE} Encoder/XilinxSwitch/XilinxSwitch.v

Encoder.sdnet: Sources/Encoder.p4
	p4c-sdnet -I ../RSEVivadoHLS Sources/Encoder.p4 -o Encoder.sdnet
	patch Encoder.sdnet Patches/Encoder.sdnet.patch

clean:
	rm -fr Encoder.sdnet Encoder.json

Update_patches:
	p4c-sdnet -I ../RSEVivadoHLS Sources/Encoder.p4 -o Encoder.sdnet.original
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -workDir Encoder.original
	Scripts/Create_patches.bash

