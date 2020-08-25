#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

echo "Starting ALV_Complete_2 (hl3)"

source $WHARF_REPO/splits2/ALV_Complete_2_hl3/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless
# NOTE "start" not needed in --headerless mode
