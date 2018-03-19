VENCORE_CODE=../../RSECodeVanilla/

all: fecEncodeBooster fecEncodeBooster_baseline

fecEncodeBooster: fecEncodeBooster.c $(VENCORE_CODE)/rse.h rse.o makefile
	g++ -I$(VENCORE_CODE) -O2 -o fecEncodeBooster fecEncodeBooster.c rse.o -lpcap

fecEncodeBooster_baseline: fecEncodeBooster_baseline.c $(VENCORE_CODE)/rse.h rse.o makefile
	g++ -I$(VENCORE_CODE) -O2 -o fecEncodeBooster_baseline fecEncodeBooster_baseline.c rse.o -lpcap

rse.o:	rse.c $(VENCORE_CODE)/rse.h makefile
	g++ -I$(VENCORE_CODE) -O3 -c rse.c

clean: 
	$(RM) fecEncodeBooster
	$(RM) fecEncodeBooster_baseline
	$(RM) *.o
