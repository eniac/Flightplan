#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

echo "Starting ALV_Complete_1 (hl3new)"

source $WHARF_REPO/splits2/ALV_Complete_1_hl3new/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless_new
# NOTE "start" not needed in --headerless mode
