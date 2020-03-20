#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# NOTE based on splits/ALV_Complete_2/start2.sh
set -e

echo "ALV_Complete_2_FW starting ALV_Complete_2"
/home/nsultana/2/P4Boosters/Wharf/splits/ALV_Complete_2/start2.sh

echo "Starting ALV_Complete_2_FW"

source /home/nsultana/2/P4Boosters/Wharf/splits/ALV_Complete_2_FW/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --start_switch --idx 0 --pip_state_var flightplan_pip_nak_count_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --start_switch --idx 0 --pip_state_var flightplan_pip_ackreq_interval --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --start_switch --idx 0 --pip_state_var flightplan_pip_ackreq_interval_exceed_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} start
