Execute ./runUnitTests.sh to run compress/decompress functionality.

runUnitTests.sh in turn calls vethTestCompressorAndDecompressor.sh.
Args to this call are:
  arg1: The input test pcap file.
  arg2: Whether the implementation should be run using libpcap(1) or HLSWrapper implementation(0)

vethTestCompressorAndDecompressor.sh creates pcap files for test pcap i/p, compressed and o/p packets.

It also generates the neccessary binary executables needed to run the test cases. 

The compression and decompression logic are run on top of virtual n/w interfaces to separate logic. 

The packet is introduced into the entry interface of the system using tcpreplay. 

Finally, a comparison is made between the i/p and o/p pcap files for each test pcap file.
