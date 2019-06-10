#!/bin/bash

SEND_PKT=pcap/Send.pcap
REF_CLIENT_PKT=pcap/ref@client.pcap
REF_SERVER_PKT=pcap/ref@server.pcap
CLIENT_PKT=fpga@client.pcap
SERVER_PKT=fpga@server.pcap

echo "Entering Test 3.."
../testscripts/Hardware_test.sh $1 $SEND_PKT;
sleep 10
python ../testscripts/cleanPcap.py $CLIENT_PKT;
python ../testscripts/cleanPcap.py $SERVER_PKT;
python ../testscripts/comparePcaps.py $SERVER_PKT $REF_SERVER_PKT
python ../testscripts/comparePcaps.py $CLIENT_PKT $REF_CLIENT_PKT

