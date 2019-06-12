#!/bin/bash

NUM=$1
TIME=$2
LOGBASE=$3
SIP=$4
DIP=$5
BASE_PORT=4240

if [[ $DIP == "" ]]; then
    echo "Usage $0 NUM TIME LOGBASE SIP DIP";
    exit -1;
fi

for i in `seq 0 $(( $NUM - 1 ))`; do
    iperf3 -c $DIP -J  -B $SIP -p $(( $BASE_PORT + $i )) -t $TIME -M 1400 > ${LOGBASE}_$i.json 2> ${LOGBASE}_$i.err &
done

wait
