#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

echo "Starting ALV_Complete_1 (hl2)"

source /home/nsultana/2/P4Boosters/Wharf/splits2/ALV_Complete_1_hl2/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless_ipv4
# NOTE "start" not needed in --headerless_ipv4 mode
