#!/bin/bash
LOGBASE=$1

time bash program_encoder.sh 2>&1 > ${LOGBASE}_enc.log&
ENC=$!
time bash program_decoder.sh 2>&1 > ${LOGBASE}_dec.log&
DEC=$!
time bash program_memcached.sh 2>&1 > ${LOGBASE}_mem.log&
MCD=$!
time bash program_compressor.sh 2>&1 > ${LOGBASE}_comp.log&
COM=$!
time bash program_decompressor.sh 2>&1 > ${LOGBASE}_decomp.log&
DCOM=$!

echo "Waiting on encoder..."
time wait $ENC
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "Encoder failed"
    exit $?
fi

echo "Waiting on decoder..."
time wait $DEC
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "Decoder failed"
    exit $?
fi

echo "Waiting on mcd..."
time wait $MCD
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "Memcached failed"
    exit $RTN
fi

echo "Waiting on compressor..."
time wait $COM
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "Compressor failed"
    exit $RTN
fi

echo "Waiting on decompressor..."
time wait $DCOM
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "Decompressor failed"
    echo $RTN
fi

echo "Done."

