#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
export FPControl=$WHARF_REPO/fpctl.py

if [ -z "${TOPOLOGY}" ]
then
  echo "Need to define TOPOLOGY environment variable"
  exit 1
fi
