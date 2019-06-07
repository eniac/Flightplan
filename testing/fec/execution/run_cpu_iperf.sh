#!/bin/bash
OUT=$1
LABEL=$2
REPS=$3
DROP_RATES=$4

if [[ $LABEL == "" ]]; then
    echo "usage $0 OUT LABEL [REPS] [DROP_RATE]"
    exit -1
fi

if [[ $REPS == "" ]]; then
    REPS=1
fi

if [[ "$DROP_RATES" == "" ]]; then
    DROP_RATES="0 0.0001 0.001 0.01 0.02 0.03 0.04 0.05 0.1"
fi


SHR=../../Shremote/shremote.py
CFG=cfgs/cpu_iperf.yml

mkdir -p $OUT/$LABEL

for i in `seq 1 $REPS`; do

    for DROP_RATE in $DROP_RATES; do

        python $SHR $CFG ${LABEL}_drop_${DROP_RATE}_rep_${i} \
            --args "drop_rate:$DROP_RATE" --out $OUT/$LABEL

        RTN=$?

        if [[ $RTN != 0 ]] ; then
            echo "I FAILED"
            exit -1
        fi

        sleep 5

    done
done
