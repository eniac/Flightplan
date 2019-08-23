# 1. Generate pcap sources.
python generateTestPcaps.py

declare -a pcapsArr=("pcaps/oneFlow.pcap" "pcaps/twoFlows.pcap" "pcaps/collidingFlows.pcap")

# 2. build.
make

for implementation in 0 1
do
    # 3. Run booster for each pcap source.
    for i in "${pcapsArr[@]}"
    do
       echo "running test pcap: $i"
       #2nd argument. 0 - HLSWrapper implementation. 1 - libpcap implementation
       sudo ./vethTestCompressorAndDecompressor.sh $i $implementation
    done
done
