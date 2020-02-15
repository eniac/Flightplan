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
    stdbuf -o 0 iperf3 -s -i .1 -B $IP -p $(( $BASE_PORT + $i )) | ts %.s > ${LOGBASE}_$i.out 2> ${LOGBASE}_$i.err&
done

wait
