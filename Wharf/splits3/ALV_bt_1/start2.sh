#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, August 2020
set -e

echo "Starting ALV_bt_1"

source $WHARF_REPO/splits3/ALV_bt_1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0e1 --idx 0 --pip_state_var flightplan_pip_nak_count_max --value 0
# Had situation in simulation where excessive ACKs were putting too much pressure on the simulation and causing weird results.
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0e1 --idx 0 --pip_state_var flightplan_pip_ackreq_interval --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0e1 --idx 0 --pip_state_var flightplan_pip_ackreq_interval_exceed_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} start
