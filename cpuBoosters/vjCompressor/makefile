BOOSTER_SWITCH_DIR=../bmv2/booster_switch/
BOOSTER_SWITCH_COMPRESSION_DIR=$(BOOSTER_SWITCH_DIR)compressionBoosters/

all: pcap p4

pcap: compressorAndDecompressor

p4: copy_files

copy_files: p4
	rsync -av --exclude='*.log' ./* $(BOOSTER_SWITCH_COMPRESSION_DIR)

compressorAndDecompressor: pcapCompressorAndDecompressor.cpp vjCompression.cpp
	g++ -Wall $^ -o compressorAndDecompressor -lpcap -std=c++11

clean: 
	$(RM) compressorAndDecompressor
