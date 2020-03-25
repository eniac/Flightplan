#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch p0e0 --next_segment 2 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch FPoffload --next_segment 3 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch FPoffload2 --next_segment 3 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_seqno --value 26

${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_nak_count --value 4
${FPControl} ${TOPOLOGY} ${FPCD} unset_drop_outgoing --switch p0e0 --next_segment 2
${FPControl} ${TOPOLOGY} ${FPCD} set_drop_outgoing --switch p0e0 --next_segment 2