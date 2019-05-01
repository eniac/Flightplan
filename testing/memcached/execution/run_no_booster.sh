#!/bin/bash
OUT=$1
LABEL=$2
ZIPF=$3
RATES=$4

if [[ $LABEL == "" || $OUT == "" ]]; then
    echo "usage $0 OUT LABEL ZIPF RATES"
    exit -1;
fi

if [[ $ZIPF == "" ]]; then
    echo "Setting ZIPF=0.9";
    ZIPF=0.9
fi

if [[ $RATES == "" ]]; then
    RATES="0.10 0.50 1.00 $(seq -f "%.02f" 2 2 30)";
fi

mkdir -p $OUT/$LABEL

run_booster () {
    python ../../Shremote/shremote.py cfgs/tofino_moongen.yml ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:" --delete;
    RTN=$?
    RETRIES=1
    while [[ $RTN != 0 ]]; do
        echo "Trying again... $RETRIES"
        sleep 5
        python ../../Shremote/shremote.py cfgs/tofino_moongen.yml ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:" --delete;
        RTN=$?
        RETRIES=$(( $RETRIES + 1 ))
    done
    echo "SUCCESS!";
    sleep 5
}

for rate in $RATES; do
    run_booster $rate;
done
