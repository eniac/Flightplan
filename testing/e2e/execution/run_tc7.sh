#!/bin/bash

SHR=../../Shremote/shremote.py
CFG=cfgs/tc7_e2e_iperf_and_mcd.yml
BASE=tc7
OUT=../tc7_output/

for i in `seq 1 5`; do

    python $SHR $CFG ${BASE}_base_$i \
        --args "drop_rate:0;dataplane_flags:" --out ${OUT}

    sleep 10

    python $SHR $CFG ${BASE}_c_$i \
        --args "drop_rate:0;dataplane_flags:-c" --out ${OUT}

    sleep 10

    python $SHR $CFG ${BASE}_cd_$i \
        --args "drop_rate:0.05;dataplane_flags:-c" --out ${OUT}

    sleep 10

    python $SHR $CFG ${BASE}_cdf_$i \
        --args "drop_rate:0.05;dataplane_flags:-c -f" --out ${OUT}

    sleep 10

    python $SHR $CFG ${BASE}_cdfk_$i \
        --args "drop_rate:0.05;dataplane_flags:-c -f -k" --out ${OUT}

done

#for i in `seq 1 5`; do
#    python ../../Shremote/shremote.py \
#        cfgs/faster_e2e_iperf_and_mcd.yml t${i} \
#        --args "dataplane_flags:" --out ../output_combined_faster/t/
#    sleep 10
#    python ../../Shremote/shremote.py \
#        cfgs/faster_e2e_iperf_and_mcd.yml t_f_${i} \
#        --args "dataplane_flags:-f" --out ../output_combined_faster/t_f/
#    sleep 10
#    python ../../Shremote/shremote.py \
#        cfgs/faster_e2e_iperf_and_mcd.yml t_f_c_${i} \
#        --args "dataplane_flags:-f -c" --out ../output_combined_faster/t_f_c/
#    sleep 10
#    python ../../Shremote/shremote.py \
#        cfgs/faster_e2e_iperf_and_mcd.yml t_f_c_k_${i} \
#        --args "dataplane_flags:-f -c -k" --out ../output_combined_faster/t_f_c_k/
#    sleep 10
#done

#python ../../Shremote/shremote.py \
#    cfgs/e2e_iperf_and_mcd.yml fec_and_kv_3 \
#    --args "dataplane_flags:-f -k" --out ../output_combined/fec_and_kv/

