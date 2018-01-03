all: emptyBooster randomPacketGenerator

emptyBooster: emptyBooster.cpp
	g++ emptyBooster.cpp -o emptyBooster -lpcap -std=c++11
randomPacketGenerator: randomPacketGenerator.cpp
	g++ randomPacketGenerator.cpp -o randomPacketGenerator -lpcap -std=c++11


clean: 
	rm emptyBooster randomPacketGenerator
