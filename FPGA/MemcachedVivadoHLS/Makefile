All: MemcachedVivadoHLS

MemcachedVivadoHLS: MemHLS.cpp MemHLS.h 
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

clean:
	rm -fr Batch

