#!/bin/bash
OUT=$1
LABEL=$2
RATES=$3

if [[ $LABEL == "" || $OUT == "" ]]; then
    echo "usage $0 OUT LABEL RATES"
    exit -1;
fi

if [[ $RATES == "" ]]; then
    RATES=".00 $(seq -f "%.02f" 2 2 30)";
fi

mkdir -p $OUT/$LABEL

run_booster () {
    python ../../Shremote/shremote.py cfgs/tofino_moongen.yml ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:-k" --delete;
    RTN=$?
    RETRIES=1
    while [[ $RTN != 0 ]]; do
        echo "Trying again... $RETRIES"
        sleep 5
        python ../../Shremote/shremote.py cfgs/tofino_moongen.yml ${LABEL}_$1 --out $OUT/$LABEL --args="rate:$1;dataplane_flags:-k" --delete;
        RTN=$?
        RETRIES=$(( $RETRIES + 1 ))
    done
    echo "SUCCESS!";
    sleep 5
}

for rate in $RATES; do
    run_booster $rate;
done
