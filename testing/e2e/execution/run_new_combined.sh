#!/bin/bash
for i in `seq 1 3`; do

    python ../../Shremote/shremote.py \
        cfgs/new_e2e_iperf_and_mcd.yml new_c_$i \
            --args "drop_rate:0;dataplane_flags:-c" --out ../output_swap/
    sleep 10
done

exit 0

for i in `seq 1 3`; do

    python ../../Shremote/shremote.py \
        cfgs/new_e2e_iperf_and_mcd.yml new_t_$i \
            --args "drop_rate:0;dataplane_flags:-t" --out ../output_swap/
    sleep 10
    python ../../Shremote/shremote.py \
        cfgs/new_e2e_iperf_and_mcd.yml new_tc_$i \
        --args "drop_rate:0;dataplane_flags:-t -c" --out ../output_swap/
    sleep 10
    python ../../Shremote/shremote.py \
        cfgs/new_e2e_iperf_and_mcd.yml new_tdc_$i \
            --args "drop_rate:0.05;dataplane_flags:-t -c" --out ../output_swap/
    sleep 10
    python ../../Shremote/shremote.py \
        cfgs/new_e2e_iperf_and_mcd.yml new_tdcf_$i \
            --args "drop_rate:0.05;dataplane_flags:-t -c -f" --out ../output_swap/
    sleep 10
    python ../../Shremote/shremote.py \
        cfgs/new_e2e_iperf_and_mcd.yml new_tdcfk_$i \
            --args "drop_rate:0.05;dataplane_flags:-t -c -f -k" --out ../output_swap/
    sleep 10
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

