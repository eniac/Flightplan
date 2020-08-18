#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source $WHARF_REPO/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} start
