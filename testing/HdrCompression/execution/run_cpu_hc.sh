#!/bin/bash
OUT=$1
LABEL=$2
REPS=$3

if [[ $LABEL == "" ]]; then
    echo "usage $0 OUT LABEL RATES "
    exit -1
fi

if [[ $RATES == "" ]]; then
    RATES="5.00";
fi

SHR=../../Shremote/shremote.py
CFG=cfgs/cpu_hc.yml

mkdir -p $OUT/$LABEL

run_booster () {
    python3 $SHR $CFG ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:-f;pcap_file:oneFlow.pcap" ;
    RTN=$?
    RETRIES=1
    while [[ $RTN != 0 ]]; do
        echo "Trying again... $RETRIES"
        sleep 5
        python3 $SHR $CFG ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:-f;pcap_file:oneFlow.pcap" ;
        RTN=$?
        RETRIES=$(( $RETRIES + 1 ))
    done
    echo "SUCCESS!";
    sleep 5
}

for rate in $RATES; do
    run_booster $rate;
done
