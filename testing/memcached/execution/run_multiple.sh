#!/bin/bash
SCRIPT=$1
EXPERIMENT=$2
PCAP_WMP=$3
PCAP_TEST=$4

if [ $# != 4 ]; then
	echo "USAGE: ./run_multiple.sh <script to be run multiple times> <name of experiment> <warmup pcap file> <test pcap file>"
	exit
fi

for i in {1..5} 
do
    #echo "$SCRIPT ${EXPERIMENT}_${i} $PCAP_WMP $PCAP_TEST"
    ./$SCRIPT test_multiple_run ${EXPERIMENT}_${i} $PCAP_WMP $PCAP_TEST 
done
