#!/bin/bash
# Wrapper script to run experiment
#Nik Sultana, UPenn, August 2020

NUM_PINGS=$1
for (( COUNT=1; COUNT<=${NUM_PINGS}; COUNT++ ))
do
  `dirname "$0"`/send.py 192.3.1.2 "Flightplan test ${COUNT}" --dst_id 1
  sleep 1
done
