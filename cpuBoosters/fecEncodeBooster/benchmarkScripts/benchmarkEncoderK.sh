#!/bin/bash
H=3
K=130

NUM_WORKERS=8
MAX_ID=7

NETWORK_IF=enp66s0f0 # tofino side of cable
NETWORK_IF_PCI_ID='42:00.0'
BOOSTER_IF=enp66s0f1 # booster side of cable
BOOSTER_IF_PCI_ID='42:00.1'

RESULTS_DIR=`realpath ../benchmarkData`
EXP_DIR=`pwd`
DPDK_SCRIPT_DIR=`realpath ../../dpdkScripts`

EXP_NAME=fecK
BOOSTER_NAME=fecEncodeBooster

SRC_PCAP=`realpath $1`
TMP_PCAP=`pwd`/tmp.pcap

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

ip link add networkVeth type veth peer name deviceVeth
sysctl net.ipv6.conf.networkVeth.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth.disable_ipv6=1
ifconfig networkVeth up promisc
ifconfig deviceVeth up promisc

# for K in {10}
# do
	echo "K = $K"
	# generate pcap.
	../../tofinoModel/tofinoModel deviceVeth $K $H &
	echo "starting tcpdump..."
	rm $TMP_PCAP
	tcpdump -Q in -i networkVeth -w $TMP_PCAP &
	sleep 1
	echo "starting tcpreplay..."
	tcpreplay --preload-pcap --quiet -p 1000 -i networkVeth $SRC_PCAP
	sleep 1
	chown $real_user:$real_user $TMP_PCAP
	killall tcpdump
	killall tofinoModel

	# run FEC Booster.
	for WORKER_ID in `seq 0 $MAX_ID`
	do
		echo "starting booster $WORKER_ID"
		numactl --cpunodebind 1 --membind 1 ../$BOOSTER_NAME -i $BOOSTER_IF -w $WORKER_ID -t $NUM_WORKERS &
	done
	sleep 2

	# start traffic generator.
	cd $DPDK_SCRIPT_DIR
	. ./setDpdkPaths.bash
	./allocHugePages.sh
	cd $PKTGEN_DIR
	sudo ./app/x86_64-native-linuxapp-gcc/pktgen -l 0,4,8 -n 4 -w $NETWORK_IF_PCI_ID -- -P -m "[4:8].[0:0]" -f $DPDK_SCRIPT_DIR/luaScripts/oneport_throughput.lua -s 0:$TMP_PCAP
	# move output file to benchmarks dir.
	sudo chown $real_user $PKTGEN_DIR/throughput.txt
	mv $PKTGEN_DIR/throughput.txt $RESULTS_DIR/pcapThroughput."$EXP_NAME"."$K".txt

	killall $BOOSTER_NAME
	cd $EXP_DIR

# done


# start booster.
# numactl --cpunodebind 1 --membind 1 ../$BOOSTER_NAME -i $BOOSTER_IF &


