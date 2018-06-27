.PHONY: All Simulation clean

All: Encoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet Scripts/Generate_packets.sh Scripts/Patch_backpressure.pl \
         Sources/fec_0_t.hpp Sources/rse.cpp Sources/rse.h Sources/fec_0_t.v \
         Sources/memcached_0_t.hpp Sources/memcached_0_t.v
	@rm -fr Encoder
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Encoder
	@ln -s ../../Scripts/Generate_packets.sh Encoder/XilinxSwitch/Generate_packets.sh
#	@ln -s ../../../Sources/fec_0_t.hpp Encoder/XilinxSwitch/fec_0_t.TB/fec_0_t.hpp
#	@ln -s ../../../Sources/rse.cpp Encoder/XilinxSwitch/fec_0_t.TB/rse.cpp
#	@ln -s ../../../Sources/rse.h Encoder/XilinxSwitch/fec_0_t.TB/rse.h
#	@ln -s ../../../Sources/fec_0_t.v Encoder/XilinxSwitch/fec_0_t.HDL/fec_0_t.v
	@ln -s ../../../Sources/memcached_0_t.hpp Encoder/XilinxSwitch/memcached_0_t.TB/memcached_0_t.hpp
	@ln -s ../../../Sources/memcached_0_t.v Encoder/XilinxSwitch/memcached_0_t.HDL/memcached_0_t.v
	@ln -s ../../../MemcachedP4/Scripts/run_C.sh Encoder/XilinxSwitch/run_C.sh
	@ln -s ../../../MemcachedP4/Scripts/run_RTL.sh Encoder/XilinxSwitch/run_RTL.sh
	@ln -s ../../../../MemcachedVivadoHLS/Memcore.h Encoder/XilinxSwitch/XilinxSwitch.TB/Memcore.h
	@ln -s ../../../../MemcachedVivadoHLS/MemHLS.h Encoder/XilinxSwitch/XilinxSwitch.TB/MemHLS.h
	@ln -s ../../../../MemcachedVivadoHLS/MemHLS.cpp Encoder/XilinxSwitch/XilinxSwitch.TB/MemHLS.cpp
#	@cp ../RSEVivadoHLS/Batch/RSEVivadoHLS/solution1/syn/vhdl/*.vhd Encoder/XilinxSwitch/fec_0_t.HDL
	@echo "Copy and link memcached engine here"
	@cp ../MemcachedVivadoHLS/Batch/MemcachedVivadoHLS/solution2/syn/verilog/*.v Encoder/XilinxSwitch/memcached_0_t.HDL
	@echo "Patches/Encoder.patch has been adapted for memcached -- needs editing to work with FEC too"
	patch -p0 < Patches/Encoder.patch
# Convert configuration file to Verilog.
#	@sed -e 's/^#/`/' -e 's://.*$$::' ../RSEConfig/Configuration.h > Encoder/XilinxSwitch/fec_0_t.HDL/Configuration.v
# Fix backpressure.
	@echo "./Scripts/Patch_backpressure.pl given 'memcached' parameter -- needs editing to work with FEC too"
#	@FILE=$$(mktemp) && ./Scripts/Patch_backpressure.pl -i Encoder/XilinxSwitch/XilinxSwitch.v -d 3 -p fec -t fec_0_t -m fec_0 > $${FILE} && mv $${FILE} Encoder/XilinxSwitch/XilinxSwitch.v
	@FILE=$$(mktemp) && ./Scripts/Patch_backpressure.pl -i Encoder/XilinxSwitch/XilinxSwitch.v -d 3 -p memcached -t memcached_0_t -m memcached_0 > $${FILE} && mv $${FILE} Encoder/XilinxSwitch/XilinxSwitch.v

Encoder.sdnet: Sources/Encoder.p4
	p4c-sdnet -I ../RSEVivadoHLS -I ../MemcachedP4 Sources/Encoder.p4 -o Encoder.sdnet
	patch Encoder.sdnet Patches/Encoder.sdnet.patch

clean:
	rm -fr Encoder.sdnet Encoder

Update_patches:
	p4c-sdnet -I ../RSEVivadoHLS -I ../MemcachedP4 Sources/Encoder.p4 -o Encoder.sdnet.original
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Encoder.original
	Scripts/Create_patches.bash

