if [ $# != 2 ]
then 
	echo Auto Generate Packets
	./generate_packet.sh
	input="TX.pcap"
	standard="RX.pcap"
else
	input="$1"
	standard="$2"
fi
sleep 1
cp ./$input ../FPGA/MemcachedP4/Encoder/XilinxSwitch/Packet.user
cd ../FPGA/MemcachedP4/Encoder/XilinxSwitch

XilinxSwitch.TB/XilinxSwitch > ../../../../MemPacket/output.log
cp Packet_expect.pcap ../../../../MemPacket/.
cd ../../../../MemPacket
python3 payload.py $standard
python3 payload.py Packet_expect.pcap
diff $standard.txt Packet_expect.pcap.txt
