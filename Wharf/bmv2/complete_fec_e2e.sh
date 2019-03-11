#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 <test_file.pcap>"
    exit
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit
fi

HERE=`dirname $0`
BLD=$HERE/../build

USER=`logname`
INPUT_PCAP=`realpath $1`

TESTDIR=$HERE/test_output
BASENAME=$(basename $INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -f $LOG_DUMPS
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

echo "Encoder log:"
echo tail -f `realpath $LOG_DUMPS/encoder.log`
echo "Decoder log:"
echo tail -f `realpath $LOG_DUMPS/decoder.log`
echo "Dropper log:"
echo tail -f `realpath $LOG_DUMPS/dropper.log`

sudo mn -c

sudo -E python $HERE/flightplan_mininet.py \
        $HERE/flightplan_fec_topology.yml \
		--bmv2-exe $BMV2_REPO/targets/booster_switch/simple_switch \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay h1-s1:$INPUT_PCAP

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

sleep 4

IN_PCAP=$OUTDIR/${BASENAME}_in.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

python $HERE/pcap_clean.py  $PCAP_DUMPS/h1_out.pcap $IN_PCAP --ipv4-only
python $HERE/pcap_clean.py $PCAP_DUMPS/h2_in.pcap $OUT_PCAP --ipv4-only

sleep 1
OUT_TXT=$OUTDIR/${BASENAME}_out.txt
IN_TXT=$OUTDIR/${BASENAME}_in.txt

IN_SRT=$OUTDIR/sorted_in.txt
OUT_SRT=$OUTDIR/sorted_out.txt

tcpdump -XXtenr $IN_PCAP > $IN_TXT
tcpdump -XXtenr $OUT_PCAP > $OUT_TXT

INLINES=$(cat $IN_TXT | wc -l)
OUTLINES=$(cat $OUT_TXT | wc -l)

sort $IN_TXT > $IN_SRT
sort $OUT_TXT > $OUT_SRT

sudo chown -R $USER:$USER $OUTDIR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [[ $INLINES == $OUTLINES ]]; then
    echo "Input and output both contain $INLINES lines"
    echo "Running diff:"
    diff $IN_SRT $OUT_SRT
    echo "Diff complete"

    if [[ $INLINES == 0 ]]; then
        echo -e ${RED}TEST FAILED${NC}
        exit 1;
    fi

    if [[ `diff $IN_SRT $OUT_SRT | wc -l` != '0' ]]; then
        echo -e ${RED}TEST FAILED${NC}
        exit 1
    else
        echo -e ${GREEN}TEST SUCCEEDED${NC}
        exit 0
    fi
else
    echo -e "Difference between input and output:\n"
    diff $IN_SRT $OUT_SRT | head 100
    echo "(diff possibly truncated)"

    echo "Input and output contain different number of lines!"
    echo "($INLINES and $OUTLINES)"
    echo "Check $IN_TXT $OUT_TXT to compare"
    echo -e ${RED}TEST FAILED${NC}
    exit 1
fi

