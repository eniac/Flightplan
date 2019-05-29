# run the empty booster.
BOOSTER_NAME=compressorAndDecompressor
SOURCE_PCAP=$1
INPUT_PCAP=$1.$BOOSTER_NAME.in.pcap
OUTPUT_PCAP=$1.$BOOSTER_NAME.out.pcap
COMPRESS_PCAP=$1.$BOOSTER_NAME.compress.pcap
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

LIBPCAP=$2
HLS_COMPRESSOR=hls_comp_pcap
HLS_DECOMPRESSOR=hls_decomp_pcap

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

if [ $LIBPCAP = 1 ]; then
# start empty booster : reads and writes to deviceVeth.
  echo "starting compressor booster..."
  ./$BOOSTER_NAME -i deviceVeth1 -o networkVeth2 -f 0 > ${BOOSTER_NAME}_compress.log &
  echo "starting decompressor booster..."
  ./$BOOSTER_NAME -i deviceVeth2 -o networkVeth3 -f 1 > ${BOOSTER_NAME}_decompress.log &
else
  echo "starting compressor booster..."
  ./$HLS_COMPRESSOR -i deviceVeth1 -o networkVeth2 -f 0 > ${BOOSTER_NAME}_compress.log &
  echo "starting decompressor booster..."
  ./$HLS_DECOMPRESSOR -i deviceVeth2 -o networkVeth3 -f 1 > ${BOOSTER_NAME}_decompress.log &
fi

# start tcpdump to collect the packets that come back into the network from the device.
echo "starting tcpdump... INPUT_PCAP=$INPUT_PCAP, OUTPUT_PCAP=$OUTPUT_PCAP, COMPRESS_PCAP=$COMPRESS_PCAP"
rm $INPUT_PCAP
rm $OUTPUT_PCAP
rm $COMPRESS_PCAP
tcpdump -Q out -i networkVeth1 -w $INPUT_PCAP &
tcpdump -Q out -i networkVeth2 -w $COMPRESS_PCAP &
tcpdump -Q out -i networkVeth3 -w $OUTPUT_PCAP &
sleep 1

# start tcpreplay to send input from the network to the device (at 1k pps).
echo "starting tcpreplay..."
tcpreplay --preload-pcap --quiet -p 1000 -i networkVeth1 $SOURCE_PCAP
sleep 1

#if [ $LIBPCAP = 0]; then
#  echo "starting tcpreplay..."
#  tcpreplay --preload-pcap --quiet -p 1000 -i networkVeth2 $COMPRESS_PCAP
#  sleep 1
#fi

# cleanup
chown $real_user:$real_user $OUTPUT_PCAP
killall tcpdump
killall $BOOSTER_NAME
killall $HLS_COMPRESSOR
killall $HLS_DECOMPRESSOR
ip link delete networkVeth1
ip link delete networkVeth2
ip link delete networkVeth3

# compare input and output pcaps.
python comparePcaps.py $INPUT_PCAP $OUTPUT_PCAP

# Verify that header has been compressed
#python ../../Wharf/bmv2/pcap_tools/pcap_size.py $INPUT_PCAP $COMPRESS_PCAP $OUTPUT_PCAP 
