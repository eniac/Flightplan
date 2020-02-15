#!/bin/bash
# Nik Sultana, UPenn, July 2019

for HOST in `seq 1 254`
do
  ping -c1 192.168.1.${HOST} -I eno2 2>&1 > /dev/null &
done
