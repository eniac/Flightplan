all: fecEncodeBooster fecEncodeBooster_baseline

fecEncodeBooster: fecEncodeBooster.c rse.h rse.o makefile
	g++ -O2 -o fecEncodeBooster fecEncodeBooster.c rse.o -lpcap

fecEncodeBooster_baseline: fecEncodeBooster_baseline.c rse.h rse.o makefile
	g++ -O2 -o fecEncodeBooster_baseline fecEncodeBooster_baseline.c rse.o -lpcap

rse.o:	rse.c rse.h makefile
	g++ -O3 -c rse.c

clean: 
	$(RM) fecEncodeBooster
	$(RM) fecEncodeBooster_baseline
	$(RM) *.o
