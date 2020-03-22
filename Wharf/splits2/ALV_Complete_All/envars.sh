#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
export FPControl=/home/nsultana/2/P4Boosters/Wharf/fpctl.py

if [ -z "${TOPOLOGY}" ]
then
  echo "Need to define TOPOLOGY environment variable"
  exit 1
fi
