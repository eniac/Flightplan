VENCORE_CODE=../../RSECode

# To use Vencore's or Hans' implementation of the FEC
COMPILED_RSE=$(VENCORE_CODE)
#COMPILED_RSE=../../FPGA/RSEVivadoHLS

FLAGS=-Wall -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -DWHARF_DEBUGGING

# For Configuration.h
OTHER_INCLUDE=../../FPGA/RSEVivadoHLS

all: fecBooster.o fecEncodeBooster fecEncodeBooster_baseline fecDecodeBooster fecTagUntagBooster fecTagEncodeBooster forwardingNonbooster

fecBooster.o: fecBooster.c $(VENCORE_CODE)/rse.h
	g++ $(FLAGS) -c fecBooster.c -lpcap

fecTagEncodeBooster: fecTagEncodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ $(FLAGS) -o fecTagEncodeBooster fecTagEncodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

fecDecodeBooster: fecDecodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ $(FLAGS) -o fecDecodeBooster fecDecodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

forwardingNonbooster: forwardingNonbooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ $(FLAGS) -o forwardingNonbooster forwardingNonbooster.c $(COMPILED_RSE)/rse.o fecBooster.o -lpcap

$(COMPILED_RSE)/rse.o:
	make -C $(COMPILED_RSE) rse.o

clean:
	$(RM) fecTagEncodeBooster
	$(RM) fecDecodeBooster
	$(RM) forwardingNonbooster
	$(RM) *.o
	$(RM) $(COMPILED_RSE)/rse.o
