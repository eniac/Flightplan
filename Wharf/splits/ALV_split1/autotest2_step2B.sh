#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source $WHARF_REPO/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch p0e0 --next_segment 2 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch SA_1 --next_segment 3 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch SA_2 --next_segment 3 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_pip_state --switch p0e0 --idx 0 --pip_state_var flightplan_pip_nak_count --value 4

${FPControl} ${TOPOLOGY} ${FPCD} unset_drop_outgoing --switch p0e0 --next_segment 2
