#!/bin/bash
# Nik Sultana, UPenn, July 2019

source config.sh

for IDX in ${RANGE}
do
  echo "Logging power of ${NAME[$IDX]}"
  ./power_read.sh ${IDX} >> power_${IDX}.out 2>> power_${IDX}.err &
done
