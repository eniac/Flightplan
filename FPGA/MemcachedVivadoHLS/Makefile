ifeq ($(VIVADO_HLS_INCLUDE), )
$(warning WARNING! Set environment variable VIVADO_HLS_INCLUDE to build python hash library)
endif

hls: MemcachedVivadoHLS
hash: MemHLS_hash.so
all: hls hash

MemcachedVivadoHLS: MemHLS.cpp MemHLS.h
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

MemHLS_hash.so: MemHLS_hash.cpp MemHLS.cpp
	g++ -c -fPIC $< -o ${@:.so=.o} -I$(VIVADO_HLS_INCLUDE)
	g++ -shared -o $@ ${@:.so=.o}

clean:
	rm -fr Batch MemHLS_hash.o MemHLS_hash.so

