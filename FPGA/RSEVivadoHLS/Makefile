VENCORE_CODE=../../RSECodeVanilla/

rsetest:
	@gcc -I$(VENCORE_CODE) -std=c99 -DUSE_OLD_GENERATOR -DIN_SOFTWARE -DVENCORE_ENCODER -o rsetest *.c

All: RSEVivadoHLS

RSEVivadoHLS: Encoder.c Encoder.h RSECore.c $(VENCORE_CODE)/rse.h Configuration.h
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

clean:
	rm -fr Batch

