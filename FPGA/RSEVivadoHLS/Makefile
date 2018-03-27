VENCORE_CODE=../../RSECode
INCLUDES=-I$(VENCORE_CODE) -I../RSEConfig -I.
CFLAGS=-D IN_SOFTWARE -D VERIFY_HLS

All: RSEVivadoHLS

RSEVivadoHLS: Encoder.c Encoder.h RSECore.c $(VENCORE_CODE)/rse.h Configuration.h
	@mkdir -p Batch
	cd Batch && vivado_hls ../Synthesize.tcl

clean:
	rm -fr Batch
	rm -f *.o rsetest

rsetest: Encoder.c rsetest.c RSE_core_test.c $(VENCORE_CODE)/rse.c
	gcc $(INCLUDES) -std=c99 $(CFLAGS) -o rsetest \
            Encoder.c rsetest.c RSE_core_test.c $(VENCORE_CODE)/rse.c

# Intended for linking with C++ compiled CPU booster in ../../cpuBoosters/fecEncodeBooster
rse.o:
	@g++ $(INCLUDES) $(CFLAGS) -c rse.c
	@mv rse.o pre_rse.o
	@g++ $(INCLUDES) $(CFLAGS) -c RSE_core_test.c
	@g++ $(INCLUDES) $(CFLAGS) -c RSECore.c
	@g++ $(INCLUDES) $(CFLAGS) -c Encoder.c
	@ld -r pre_rse.o RSE_core_test.o RSECore.o Encoder.o -o rse.o
	@rm pre_rse.o
