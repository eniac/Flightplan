#!/usr/bin/env bash
#Test setup for Flightplan
#Nik Sultana, UPenn, August 2020
#
# FIXME this and other scripts assume that it's being run in the "Wharf" directory

export TOPOLOGY=$WHARF_REPO/splits3/ALV_bt_1/alv_k=4.yml
export EXPERIMENT_INIT=$WHARF_REPO/splits3/ALV_bt_1/start2.sh

source $WHARF_REPO/splits3/ALV_bt/tests.sh
