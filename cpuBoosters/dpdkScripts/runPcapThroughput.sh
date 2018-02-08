. ./setDpdkPaths.bash
./allocHugePages.sh
WORK_DIR=`pwd`

PCAP_FILE=$WORK_DIR/pcaps/iperfClient2Server.pcap

cd $PKTGEN_DIR
# -l <list of cores to use>
# -n <number of memory channels (always for for dell 720s)
# -m [cores for rx:cores for tx].[device #s to use (0 for first NIC)]
# -w specify a device to use (a NIC)
# -s <NIC port>:pcap filename
sudo ./app/x86_64-native-linuxapp-gcc/pktgen -l 0,1,2,3,4 -n 4 -w 42:00.0 -w 42:00.1 -- -P -m "[1-3:4].[0-1]" -f $WORK_DIR/luaScripts/throughput.lua -s 0:$PCAP_FILE
# move output file to current dir.
sudo chown $USER $PKTGEN_DIR/throughput.txt
mv $PKTGEN_DIR/throughput.txt $WORK_DIR/pcapThroughput.txt