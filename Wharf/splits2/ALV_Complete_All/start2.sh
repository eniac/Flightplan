#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# NOTE based on splits/ALV_Complete_2_FW/start2.sh
set -e

echo "ALV_Complete_All starting ALV_Complete_2_FW"
/home/nsultana/2/P4Boosters/Wharf/splits/ALV_Complete_2_FW/start2.sh

echo "Starting ALV_Complete_All"
PROG_PATH=/home/nsultana/2/P4Boosters/Wharf/splits2/ALV_Complete_All
source ${PROG_PATH}/envars.sh
FPCD=${PROG_PATH}/FPControlData_R2.yml
${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} start
FPCD=${PROG_PATH}/FPControlData_HL_V2.yml
${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless_new
FPCD=${PROG_PATH}/FPControlData_HL_V3.yml
${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless_new
# NOTE "start" not needed in --headerless mode
