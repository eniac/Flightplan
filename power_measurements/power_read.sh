#!/bin/bash
# Nik Sultana, UPenn, July 2019

source config.sh

IDX=$1

while true
do
  echo `date --rfc-3339=ns` `./get_one.sh ${IDX}`
  sleep 0.1s
done
