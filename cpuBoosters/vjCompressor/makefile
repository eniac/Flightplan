all: pcap

pcap: compressorAndDecompressor

compressorAndDecompressor: pcapCompressorAndDecompressor.cpp vjCompression.cpp
	g++ $^ -o compressorAndDecompressor -lpcap -std=c++11

clean: 
	$(RM) compressorAndDecompressor
