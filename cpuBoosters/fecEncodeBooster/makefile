all: fecBooster.o fecEncodeBooster fecEncodeBooster_baseline

fecBooster.o: fecBooster.c rse.h
	g++ -O2 -c fecBooster.c -lpcap

fecEncodeBooster: fecEncodeBooster.c rse.h rse.o makefile fecBooster.o
	g++ -O2 -o fecEncodeBooster fecEncodeBooster.c rse.o fecBooster.o -lpcap

fecEncodeBooster_baseline: fecEncodeBooster.c rse.h rse.o makefile
	g++ -DFEC_ENCODE_BOOSTER_BASELINE -O2 -o fecEncodeBooster_baseline fecEncodeBooster.c rse.o fecBooster.o -lpcap


fecEncodeBooster_baseline: fecEncodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile
	g++ -DFEC_ENCODE_BOOSTER_BASELINE -I$(VENCORE_CODE) -O2 -o fecEncodeBooster_baseline fecEncodeBooster_baseline.c $(COMPILED_RSE)/rse.o -lpcap

rse.o:
	make -C $(COMPILED_RSE) rse.o

clean: 
	$(RM) fecEncodeBooster
	$(RM) fecEncodeBooster_baseline
	$(RM) *.o
	$(RM) $(COMPILED_RSE)/rse.o
