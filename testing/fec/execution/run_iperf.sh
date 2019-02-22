#!/bin/bash

SHR=../../Shremote/shremote.py
CFG=cfgs/iperf.yml
BASE=iperf
OUT=../iperf_output/

for i in `seq 1 10`; do

    for DROP in 0 0.0001 0.001 0.01 0.02 0.03 0.04 0.05 0.1; do

        python $SHR $CFG ${BASE}_${DROP}_nofec_${i} \
            --args "drop_rate:$DROP;dataplane_flags:" --out ${OUT}/nofec/

        sleep 10

        python $SHR $CFG ${BASE}_${DROP}_fec_${i} \
            --args "drop_rate:$DROP;dataplane_flags:-f" --out ${OUT}/fec/

        sleep 10
    done

done
