rsetest:
	@gcc -std=c99 -DUSE_OLD_GENERATOR -DIN_SOFTWARE -o rsetest *.c

All: RSEVivadoHLS

RSEVivadoHLS: Encoder.c Encoder.h RSECore.c rse.h
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

clean:
	rm -fr Batch

