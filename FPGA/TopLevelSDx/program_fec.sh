#!/bin/bash
if [[ $# != 1 ]]; then
    echo "Usage: $0 logbase"
    exit -1
fi

LOGBASE=$1

bash program_encoder.sh > ${LOGBASE}_encod.log &
COMP=$!

bash program_decoder.sh > ${LOGBASE}_decod.log &
DECOMP=$!

echo "Waiting on encoder..."
wait $ENC
if [[ $? != 0 ]]; then
    echo "Encoder failed"
    exit $?
fi


echo "Waiting on decoder..."
wait $DECOMP
if [[ $? != 0 ]]; then
    echo "Decompressor failed"
    exit $?
fi

echo "Done."
