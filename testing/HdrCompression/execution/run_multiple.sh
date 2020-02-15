#!/bin/bash
SCRIPT=$1
EXPERIMENT=$2
PCAP=$3

if [ $# != 3 ]; then
	echo "USAGE: ./run_multiple.sh <script to be run multiple times> <name of experiment> <pcap file>"
	exit
fi

for i in {3..5} 
do
    #echo "$SCRIPT ${EXPERIMENT}_${i} $PCAP"
    ./$SCRIPT test_multiple_run ${EXPERIMENT}_${i} $PCAP 
done
