#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# NOTE based on splits/ALV_Complete_1/start2.sh
set -e

echo "ALV_Complete_3 starting ALV_Complete_2"
$WHARF_REPO/splits/ALV_Complete_2/start2.sh

echo "Starting ALV_Complete_3"

source $WHARF_REPO/splits/ALV_Complete_3/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch c0 --idx 0 --pip_state_var flightplan_pip_nak_count_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch c0 --idx 0 --pip_state_var flightplan_pip_ackreq_interval --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch c0 --idx 0 --pip_state_var flightplan_pip_ackreq_interval_exceed_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} start
