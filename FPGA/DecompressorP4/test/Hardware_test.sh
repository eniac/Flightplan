BOOSTER_NAME=Decompressor
SOURCE_PCAP=$1
SEND_PCAP=send.pcap
RECV_PCAP=recv.pcap
SOFTWARE_RECV_PCAP=Packet_expect.pcap
SOFTWARE_INPUT=Packet.user
INTERFACE_IN=enp3s0f1
INTERFACE_OUT=enp3s0f0
echo "Testing $BOOSTER_NAME...."

if ! [ $(id -u) = 0 ]; then
	echo "The script need to be run as root" >&2
	exit 1
fi

echo "Run Software Simulation..."

rm $SOFTWARE_INPUT
cp $SOURCE_PCAP $SOFTWARE_INPUT
../Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch > simulation.log

echo "Starting tcpdump...."
rm $SEND_PCAP
rm $RECV_PCAP
tcpdump -i $INTERFACE_OUT -w $SEND_PCAP &
tcpdump -Q in -i $INTERFACE_IN -w $RECV_PCAP &
sleep 1

echo "Starting tcpreplay..."
tcpreplay --preload-pcap --quiet -p 1000 -i $INTERFACE_OUT $SOURCE_PCAP
sleep 5 

echo "clean up"
killall tcpdump

echo "Remove Broadcast pcap"
python cleanPcap.py $RECV_PCAP
mv clean.pcap $RECV_PCAP

python comparePcaps.py $RECV_PCAP $SOFTWARE_RECV_PCAP 

rm -f Packet* 
rm -f Tuple*
