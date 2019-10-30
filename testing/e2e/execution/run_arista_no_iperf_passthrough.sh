#!/bin/bash
SUFFIX=$1

if [[ $SUFFIX == "" ]]; then
    echo "Usage: $0 SUFFIX"
    exit -1
fi

#OUTPUT=../e2e_output_200k
OUTPUT=../e2e_output_500k_arista_no_iperf_passthrough

run_shremote() {
    DROP_RATE=$1;
    FLAGS="$2";
    BASE_LABEL=$3;
    ITER=$4;

    rtn=1

    for i in $(seq 1 5); do
        ../../Shremote/shremote.py cfgs/arista_e2e_no_iperf_passthrough_500k.yml ${BASE_LABEL}_$ITER \
            --args "drop_rate:$DROP_RATE;dataplane_flags:$FLAGS" \
            --out $OUTPUT/$BASE_LABEL/ --delete;
        rtn=$?
        if [[ $rtn != 0 ]]; then
            echo "Execution failed... trying again";
            sleep 2
        else
            break
        fi
    done
}

run_shremote 0 "" baseline $SUFFIX
run_shremote 0 "-fc" hc $SUFFIX
run_shremote 0.05 "-fc" drop $SUFFIX
run_shremote 0.05 "-f -fc" fec $SUFFIX
run_shremote 0.05 "-f -fc -k" kv $SUFFIX
