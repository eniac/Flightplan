#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
export FPControl=/home/nsultana/2/P4Boosters/Wharf/fpctl.py
export FPCD=/home/nsultana/2/P4Boosters/Wharf/splits2/ALV_Complete_1_hl2/FPControlData.yml

if [ -z "${TOPOLOGY}" ]
then
  echo "Need to define TOPOLOGY environment variable"
  exit 1
fi
