all: pcap

pcap: compressorAndDecompressor

compressorAndDecompressor: pcapCompressorAndDecompressor.cpp
	g++ pcapCompressorAndDecompressor.cpp vjCompression.cpp -o compressorAndDecompressor -lpcap -std=c++11

clean: 
	$(RM) compressorAndDecompressor
