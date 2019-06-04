.PHONY: All Simulation clean

All: Encoder/XilinxSwitch/XilinxSwitch_vivado

Simulation: Encoder

Encoder/XilinxSwitch/XilinxSwitch_vivado: Encoder
	cd $(realpath Encoder/XilinxSwitch); \
	vivado -mode batch -source XilinxSwitch_vivado_packager.tcl

Encoder: Encoder.sdnet ../RSEP4/Scripts/Patch_backpressure.pl \
         Sources/memcached_0_t.hpp Sources/memcached_0_t.v
	@rm -fr Encoder
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Encoder
	@ln -s ../../../Sources/memcached_0_t.hpp Encoder/XilinxSwitch/memcached_0_t.TB/memcached_0_t.hpp
	@ln -s ../../../Sources/memcached_0_t.v Encoder/XilinxSwitch/memcached_0_t.HDL/memcached_0_t.v
	@ln -s ../../../MemcachedP4/Scripts/run_C.sh Encoder/XilinxSwitch/run_C.sh
	@ln -s ../../../MemcachedP4/Scripts/run_RTL.sh Encoder/XilinxSwitch/run_RTL.sh
	@ln -s ../../../../MemcachedVivadoHLS/MemHLS.h Encoder/XilinxSwitch/XilinxSwitch.TB/MemHLS.h
	@ln -s ../../../../MemcachedVivadoHLS/MemHLS.cpp Encoder/XilinxSwitch/XilinxSwitch.TB/MemHLS.cpp
	@ln -s ../../../../MemcachedVivadoHLS/MemHLS_hash.h Encoder/XilinxSwitch/XilinxSwitch.TB/MemHLS_hash.h
	@ln -s ../../../../MemcachedVivadoHLS/MemHLS_hash.cpp Encoder/XilinxSwitch/XilinxSwitch.TB/MemHLS_hash.cpp
	@cp ../MemcachedVivadoHLS/Batch/MemcachedVivadoHLS/solution2/syn/verilog/*.v Encoder/XilinxSwitch/memcached_0_t.HDL
	@echo "Patches/Encoder.patch has been adapted for memcached -- needs editing to work with FEC too"
	patch -p0 < Patches/Encoder.patch
	cp Sources/XilinxSwitch.hpp Encoder/XilinxSwitch/XilinxSwitch.TB/. 
	@FILE=$$(mktemp) && ../RSEP4/Scripts/Patch_backpressure.pl -i Encoder/XilinxSwitch/XilinxSwitch.v -d 3 -p memcached -t memcached_0_t -m memcached_0 > $${FILE} && mv $${FILE} Encoder/XilinxSwitch/XilinxSwitch.v
	cd Encoder/XilinxSwitch/XilinxSwitch.TB; \
	./compile.bash	
Encoder.sdnet: Sources/Encoder.p4
	p4c-sdnet -I ../RSEVivadoHLS -I ../MemcachedP4 Sources/Encoder.p4 -o Encoder.sdnet
	patch Encoder.sdnet Patches/Encoder.sdnet.patch
clean:
	rm -fr Encoder.sdnet Encoder

Update_patches:
	p4c-sdnet -I ../RSEVivadoHLS -I ../MemcachedP4 Sources/Encoder.p4 -o Encoder.sdnet.original
	sdnet Encoder.sdnet -busType axi -busWidth 64 -UE -clk_line -lineClock 156.25 -workDir Encoder.original
	@echo "WARNING: This part of the Makefile has NOT been updated for Memcached" >&2
	Scripts/Create_patches.bash
