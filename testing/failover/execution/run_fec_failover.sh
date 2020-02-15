#!/bin/bash
SUFFIX=$1

if [[ $SUFFIX == "" ]]; then
    echo "Usage: $0 SUFFIX"
    exit -1
fi

#OUTPUT=../e2e_output_200k
OUTPUT=../failover_output_2/

run_shremote() {
    BASE_LABEL=$1;
    ITER=$2;

    rtn=1

    while [[ $rtn != 0 ]]; do
        ../../Shremote/shremote.py cfgs/fec_failover.yml ${BASE_LABEL}_$ITER \
            --out $OUTPUT/$BASE_LABEL/ --delete;
        rtn=$?
        if [[ $rtn != 0 ]]; then
            echo "Execution failed... trying again";
            slackme "Experiment $BASE_LABEL - $ITER failed :("
            sleep 2
        fi
    done
}

run_shremote fec_failover $SUFFIX

slackme "Experiment set $SUFFIX completed successfully"
