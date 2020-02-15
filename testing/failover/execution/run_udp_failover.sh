#!/bin/bash
SUFFIX=$1

if [[ $SUFFIX == "" ]]; then
    echo "Usage: $0 SUFFIX"
    exit -1
fi

OUTPUT=../failover_output_6/fec/

run_shremote() {
    BASE_LABEL=$1;
    ITER=$2;
    CFG=$3;
    args=$4

    rtn=1

    while [[ $rtn != 0 ]]; do
        ../../Shremote/shremote.py $CFG ${BASE_LABEL}_$ITER \
            --out $OUTPUT/$BASE_LABEL/ --delete $args;
        rtn=$?
        if [[ $rtn != 0 ]]; then
            echo "Execution failed... trying again";
            slackme "Experiment $BASE_LABEL - $ITER failed :("
            sleep 2
        fi
    done
}

#run_shremote fec_udp_failover_100  $SUFFIX cfgs/fec_udp_failover.yml "--args=poll_time:0.1"
run_shremote fec_udp_failover_020  $SUFFIX cfgs/fec_udp_failover.yml "--args=poll_time:0.02"
run_shremote fec_udp_failover_010  $SUFFIX cfgs/fec_udp_failover.yml "--args=poll_time:0.01"
run_shremote fec_udp_failover_001  $SUFFIX cfgs/fec_udp_failover.yml "--args=poll_time:0.001"
#run_shremote fec_udp_failover_000  $SUFFIX cfgs/fec_udp_failover.yml "--args=poll_time:0"

slackme "Experiment set $SUFFIX completed successfully"
