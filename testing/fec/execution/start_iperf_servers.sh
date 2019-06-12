#!/bin/bash

NUM=$1
LOGBASE=$2
IP=$3
BASE_PORT=4240

if [[ $IP == "" ]]; then
    echo "usage: $0 NUM LOGBASE IP";
    exit -1;
fi

for i in `seq 0 $(( $NUM - 1 ))`; do
    iperf3 -s -B $IP -J -p $(( $BASE_PORT + $i )) > ${LOGBASE}_$i.json 2> ${LOGBASE}_$i.err&
done

wait
