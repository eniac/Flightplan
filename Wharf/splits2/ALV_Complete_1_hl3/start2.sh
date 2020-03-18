#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

echo "Starting ALV_Complete_1 (hl3)"

source /home/nsultana/2/P4Boosters/Wharf/splits2/ALV_Complete_1_hl3/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless
# NOTE "start" not needed in --headerless mode
