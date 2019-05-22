CC=g++

COMPRESSOR_CORE_DIR=../../FPGA/CompressorVivadoHLS
COMPRESSOR_CORE_SOURCE=$(CORE_DIR)/Compressor.cpp
COMPRESSOR_CORE_OBJ=Compressor.o

COMPRESSOR_CORE_DIR=../../FPGA/DecompressorVivadoHLS
COMPRESSOR_CORE_SOURCE=$(CORE_DIR)/Decompressor.cpp
COMPRESSOR_CORE_OBJ=Decompressor.o

XILINX_DIR=/home/$(USER)/Xilinx

HLS_INCLUDE_DIR=$(XILINX_DIR)/Vivado_HLS/2017.1/include/

FLAGS=-g -Wall -I$(CORE_DIR) -I. -I$(HLS_INCLUDE_DIR) -O2 -Wno-unknown-pragmas

BOOSTER_SWITCH_DIR=../bmv2/booster_switch/
BOOSTER_SWITCH_COMPRESSION_DIR=$(BOOSTER_SWITCH_DIR)compressionBoosters/

all: pcap p4 hls_pcap

pcap: compressorAndDecompressor

p4: copy_files

copy_files: p4
	rsync -av --exclude='*.log' ./* $(BOOSTER_SWITCH_COMPRESSION_DIR)

compressorAndDecompressor: pcapCompressorAndDecompressor.cpp vjCompression.cpp
	g++ $^ -o compressorAndDecompressor -lpcap -std=c++11

clean: 
	$(RM) compressorAndDecompressor
