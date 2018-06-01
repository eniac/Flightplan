INPUT_PCAP=`realpath $1`

NETWORK_IF=enp66s0f0 # tofino side of cable
NETWORK_IF_PCI_ID='42:00.0'
BOOSTER_IF=enp66s0f1 # booster side of cable
BOOSTER_IF_PCI_ID='42:00.1'

RESULTS_DIR=`realpath ../benchmarkData`

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

EXP_DIR=`pwd`

sysctl net.ipv6.conf."$NETWORK_IF".disable_ipv6=1
sysctl net.ipv6.conf."$BOOSTER_IF".disable_ipv6=1
ifconfig $NETWORK_IF up promisc
ifconfig $BOOSTER_IF up promisc


# 1. benchmark line rate.
EXP_NAME=lineRate
echo "running experiment: $EXP_NAME"
# start dpdk.
DPDK_SCRIPT_DIR=`realpath ../../dpdkScripts`
cd $DPDK_SCRIPT_DIR
. ./setDpdkPaths.bash
./allocHugePages.sh
cd $PKTGEN_DIR
sudo ./app/x86_64-native-linuxapp-gcc/pktgen -l 0,1,2 -n 4 -w $NETWORK_IF_PCI_ID -w $BOOSTER_IF_PCI_ID -- -P -m "[1:2].[0-1]" -f $DPDK_SCRIPT_DIR/luaScripts/throughput.lua -s 0:$INPUT_PCAP
# move output file to benchmarks dir.
sudo chown $real_user $PKTGEN_DIR/throughput.txt
mv $PKTGEN_DIR/throughput.txt $RESULTS_DIR/pcapThroughput."$EXP_NAME".txt

cd $EXP_DIR