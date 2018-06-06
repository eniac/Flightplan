VENCORE_CODE=../../RSECode

# To use Vencore's or Hans' implementation of the FEC
COMPILED_RSE=$(VENCORE_CODE)
#COMPILED_RSE=../../FPGA/RSEVivadoHLS

FLAGS=-Wall -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -DWHARF_DEBUGGING

# For Configuration.h
OTHER_INCLUDE=../../FPGA/RSEVivadoHLS

all: fecBooster.o fecDecodeBooster fecEncodeBooster forwardingNonbooster boosterCliTest

fecBooster.o: fecBooster.c $(VENCORE_CODE)/rse.h fecBoosterApi.c
	g++ $(FLAGS) -c fecBooster.c -lpcap

fecEncodeBooster: fecEncodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ $(FLAGS) -o $@ fecEncodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o fecBoosterApi.c -lpcap

fecDecodeBooster: fecDecodeBooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ $(FLAGS) -o $@ fecDecodeBooster.c $(COMPILED_RSE)/rse.o fecBooster.o fecBoosterApi.c -lpcap

forwardingNonbooster: forwardingNonbooster.c $(VENCORE_CODE)/rse.h $(COMPILED_RSE)/rse.o makefile fecBooster.o
	g++ $(FLAGS) -o $@ forwardingNonbooster.c $(COMPILED_RSE)/rse.o fecBooster.o fecBoosterApi.c -lpcap

boosterCliTest: fecBoosterApi.c fecBoosterApi.h boosterCliTest.c
	g++ $(FLAGS) -o $@ fecBoosterApi.c boosterCliTest.c -DNO_FBK

$(COMPILED_RSE)/rse.o:
	make -C $(COMPILED_RSE) rse.o

clean:
	$(RM) fecEncodeBooster
	$(RM) fecDecodeBooster
	$(RM) forwardingNonbooster
	$(RM) boosterCliTest
	$(RM) *.o
	$(RM) $(COMPILED_RSE)/rse.o
