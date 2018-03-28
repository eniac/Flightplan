VENCORE_CODE=../../RSECode

# To use Vencore's or Hans' implementation of the FEC
COMPILED_RSE=$(VENCORE_CODE)
#COMPILED_RSE=../../FPGA/RSEVivadoHLS

# For Configuration.h
OTHER_INCLUDE=../../FPGA/RSEVivadoHLS

all: fecBooster.o fecEncodeBooster fecEncodeBooster_baseline fecDecodeBooster fecTagUntagBooster

fecBooster.o: fecBooster.c $(VENCORE_CODE)/rse.h
	g++ -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -c fecBooster.c -lpcap

fecEncodeBooster: fecEncodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -o fecEncodeBooster fecEncodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

fecDecodeBooster: fecDecodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -o fecDecodeBooster fecDecodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

fecTagUntagBooster: fecTagUntagBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -o fecTagUntagBooster fecTagUntagBooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

fecEncodeBooster_baseline: fecEncodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ -DFEC_ENCODE_BOOSTER_BASELINE -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -o fecEncodeBooster_baseline fecEncodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

$(COMPILED_RSE)/rse.o:
	make -C $(COMPILED_RSE) rse.o

clean: 
	$(RM) fecEncodeBooster
	$(RM) fecEncodeBooster_baseline
	$(RM) *.o
	$(RM) $(COMPILED_RSE)/rse.o
