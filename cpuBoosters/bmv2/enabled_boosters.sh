#!/bin/bash

if [[ $BMV2_REPO == "" ]]; then
    echo "ERROR: BMV2_REPO not defined" 1>&2;
    exit -1;
fi

if [[ $# == 0 ]]; then
    echo "Usage: $0 BOOSTER_1 [BOOSTER_2 BOOSTER_3 ...]" 1>&2;
    exit -1;
fi

BOOSTER_MAKEFILE="$BMV2_REPO/targets/booster_switch/Makefile"

OUTPUT=""

for BOOSTER in $@; do
    GREP_OUT=$( grep "\-D${BOOSTER}_BOOSTER" $BOOSTER_MAKEFILE )
    if [[ ${GREP_OUT:0:1} == "#" || $GREP_OUT == "" ]]; then # If commented out
        echo "Warning: ${BOOSTER} disabled in booster_switch" 1>&2;
    else
        OUTPUT="$OUTPUT ${BOOSTER}"
    fi
done
echo $OUTPUT
