#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, August 2020
set -e

echo "Starting ALV_qos (hl3new)"

source $WHARF_REPO/splits3/ALV_qos_hl3new/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force --headerless_new
# NOTE "start" not needed in --headerless mode
