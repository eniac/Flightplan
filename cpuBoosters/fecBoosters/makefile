VENCORE_CODE=../../RSECode

# To use Vencore's or Hans' implementation of the FEC
COMPILED_RSE=$(VENCORE_CODE)
#COMPILED_RSE=../../FPGA/RSEVivadoHLS

FLAGS=-g -Wall -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -O2 -DWHARF_DEBUGGING

# For Configuration.h
OTHER_INCLUDE=../../FPGA/RSEVivadoHLS

PCAP_INPUTS=$(COMPILED_RSE)/rse.o fecBooster.o fecBoosterApi.c fecPcap.c
PCAP_DEPS=$(PCAP_INPUTS) $(VENCORE_CODE)/rse.h fecPcap.h makefile

all: fecDecodeBooster fecEncodeBooster forwardingNonbooster boosterCliTest

fecBooster.o: fecBooster.c $(VENCORE_CODE)/rse.h makefile
	g++ $(FLAGS) -c fecBooster.c -lpcap

fecEncodeBooster: fecEncodeBooster.c $(PCAP_DEPS)
	g++ $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

fecDecodeBooster: fecDecodeBooster.c $(PCAP_DEPS)
	g++ $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

forwardingNonbooster: forwardingNonbooster.c $(PCAP_DEPS)
	g++ $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

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
