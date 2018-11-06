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
ip link add networkVeth type veth peer name deviceVeth
sysctl net.ipv6.conf.networkVeth.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth.disable_ipv6=1
ifconfig networkVeth up promisc
ifconfig deviceVeth up promisc

# start empty booster : reads and writes to deviceVeth.
echo "starting booster..."
./$BOOSTER_NAME -i deviceVeth > $BOOSTER_NAME.log &

# start tcpdump to collect the packets that come back into the network from the device.
echo "starting tcpdump... INPUT_PCAP=$INPUT_PCAP, OUTPUT_PCAP=$OUTPUT_PCAP"
rm $INPUT_PCAP
rm $OUTPUT_PCAP
tcpdump -Q out -i networkVeth -w $INPUT_PCAP &
tcpdump -Q in -i networkVeth -w $OUTPUT_PCAP &
sleep 1

# start tcpreplay to send input from the network to the device (at 1k pps).
echo "starting tcpreplay..."
tcpreplay --preload-pcap --quiet -p 1000 -i networkVeth $SOURCE_PCAP
sleep 1

# cleanup
chown $real_user:$real_user $OUTPUT_PCAP
killall tcpdump
killall $BOOSTER_NAME
ip link delete networkVeth

# compare input and output pcaps.
python comparePcaps.py $INPUT_PCAP $OUTPUT_PCAP