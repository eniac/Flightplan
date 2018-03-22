VENCORE_CODE=../../RSECode/
CFLAGS=-DUSE_OLD_GENERATOR -DIN_SOFTWARE

All: RSEVivadoHLS

RSEVivadoHLS: Encoder.c Encoder.h RSECore.c $(VENCORE_CODE)/rse.h Configuration.h
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

clean:
	rm -fr Batch
	rm *.o

rsetest:
	@gcc -I$(VENCORE_CODE) -std=c99 $(CFLAGS) -DVENCORE_ENCODER -o rsetest *.c

# Intended for linking with C++ compiled CPU booster in ../../cpuBoosters/fecEncodeBooster
rse.o:
	@g++ -I$(VENCORE_CODE) -std=c99 $(CFLAGS) -c rse.c
	@mv rse.o pre_rse.o
	@g++ -I$(VENCORE_CODE) -std=c99 $(CFLAGS) -c RSE_core_test.c
	@g++ -I$(VENCORE_CODE) -std=c99 $(CFLAGS) -c RSECore.c
	@g++ -I$(VENCORE_CODE) -std=c99 $(CFLAGS) -c Encoder.c
	@ld -r pre_rse.o RSE_core_test.o RSECore.o Encoder.o -o rse.o
	@rm pre_rse.o
