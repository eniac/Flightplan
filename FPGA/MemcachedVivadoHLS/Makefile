All: MemcachedVivadoHLS MemHLS_hash.so

hash: MemHLS_hash.so

MemcachedVivadoHLS: MemHLS.cpp MemHLS.h
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

MemHLS_hash.so: MemHLS_hash.cpp MemHLS.cpp
	g++ -c -fPIC $< -o ${@:.so=.o} -I/home/iped/Vivado_HLS/2017.1/include/
	g++ -shared -o $@ ${@:.so=.o}

clean:
	rm -fr Batch MemHLS_hash.o MemHLS_hash.so

