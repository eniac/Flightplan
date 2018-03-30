# Based on vethTestBooster.sh but simplified to test forwarding: output packets should be identical to those input.

BOOSTER_NAME=forwardingNonbooster
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
ip link add networkVeth1 type veth peer name deviceVeth1
sysctl net.ipv6.conf.networkVeth1.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth1.disable_ipv6=1
ifconfig networkVeth1 up promisc
ifconfig deviceVeth1 up promisc

ip link add networkVeth2 type veth peer name deviceVeth2
sysctl net.ipv6.conf.networkVeth2.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth2.disable_ipv6=1
ifconfig networkVeth2 up promisc
ifconfig deviceVeth2 up promisc

NUM_WORKERS=1
MAX_ID=0

for WORKER_ID in `seq 0 $MAX_ID`
do
	echo "starting booster $WORKER_ID"
	./$BOOSTER_NAME -i deviceVeth1 -o deviceVeth2 -w $WORKER_ID -t $NUM_WORKERS &
done


sleep 1
# start tcpdump to collect the packets that come back into the network from the device.
echo "starting tcpdump... OUTPUT_PCAP=$OUTPUT_PCAP"
rm $OUTPUT_PCAP
tcpdump -Q in -i networkVeth2 -w $OUTPUT_PCAP &
sleep 1

# start tcpreplay to send input from the network to the device (at 1k pps).
echo "starting tcpreplay..."
tcpreplay --preload-pcap --quiet --loop=1 --topspeed -i networkVeth1 $INPUT_PCAP
sleep 1

# cleanup
chown $real_user:$real_user $OUTPUT_PCAP
killall tcpdump
killall $BOOSTER_NAME
ip link delete networkVeth1
ip link delete networkVeth2
