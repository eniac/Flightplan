CC=g++

COMPRESSOR_CORE_DIR=../../FPGA/CompressorVivadoHLS
COMPRESSOR_CORE_SOURCE=$(COMPRESSOR_CORE_DIR)/Compressor.cpp
COMPRESSOR_CORE_OBJ=Compressor.o

DECOMPRESSOR_CORE_DIR=../../FPGA/DecompressorVivadoHLS
DECOMPRESSOR_CORE_SOURCE=$(DECOMPRESSOR_CORE_DIR)/Decompressor.cpp
DECOMPRESSOR_CORE_OBJ=Decompressor.o

XILINX_DIR=/home/$(USER)/Xilinx

HLS_INCLUDE_DIR=$(XILINX_DIR)/Vivado_HLS/2017.1/include/

FLAGS=-g -Wall -I$(DECOMPRESSOR_CORE_DIR) -I$(COMPRESSOR_CORE_DIR) -I. -I$(HLS_INCLUDE_DIR) -O2 -Wno-unknown-pragmas

BOOSTER_SWITCH_DIR=../bmv2/booster_switch/
BOOSTER_SWITCH_COMPRESSION_DIR=$(BOOSTER_SWITCH_DIR)compressionBoosters/

all: pcap p4 hls_comp_pcap hls_decomp_pcap

pcap: compressorAndDecompressor

p4: copy_files

hls_comp_pcap: $(COMPRESSOR_CORE_OBJ)
	$(CC) $(FLAGS) -DCOMPRESSOR -c hdrCompress.cpp -o hdrCompress.o 
	$(CC) $(FLAGS) $^ hdrCompress.o -o $@ -lpcap

hls_decomp_pcap: $(DECOMPRESSOR_CORE_OBJ)
	$(CC) $(FLAGS) -c hdrCompress.cpp -o hdrCompress.o 
	$(CC) $(FLAGS) $^ hdrCompress.o -o $@ -lpcap

copy_files: p4
	rsync -av --exclude='*.log' ./* $(BOOSTER_SWITCH_COMPRESSION_DIR)

$(COMPRESSOR_CORE_OBJ): $(COMPRESSOR_CORE_SOURCE)
	$(CC) $(FLAGS) -c $< -o $@

$(DECOMPRESSOR_CORE_OBJ): $(DECOMPRESSOR_CORE_SOURCE)
	$(CC) $(FLAGS) -c $< -o $@

compressorAndDecompressor: pcapCompressorAndDecompressor.cpp vjCompression.cpp
	g++ $^ -o compressorAndDecompressor -lpcap -std=c++11

clean: 
	$(RM) compressorAndDecompressor hdrCompress $(COMPRESSOR_CORE_OBJ) $(DECOMPRESSOR_CORE_OBJ) hls_comp_pcap hls_decomp_pcap
