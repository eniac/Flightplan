CFLAGS=-D IN_SOFTWARE -D VERIFY_HLS

All: RSEVivadoHLS

RSEVivadoHLS: Encoder.c Encoder.h RSECore.c rse.h Configuration.h
	@mkdir -p Batch
	cd Batch && bash -c 'source $$SDSOC_ROOT/settings64.sh && vivado_hls ../Synthesize.tcl'

clean:
	rm -fr Batch
	rm -f *.o rsetest

rsetest: Encoder.c rsetest.c RSE_core_test.c rse.c
	gcc -std=c99 $(CFLAGS) -o rsetest \
            Encoder.c rsetest.c RSE_core_test.c rse.c

# Intended for linking with C++ compiled CPU booster in ../../cpuBoosters/fecEncodeBooster
rse.o:
	@g++ $(CFLAGS) -DHANS_ENCODER -c rse.c
	@mv rse.o pre_rse.o
	@g++ $(CFLAGS) -c RSE_core_test.c
	@g++ $(CFLAGS) -c RSECore.c
	@g++ $(CFLAGS) -c Encoder.c
	@ld -r pre_rse.o RSE_core_test.o RSECore.o Encoder.o -o rse.o
	@rm pre_rse.o
