#!/bin/bash
LOGBASE=$1

bash program_encoder.sh > ${LOGBASE}_enc.log&
ENC=$!
bash program_decoder.sh > ${LOGBASE}_dec.log&
DEC=$!
bash program_memcached.sh > ${LOGBASE}_mem.log&
MCD=$!

echo "Waiting on encoder..."
wait $ENC
if [[ $? != 0 ]]; then
    echo "Encoder failed"
    exit $?
fi

echo "Waiting on decoder..."
wait $DEC
if [[ $? != 0 ]]; then
    echo "Decoder failed"
    exit $?
fi

echo "Waiting on mcd..."
wait $MCD
if [[ $? != 0 ]]; then
    echo "Memcached failed"
    exit $?
fi

echo "Done."

