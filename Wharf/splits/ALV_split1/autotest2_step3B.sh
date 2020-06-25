#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source $WHARF_REPO/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} get_pip_state
${FPControl} ${TOPOLOGY} ${FPCD} get_state

${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch p0e0 --next_segment 2 --value 2
${FPControl} ${TOPOLOGY} ${FPCD} check_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_nak_count --value 0
${FPControl} ${TOPOLOGY} ${FPCD} check_pip_state --switch FPoffload --idx 0 --pip_state_var flightplan_pip_nak_count --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_pip_state --switch FPoffload2 --idx 0 --pip_state_var flightplan_pip_nak_count --value 0
