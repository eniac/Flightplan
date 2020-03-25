#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
set -e

source /home/nsultana/2/P4Boosters/Wharf/splits/ALV_split1/envars.sh

${FPControl} ${TOPOLOGY} ${FPCD} configure_flightplan --force
${FPControl} ${TOPOLOGY} ${FPCD} start