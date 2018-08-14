CC=g++
VENCORE_CODE=../../RSECode

# To use Vencore's or Hans' implementation of the FEC
COMPILED_RSE=$(VENCORE_CODE)
#COMPILED_RSE=../../FPGA/RSEVivadoHLS

FLAGS=-g -Wall -I$(VENCORE_CODE) -I$(OTHER_INCLUDE) -I. -O2 -DWHARF_DEBUGGING

FEC_BOOSTER_SWITCH_DIR=../bmv2/booster_switch/
FEC_BOOSTER_SWITCH_FEC_DIR=$(FEC_BOOSTER_SWITCH_DIR)fecBoosters/

P4BOOSTERS_REPO=$(realpath ../../)

# For Configuration.h
OTHER_INCLUDE=../../FPGA/RSEVivadoHLS

PCAP_INPUTS=$(COMPILED_RSE)/rse.o fecBooster.o fecBoosterApi.o fecPcap/fecPcap.c
PCAP_DEPS=$(PCAP_INPUTS) $(VENCORE_CODE)/rse.h fecPcap/fecPcap.h makefile fecBooster.h

P4_INPUTS=$(COMPILED_RSE)/rse.o fecBooster.o fecP4/fecEncodeBooster.o fecP4/fecDecodeBooster.o fecP4/fecP4.o
P4_DEPS=$(P4_INPUTS) $(PCAP_DEPS)

ifeq ($(MAKECMDGOALS), bmv2)
ifeq ($(BMV2_REPO),)
    $(error Must set env BMV2_REPO to 'make bmv2')
endif
endif

BMV2_BOOSTER_SWITCH_DIR=$(BMV2_REPO)/targets/booster_switch/

all: pcap p4

pcap: fecDecodeBooster fecEncodeBooster forwardingNonbooster

copy_files: p4
	rsync -av --exclude='test_output' ./* $(FEC_BOOSTER_SWITCH_FEC_DIR)

bmv2: copy_files
	cd $(FEC_BOOSTER_SWITCH_DIR)/.. && make configure all BOOSTERS=FEC

fecBoosterApi.o: fecBoosterApi.c
	$(CC) $(FLAGS) -c $<

fecBooster.o: fecBooster.c $(VENCORE_CODE)/rse.h makefile
	$(CC) $(FLAGS) -c fecBooster.c -lpcap

fecEncodeBooster: fecPcap/fecEncodeBooster.c $(PCAP_DEPS)
	$(CC) $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

fecDecodeBooster: fecPcap/fecDecodeBooster.c $(PCAP_DEPS)
	$(CC) $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

forwardingNonbooster: fecPcap/forwardingNonbooster.c $(PCAP_DEPS)
	$(CC) $(FLAGS) -o $@ $< $(PCAP_INPUTS) -lpcap

#boosterCliTest: fecBoosterApi.c fecBoosterApi.h boosterCliTest.c fecBooster.c
#	$(CC) $(FLAGS) -o $@ fecBoosterApi.c boosterCliTest.c fecBooster.c -DNO_FBK

p4: fecBoosterP4lib.a fecP4/fecP4.hpp

fecP4/%.o: fecP4/%.cpp fecBooster.h
	$(CC) $(FLAGS) --std=c++11 -o $@ -c $<

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
	$(RM) fecP4/*.a
	$(RM) fecPcap/*.o
	$(RM) fecBoosterP4lib.a
	$(RM) $(COMPILED_RSE)/rse.o
