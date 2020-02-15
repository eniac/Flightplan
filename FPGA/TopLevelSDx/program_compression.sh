#!/bin/bash
if [[ $# != 1 ]]; then
    echo "Usage: $0 logbase"
    exit -1
fi

LOGBASE=$1

bash program_compressor.sh > ${LOGBASE}_comp.log &
COMP=$!

bash program_decompressor.sh > ${LOGBASE}_decomp.log &
DECOMP=$!

echo "Waiting on compressor..."
wait $ENC
if [[ $? != 0 ]]; then
    echo "Encoder failed"
    exit $?
fi


echo "Waiting on decompressor..."
wait $DECOMP
if [[ $? != 0 ]]; then
    echo "Decompressor failed"
    exit $?
fi

echo "Done."
