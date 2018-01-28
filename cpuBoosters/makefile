all: tofinoModel emptyBooster packetBufferInfra

tofinoModel: tofinoModel.cpp
	g++ tofinoModel.cpp -o tofinoModel -lpcap -std=c++11

emptyBooster: emptyBooster.cpp
	g++ emptyBooster.cpp -o emptyBooster -lpcap -std=c++11

packetBufferInfra: packetBufferInfra.c rse.h rse.o makefile
	g++ -O3 -o packetBufferInfra packetBufferInfra.c rse.o -lpcap

rse.o:	rse.c rse.h makefile
	g++ -O3 -c rse.c

clean: 
	$(RM) tofinoModel
	$(RM) emptyBooster
	$(RM) packetBufferInfra
	$(RM) *.o
