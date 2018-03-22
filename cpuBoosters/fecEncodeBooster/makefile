VENCORE_CODE=../../RSECode/
#COMPILED_RSE=$(VENCORE_CODE)
COMPILED_RSE=../../FPGA/RSEVivadoHLS

all: rse.o fecEncodeBooster fecEncodeBooster_baseline

fecEncodeBooster: fecEncodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile
	g++ -I$(VENCORE_CODE) -O2 -o fecEncodeBooster fecEncodeBooster.c $(COMPILED_RSE)/rse.o -lpcap

fecEncodeBooster_baseline: fecEncodeBooster_baseline.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile
	g++ -I$(VENCORE_CODE) -O2 -o fecEncodeBooster_baseline fecEncodeBooster_baseline.c $(COMPILED_RSE)/rse.o -lpcap

rse.o:
	make -C $(COMPILED_RSE) rse.o

clean: 
	$(RM) fecEncodeBooster
	$(RM) fecEncodeBooster_baseline
	$(RM) *.o
	$(RM) $(COMPILED_RSE)/rse.o
