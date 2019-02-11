### Simple C implementation of van-jacobson compressor and decompressor ###

Use it with ```./runUnitTests.sh```

Files:
- runUnitTests.sh : run all unit test pcaps for the merged compressor/decompressor.
- vethTestCompressorAndDecompressor.sh <pcap> : run merged compressor/decompressor on a pcap. Check to ensure output == input. 
- generateTestPcaps.py : generare unit test pcaps for: one flow, two flows (non colliding) and two flows (colliding).
- pcaps : where the unit test pcaps go.
- compressorAndDecompressor.cpp : the merged compressor/decompressor. It applies the compression and decompression function on every packet.
- compressor.h : structs, defs, etc., for compressor and decompressor.
