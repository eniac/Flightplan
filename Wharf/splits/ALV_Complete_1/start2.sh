#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source /home/nsultana/2/P4Boosters/Wharf/splits/ALV_Complete_1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0a0 --idx 0 --pip_state_var flightplan_pip_nak_count_max --value 0
# Had situation in simulation where excessive ACKs were putting too much pressure on the simulation and causing weird results.
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0a0 --idx 0 --pip_state_var flightplan_pip_ackreq_interval --value 0
${FPControl} ${TOPOLOGY} ${FPCD} set_pip_state --switch p0a0 --idx 0 --pip_state_var flightplan_pip_ackreq_interval_exceed_max --value 0
${FPControl} ${TOPOLOGY} ${FPCD} start
