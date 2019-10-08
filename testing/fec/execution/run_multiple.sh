#!/bin/bash
SCRIPT=$1
EXPERIMENT=$2
PCAP=$3

if [ $# != 3 ]; then
	echo "Usage: ./run_multiple.sh <script to run multiple times> <name of experiment> <pcap file to use>"
	exit
fi

for i in {1..5} 
do
    #echo "$SCRIPT ${EXPERIMENT}_${i} $PCAP"
    ./$SCRIPT test_multiple_run ${EXPERIMENT}_${i} $PCAP 
done
