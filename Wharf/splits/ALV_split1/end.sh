#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

HERE=`pwd`

source $HERE/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} get_state
${FPControl} ${TOPOLOGY} ${FPCD} get_pip_state
${FPControl} ${TOPOLOGY} ${FPCD} get_drop_outgoing --switch p0e0 --next_segment 2
${FPControl} ${TOPOLOGY} ${FPCD} get_count_ack_relinks --switch p0e0 --next_segment 2
