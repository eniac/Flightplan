#!/bin/bash

SEND_PKT=pcap/Send.pcap
RECV_PKT=Packet_expect.pcap
REF_CLIENT_PKT=pcap/ref@client.pcap
REF_SERVER_PKT=pcap/ref@server.pcap
CLIENT_PKT=@client.pcap
SERVER_PKT=@server.pcap

echo "Entering Test 2.."
../../../FPGA/MemcachedP4/Encoder/XilinxSwitch/XilinxSwitch.TB/XilinxSwitch $SEND_PKT > Simulation.log

rm *.txt
rm *.axi
python ../testscripts/cleanPcap.py $RECV_PKT
python ../testscripts/split.py $RECV_PKT
python ../testscripts/comparePcaps.py $SERVER_PKT $REF_SERVER_PKT
python ../testscripts/comparePcaps.py $CLIENT_PKT $REF_CLIENT_PKT

