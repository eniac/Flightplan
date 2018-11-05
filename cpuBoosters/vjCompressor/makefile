all: compressor decompressor

compressor: compressor.cpp
	g++ compressor.cpp -o compressor -lpcap -std=c++11

decompressor: decompressor.cpp
	g++ decompressor.cpp -o decompressor -lpcap -std=c++11

clean: 
	$(RM) compressor
	$(RM) decompressor