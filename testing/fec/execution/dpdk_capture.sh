PKT_SCRIPT=$1
OUTPUT_PCAP=$2

if [[ $OUTPUT_PCAP == "" ]]; then
    echo Usage: $0 PKT_SCRIPT OUTPUT_PCAP
fi

DPDK_DIR=`pwd`/dpdkInstall
RTE_SDK=$DPDK_DIR/dpdk-stable-17.08.1
RTE_TARGET=x86_64-native-linuxapp-gcc
PKTGEN_DIR=$DPDK_DIR/pktgen-3.4.9
WORK_DIR=`pwd`

cd $PKTGEN_DIR
sudo app/x86_64-native-linuxapp-gcc/pktgen -l 0,1,2 -n 4 -w 0d:00.0 -- -P -m "[1:2].[0]" -f $PKT_SCRIPT
mv -f *.pcap $OUTPUT_PCAP
