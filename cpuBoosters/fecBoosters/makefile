VENCORE_CODE=../../RSECode

# To use Vencore's or Hans' implementation of the FEC
COMPILED_RSE=$(VENCORE_CODE)
#COMPILED_RSE=../../FPGA/RSEVivadoHLS

FLAGS=-g -Wall -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -I. -O2 -DWHARF_DEBUGGING

# For Configuration.h
OTHER_INCLUDE=../../FPGA/RSEVivadoHLS

PCAP_INPUTS=$(COMPILED_RSE)/rse.o fecBooster.o fecBoosterApi.o fecPcap/fecPcap.c
PCAP_DEPS=$(PCAP_INPUTS) $(VENCORE_CODE)/rse.h fecPcap/fecPcap.h makefile fecBooster.h

P4_INPUTS=$(COMPILED_RSE)/rse.o fecBooster.o fecP4/fecEncodeBooster.o
P4_DEPS=$(P4_INPUTS) $(PCAP_DEPS)

all: pcap p4

pcap: fecDecodeBooster fecEncodeBooster forwardingNonbooster boosterCliTest

fecBoosterApi.o: fecBoosterApi.c
	g++ $(FLAGS) -c $<

fecBooster.o: fecBooster.c $(VENCORE_CODE)/rse.h makefile
	g++ $(FLAGS) -c fecBooster.c -lpcap

fecEncodeBooster: fecPcap/fecEncodeBooster.c $(PCAP_DEPS)
	g++ $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

fecDecodeBooster: fecPcap/fecDecodeBooster.c $(PCAP_DEPS)
	g++ $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

forwardingNonbooster: fecPcap/forwardingNonbooster.c $(PCAP_DEPS)
	g++ $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

boosterCliTest: fecBoosterApi.c fecBoosterApi.h boosterCliTest.c
	g++ $(FLAGS) -o $@ fecBoosterApi.c boosterCliTest.c -DNO_FBK

p4: fecBoosterP4lib.a

fecP4/fecEncodeBooster.o: fecP4/fecEncodeBooster.cpp fecBooster.h
	g++ $(FLAGS) --std=c++11 -o $@ -c $<

fecBoosterP4lib.a: $(P4_DEPS)
	ar cr $@ $(P4_INPUTS)


$(COMPILED_RSE)/rse.o:
	make -C $(COMPILED_RSE) rse.o

clean:
	$(RM) fecEncodeBooster
	$(RM) fecDecodeBooster
	$(RM) forwardingNonbooster
	$(RM) boosterCliTest
	$(RM) *.o
	$(RM) fecP4/*.o
	$(RM) fecPcap/*.o
	$(RM) fecBoosterP4lib.a
	$(RM) $(COMPILED_RSE)/rse.o
