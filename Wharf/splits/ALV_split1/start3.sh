#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
#${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_nak_count_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_ackreq_interval_exceed_max --value 200
#${FPControl} ${TOPOLOGY} ${FPCD} set_count_ack_relinks --switch p0e0 --next_segment 2
${FPControl} ${TOPOLOGY} ${FPCD} start
