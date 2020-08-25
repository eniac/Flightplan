#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, August 2020
export FPControl=$WHARF_REPO/fpctl.py
export FPCD=$WHARF_REPO/splits3/ALV_bt_1/FPControlData.yml

if [ -z "${TOPOLOGY}" ]
then
  echo "Need to define TOPOLOGY environment variable"
  exit 1
fi
