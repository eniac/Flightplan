#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source $WHARF_REPO/splits/ALV_split1/envars.sh
source $WHARF_REPO/splits/ALV_split2/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} start

${FPControl} ${TOPOLOGY} ${FPCD2} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD2} start
