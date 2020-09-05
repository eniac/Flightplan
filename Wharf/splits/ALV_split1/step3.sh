#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source $WHARF_REPO/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch p0e0 --next_segment 2 --value 0
${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch SA_1 --next_segment 3 --value 1
${FPControl} ${TOPOLOGY} ${FPCD} check_state --switch SA_2 --next_segment 3 --value 1
