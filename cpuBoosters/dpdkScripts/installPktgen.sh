. ./setDpdkPaths.bash
cd $DPDK_DIR

# grab pktgen
echo "downloading pktGen..."
wget http://dpdk.org/browse/apps/pktgen-dpdk/snapshot/pktgen-3.4.9.tar.gz
tar -xzf pktgen-3.4.9.tar.gz

# build
echo "building pktGen..."
cd pktgen-3.4.9
# enlarge rx pcap buffer.
sed -i 's/(4 \* (1024 \* 1024))/(128 \* (1024 \* 1024))/g' app/pktgen-capture.c
make

# cleanup
rm ../pktgen-3.4.9.tar.gz