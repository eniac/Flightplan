#!/bin/bash
OUT=$1
LABEL=$2
PCAP_WMP=$3
PCAP_TEST=$4
RATES=$5

if [[ $LABEL == "" || $OUT == "" ]]; then
    echo "usage $0 OUT LABEL RATES"
    exit -1;
fi

if [[ $RATES == "" ]]; then
    RATES="31.00 32.00";
fi

mkdir -p $OUT/$LABEL

run_booster () {
    python ../../Shremote/shremote.py cfgs/inline_cache.yml ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:-k;pcap_warmup:$PCAP_WMP;pcap_test:$PCAP_TEST;out:$OUT;label:$LABEL;sub_label:${LABEL}_$1";
    RTN=$?
    RETRIES=1
    while [[ $RTN != 0 ]]; do
        echo "Trying again... $RETRIES"
        sleep 5
        python ../../Shremote/shremote.py cfgs/inline_cache.yml ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:-k;pcap_warmup:$PCAP_WMP;pcap_test:$PCAP_TEST";
        RTN=$?
        RETRIES=$(( $RETRIES + 1 ))
    done
    echo "SUCCESS!";
    sleep 5
}

for rate in $RATES; do
    run_booster $rate;
done
