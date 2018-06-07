# run the empty booster.
BOOSTER_NAME=fecEncodeBooster
INPUT_PCAP=$1
OUTPUT_PCAP=$(dirname "$INPUT_PCAP")/$BOOSTER_NAME/"_veth_"$(basename "$INPUT_PCAP")
echo "testing booster $BOOSTER_NAME with veth pairs."
echo "input pcap: $INPUT_PCAP"
echo "output pcap: $OUTPUT_PCAP"

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

mkdir $(dirname "$INPUT_PCAP")/$BOOSTER_NAME
chown $real_user:$real_user $(dirname "$INPUT_PCAP")/$BOOSTER_NAME


# bring up veth pairs.
# networkVeth = network side of cable.
# deviceVeth = booster side of cable.
ip link add networkVeth type veth peer name deviceVeth
sysctl net.ipv6.conf.networkVeth.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth.disable_ipv6=1
ifconfig networkVeth up promisc
ifconfig deviceVeth up promisc

# start empty booster : reads and writes to deviceVeth.
# echo "starting booster..."
# ./$BOOSTER_NAME -i deviceVeth -w 0 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 1 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 2 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 3 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 4 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 5 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 6 -t 8&
# ./$BOOSTER_NAME -i deviceVeth -w 7 -t 8&

NUM_WORKERS=8
MAX_ID=7

for WORKER_ID in `seq 0 $MAX_ID`
do
	echo "starting booster $WORKER_ID"
	./$BOOSTER_NAME -i deviceVeth -w $WORKER_ID -t $NUM_WORKERS &
done


sleep 1
# start tcpdump to collect the packets that come back into the network from the device.
echo "starting tcpdump... OUTPUT_PCAP=$OUTPUT_PCAP"
rm $OUTPUT_PCAP
tcpdump -Q in -i networkVeth -w $OUTPUT_PCAP &
sleep 1

# start tcpreplay to send input from the network to the device (at 1k pps).
echo "starting tcpreplay..."
tcpreplay --preload-pcap --quiet --loop=100 --topspeed -i networkVeth $INPUT_PCAP
sleep 1

# cleanup
chown $real_user:$real_user $OUTPUT_PCAP
killall tcpdump
killall $BOOSTER_NAME
ip link delete networkVeth
