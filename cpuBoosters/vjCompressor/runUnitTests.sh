# 1. Generate pcap sources.
python generateTestPcaps.py
declare -a pcapsArr=("pcaps/oneFlow.pcap" "pcaps/twoFlows.pcap" "pcaps/collidingFlows.pcap")

# 2. build.
make

# 3. Run booster for each pcap source.
for i in "${pcapsArr[@]}"
do
   echo "running test pcap: $i"
   sudo ./vethTestCompressorAndDecompressor.sh $i
done

