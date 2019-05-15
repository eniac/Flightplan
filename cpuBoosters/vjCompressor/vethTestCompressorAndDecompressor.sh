# run the empty booster.
BOOSTER_NAME=compressorAndDecompressor
SOURCE_PCAP=$1
INPUT_PCAP=$1.$BOOSTER_NAME.in.pcap
OUTPUT_PCAP=$1.$BOOSTER_NAME.out.pcap
echo "testing booster $BOOSTER_NAME with veth pairs."
echo "source pcap: $SOURCE_PCAP"
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

# bring up veth pairs. 
# networkVeth = network side of cable. 
# deviceVeth = booster side of cable.
peer_link() {
	ip link add $1 type veth peer name $2
	sysctl net.ipv6.conf.$1.disable_ipv6=1
	sysctl net.ipv6.conf.$2.disable_ipv6=1
	ifconfig $1 up promisc
	ifconfig $2 up promisc
}

peer_link networkVeth1 deviceVeth1
peer_link networkVeth2 deviceVeth2
peer_link networkVeth3 deviceVeth3
peer_link networkVeth4 deviceVeth4

# start empty booster : reads and writes to deviceVeth.
echo "starting compressor booster..."
./$BOOSTER_NAME -i deviceVeth1 -o networkVeth2 -f 0 > ${BOOSTER_NAME}_compress.log &
echo "starting decompressor booster..."
./$BOOSTER_NAME -i deviceVeth2 -o networkVeth3 -f 1 > ${BOOSTER_NAME}_decompress.log &
echo "starting forward nonbooster..."
./$BOOSTER_NAME -i deviceVeth3 -o networkVeth4 -f 2 > ${BOOSTER_NAME}_fwd.log &

# start tcpdump to collect the packets that come back into the network from the device.
echo "starting tcpdump... INPUT_PCAP=$INPUT_PCAP, OUTPUT_PCAP=$OUTPUT_PCAP"
rm $INPUT_PCAP
rm $OUTPUT_PCAP
tcpdump -Q out -i networkVeth1 -w $INPUT_PCAP &
tcpdump -Q out -i networkVeth4 -w $OUTPUT_PCAP &
sleep 1

# start tcpreplay to send input from the network to the device (at 1k pps).
echo "starting tcpreplay..."
tcpreplay --preload-pcap --quiet -p 1000 -i networkVeth1 $SOURCE_PCAP
sleep 1

# cleanup
chown $real_user:$real_user $OUTPUT_PCAP
killall tcpdump
killall $BOOSTER_NAME
ip link delete networkVeth1
ip link delete networkVeth2
ip link delete networkVeth3
ip link delete networkVeth4

# compare input and output pcaps.
python comparePcaps.py $INPUT_PCAP $OUTPUT_PCAP
