# 1. Generate pcap sources.
python generateTestPcaps.py
declare -a pcapsArr=("pcaps/twoFlows.pcap" "pcaps/collidingFlows.pcap" "pcaps/Send.pcap" "pcaps/oneFlow.pcap")

# 2. build.
make

# 3. Run booster for each pcap source.
for i in "${pcapsArr[@]}"
do
   echo "running test pcap: $i"
   #2nd argument. 0 - HLSWrapper implementation. 1 - libpcap implementation
   sudo ./vethTestCompressorAndDecompressor.sh $i 0
done

