#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, March 2020
#
# FIXME hardcoded paths
# FIXME this and other scripts assume that it's being run in the "Wharf" directory

export TOPOLOGY=$WHARF_REPO/splits/ALV_FW/alv_k=4.yml

source `dirname "$0"`/../../run_alv.sh
