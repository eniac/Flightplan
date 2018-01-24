all: tofinoModel emptyBooster

tofinoModel: tofinoModel.cpp
	g++ tofinoModel.cpp -o tofinoModel -lpcap -std=c++11

emptyBooster: emptyBooster.cpp
	g++ emptyBooster.cpp -o emptyBooster -lpcap -std=c++11

clean: 
	$(RM) tofinoModel
	$(RM) emptyBooster
