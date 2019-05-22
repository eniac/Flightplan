BOOSTER_NAME=Decompressor

if [ $# -eq 0 ];
then
	echo "Please specify the Test case"
	exit 1
fi

TEST_NAME=UnitTest/$1
SOURCE_PCAP=$TEST_NAME/Send.pcap
REF_PCAP=$TEST_NAME/ref.pcap
SOFTWARE_RECV_PCAP=Csimulation.pcap
SOFTWARE_INPUT=Packet.user
echo "Testing $BOOSTER_NAME with $TEST_NAME..."

echo "--------------------------Starting C-simulation----------------------"

rm *.pcap
cp $SOURCE_PCAP $SOFTWARE_INPUT
../Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch > Csim.log 
mv Packet_expect.pcap $SOFTWARE_RECV_PCAP
echo "Finish C_Simulation"
echo
echo "Comparing CSimulation pcap with ref trace"
python comparePcaps.py $REF_PCAP $SOFTWARE_RECV_PCAP 
if [ $# -gt 1 ] && [ "$2" = "-RTL" ];
then
	echo "--------------------------Starting RTL-simulation----------------------"
	cp Packet* ../Encoder/XilinxSwitch/.
	cp Tuple* ../Encoder/XilinxSwitch/.
	cd ../Encoder/XilinxSwitch/
	./vivado_sim.bash;
	cd ../../tests
	echo "--------------------------Finish RTL-simulation----------------------"
fi

rm -f Packet* 
rm -f Tuple*
rm -f xsc* 
