VENCORE_CODE=../../RSECode/

all: fecEncodeBooster fecEncodeBooster_baseline

fecEncodeBooster: fecEncodeBooster.c $(VENCORE_CODE)/rse.h $(VENCORE_CODE)/rse.o makefile
	g++ -I$(VENCORE_CODE) -O2 -o fecEncodeBooster fecEncodeBooster.c $(VENCORE_CODE)/rse.o -lpcap

fecEncodeBooster_baseline: fecEncodeBooster_baseline.c $(VENCORE_CODE)/rse.h $(VENCORE_CODE)/rse.o makefile
	g++ -I$(VENCORE_CODE) -O2 -o fecEncodeBooster_baseline fecEncodeBooster_baseline.c $(VENCORE_CODE)/rse.o -lpcap

rse.o:
	make -C $(VENCORE_CODE)

clean: 
	$(RM) fecEncodeBooster
	$(RM) fecEncodeBooster_baseline
	$(RM) *.o
