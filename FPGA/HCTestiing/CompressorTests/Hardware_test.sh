BOOSTER_NAME=Decompressor
TEST_NAME=UnitTest/$1
SOURCE_PCAP=$TEST_NAME/Send.pcap
REF_PCAP=$TEST_NAME/ref.pcap
SEND_PCAP=send.pcap
RECV_PCAP=recv.pcap
SOFTWARE_RECV_PCAP=Csimulation.pcap
SOFTWARE_INPUT=Packet.user
INTERFACE_IN=enp3s0f0
INTERFACE_OUT=enp3s0f1
echo "Testing $BOOSTER_NAME with $TEST_NAME..."

if ! [ $(id -u) = 0 ]; then
	echo "The script need to be run as root" >&2
	exit 1
fi

rm *.pcap

echo "Run Software Simulation..."

cp $SOURCE_PCAP $SOFTWARE_INPUT
../../CompressorP4/Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch > simulation.log
mv Packet_expect.pcap $SOFTWARE_RECV_PCAP

echo "Starting tcpdump...."
tcpdump -i -Q out $INTERFACE_OUT -w $SEND_PCAP &
tcpdump -Q in -i $INTERFACE_IN -w $RECV_PCAP &
sleep 1

echo "Starting tcpreplay..."
tcpreplay --preload-pcap --quiet -p 1000 -i $INTERFACE_OUT $SOURCE_PCAP
sleep 5 

killall tcpdump
sleep 5 

echo "----------------------------------------------------------------------"
python cleanPcap.py $RECV_PCAP
mv clean.pcap $RECV_PCAP

echo "Comparing CSimulation pcap with FPGA trace"
python comparePcaps.py $RECV_PCAP $SOFTWARE_RECV_PCAP 


echo "Comparing CSimulation pcap with ref trace"
python comparePcaps.py $REF_PCAP $SOFTWARE_RECV_PCAP 


rm -f Packet* 
rm -f Tuple*
