#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
export FPControl=$WHARF_REPO/fpctl.py
export FPCD=$WHARF_REPO/splits2/ALV_Complete_1_hl3/FPControlData.yml

if [ -z "${TOPOLOGY}" ]
then
  echo "Need to define TOPOLOGY environment variable"
  exit 1
fi
