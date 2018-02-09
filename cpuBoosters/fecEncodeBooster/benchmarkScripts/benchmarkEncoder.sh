#!/bin/bash
INPUT_PCAP=`realpath $1`

NETWORK_IF=enp66s0f0 # tofino side of cable
NETWORK_IF_PCI_ID='42:00.0'
BOOSTER_IF=enp66s0f1 # booster side of cable
BOOSTER_IF_PCI_ID='42:00.1'

RESULTS_DIR=`realpath ../benchmarkData`
EXP_DIR=`pwd`
EXP_NAME=fec
BOOSTER_NAME=fecEncodeBooster

echo "testing booster $BOOSTER_NAME with physical interfaces."
echo "input pcap: $INPUT_PCAP"

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

mkdir $RESULTS_DIR
chown $real_user $RESULTS_DIR

sysctl net.ipv6.conf."$NETWORK_IF".disable_ipv6=1
sysctl net.ipv6.conf."$BOOSTER_IF".disable_ipv6=1
ifconfig $NETWORK_IF up promisc
ifconfig $BOOSTER_IF up promisc

# start booster.
# numactl --cpunodebind 1 --membind 1 ../$BOOSTER_NAME -i $BOOSTER_IF &

NUM_WORKERS=8
MAX_ID=7

for WORKER_ID in `seq 0 $MAX_ID`
do
	echo "starting booster $WORKER_ID"
	numactl --cpunodebind 1 --membind 1 ../$BOOSTER_NAME -i $BOOSTER_IF -w $WORKER_ID -t $NUM_WORKERS &
done

sleep 2

# start dpdk.
DPDK_SCRIPT_DIR=`realpath ../../dpdkScripts`
cd $DPDK_SCRIPT_DIR
. ./setDpdkPaths.bash
./allocHugePages.sh
cd $PKTGEN_DIR
sudo ./app/x86_64-native-linuxapp-gcc/pktgen -l 0,4,8 -n 4 -w $NETWORK_IF_PCI_ID -- -P -m "[4:8].[0:0]" -f $DPDK_SCRIPT_DIR/luaScripts/oneport_throughput.lua -s 0:$INPUT_PCAP
# move output file to benchmarks dir.
sudo chown $real_user $PKTGEN_DIR/throughput.txt
mv $PKTGEN_DIR/throughput.txt $RESULTS_DIR/pcapThroughput."$EXP_NAME"4.txt

killall $BOOSTER_NAME
cd $EXP_DIR