#!/bin/bash

if [[ $# != 2 ]]; then
    echo "Usage $0 <input.pcap> <expected_output.pcap>"
    exit 1
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit 1
fi

HERE=`dirname $0`
BLD=$HERE/../build

USER=`logname`
PRE_INPUT_PCAP=`realpath $1`
EXPECTED=$2

TESTDIR=$HERE/test_output
BASENAME=$(basename $PRE_INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -rf $LOG_DUMPS
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

INPUT_PCAP=$OUTDIR/${BASENAME}_in.pcap
echo "Putting pcap in $INPUT_PCAP"
python $HERE/pcap_tools/pcap_sub.py $PRE_INPUT_PCAP $INPUT_PCAP 0

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $HERE/topologies/complete_topology.yml \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay h1-s1:$INPUT_PCAP \
        --host-prog "h2:memcached -u $USER -U 11211 -B ascii -vvv" \
        2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi


REQ_PCAP=$OUTDIR/${BASENAME}_req.pcap
EXP_PCAP=$OUTDIR/${BASENAME}_expected.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

python2 $HERE/pcap_tools/pcap_clean.py $INPUT_PCAP $REQ_PCAP --rm-chksum &
python2 $HERE/pcap_tools/pcap_sub.py $EXPECTED $EXP_PCAP 1 &
python2 $HERE/pcap_tools/pcap_clean.py $PCAP_DUMPS/s1_to_h1.pcap $OUT_PCAP --rm-chksum &
wait
python2 $HERE/pcap_tools/pcap_clean.py $EXP_PCAP $EXP_PCAP --rm-chksum

REQ_TXT=$OUTDIR/${BASENAME}_req.txt
OUT_TXT=$OUTDIR/${BASENAME}_out.txt
EXP_TXT=$OUTDIR/${BASENAME}_exp.txt

python2 $HERE/pcap_tools/pcap_print.py $REQ_PCAP $REQ_TXT &
python2 $HERE/pcap_tools/pcap_print.py $EXP_PCAP $EXP_TXT &
python2 $HERE/pcap_tools/pcap_print.py $OUT_PCAP $OUT_TXT &
wait

sudo chown -R $USER:$USER $OUTDIR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


echo "Requests:"
python $HERE/pcap_tools/pcap_size.py \
    $PCAP_DUMPS/{h1_to_s1,s1_to_s2,s2_to_s3,s3_to_h2}.pcap

echo "Replies:"
python $HERE/pcap_tools/pcap_size.py \
    $PCAP_DUMPS/{h2_to_s3,s3_to_s2,s2_to_s1,s1_to_h1}.pcap


python2 $HERE/pcap_tools/pcap_mcd_compare.py $EXP_PCAP $OUT_PCAP

if [[ $? == 0 ]]; then
    echo -e ${GREEN}TEST SUCCEEDED${NC}
    echo "Check $EXP_TXT $OUT_TXT to compare"
    exit 0
else
    echo -e ${RED}TEST FAILED${NC}
    echo "Check $EXP_TXT $OUT_TXT to compare"
    exit 1
fi

