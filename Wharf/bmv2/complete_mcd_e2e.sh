#!/bin/bash

if [[ $# != 2 ]]; then
    echo "Usage $0 <input.pcap> <expected_output.pcap>"
    exit
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit
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
rm -f $LOG_DUMPS
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

INPUT_PCAP=$OUTDIR/${BASENAME}_in.pcap
echo "Putting pcap in $INPUT_PCAP"
python $HERE/pcap_sub.py $PRE_INPUT_PCAP $INPUT_PCAP 0

sudo mn -c

sudo -E python $HERE/start_flightplan_mininet.py \
        $HERE/flightplan_mcd_topology.yml \
        --bmv2-exe $BMV2_REPO/targets/booster_switch/simple_switch \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay h1-s1:$INPUT_PCAP
sleep 4

REQ_PCAP=$OUTDIR/${BASENAME}_req.pcap
EXP_PCAP=$OUTDIR/${BASENAME}_expected.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

python $HERE/pcap_clean.py $INPUT_PCAP $REQ_PCAP --rm-chksum &
python $HERE/pcap_sub.py $EXPECTED $EXP_PCAP 1 &
python $HERE/pcap_clean.py $PCAP_DUMPS/h1_in.pcap $OUT_PCAP --rm-chksum &
wait
python $HERE/pcap_clean.py $EXP_PCAP $EXP_PCAP --rm-chksum

sleep 1
REQ_TXT=$OUTDIR/${BASENAME}_req.txt
OUT_TXT=$OUTDIR/${BASENAME}_out.txt
EXP_TXT=$OUTDIR/${BASENAME}_exp.txt

python $HERE/pcap_print.py $REQ_PCAP $REQ_TXT &
python $HERE/pcap_print.py $EXP_PCAP $EXP_TXT &
python $HERE/pcap_print.py $OUT_PCAP $OUT_TXT &
wait

sudo chown -R $USER:$USER $OUTDIR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

python $HERE/pcap_mcd_compare.py $EXP_PCAP $OUT_PCAP

if [[ $? == 0 ]]; then
    echo -e ${GREEN}TEST SUCCEEDED${NC}
    echo "Check $EXP_TXT $OUT_TXT to compare"
    exit 0
else
    echo -e ${RED}TEST FAILED${NC}
    echo "Check $EXP_TXT $OUT_TXT to compare"
    exit 1
fi

