CC=g++

CORE_DIR=../../FPGA/MemcachedVivadoHLS
CORE_SOURCE=$(CORE_DIR)/MemHLS.cpp
CORE_OBJ=MemHLS.o

XILINX_DIR=/home/iped/

HLS_INCLUDE_DIR=$(XILINX_DIR)/Vivado_HLS/2017.1/include/

FLAGS=-g -Wall -I$(CORE_DIR) -I. -I$(HLS_INCLUDE_DIR) -O2 -Wno-unknown-pragmas

BOOSTER_SWITCH_DIR=../bmv2/booster_switch/
BOOSTER_SWITCH_MEMCD_DIR=$(BOOSTER_SWITCH_DIR)memcachedBooster/

P4BOOSTERS_REPO=$(realpath ../../)

P4_INPUTS=$(CORE_OBJ) memcached.o
P4_DEPS=$(P4_INPUTS) memcached.h

ifeq ($(BMV2_REPO),)
$(error Must set env BMV2_REPO to 'make bmv2')
endif

BMV2_BOOSTER_SWITCH_DIR=$(BMV2_REPO)/targets/booster_switch/

all: p4 pcap

copy_files: p4
	rsync -av --exclude='test_output' ./* $(BOOSTER_SWITCH_MEMCD_DIR)

bmv2_configure: copy_files
	cd $(BOOSTER_SWITCH_DIR)/.. && make configure all BOOSTERS=MEMCACHED

bmv2: copy_files
	cd $(BOOSTER_SWITCH_DIR)/.. && make

memcached.o: memcached.cpp
	$(CC) $(FLAGS) -c $<

$(CORE_OBJ): $(CORE_SOURCE)
	$(CC) $(FLAGS) -c $< -o $@

pcap: memcachedPcap

memcachedPcap: memcachedPcap.c memcached.o $(CORE_OBJ)
	$(CC) $(FLAGS) $^ -o $@ -lpcap

p4: memcachedP4lib.a

memcachedP4lib.a: $(P4_DEPS)
	ar cr $@ $(P4_INPUTS)


clean:
	$(RM) memcachedP4lib.a
	$(RM) $(CORE_OBJ)
