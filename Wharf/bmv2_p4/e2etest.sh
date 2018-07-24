#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 <test_file.pcap>"
    exit
fi

BMV2_REPO_M=$BMV2_REPO

if [[ $BMV2_REPO_M == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit
fi

USER=`logname`
INPUT_PCAP=`realpath $1`

TESTDIR=test_output
BASENAME=$(basename $INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

echo "Encoder log:"
echo tail -f `realpath $LOG_DUMPS/encoder.log`
echo "Decoder log:"
echo tail -f `realpath $LOG_DUMPS/decoder.log`
echo "Dropper log:"
echo tail -f `realpath $LOG_DUMPS/dropper.log`

sleep 2

sudo python ./fec_demo.py \
		--behavioral-exe $BMV2_REPO_M/targets/booster_switch/simple_switch \
		--encoder-json build/EncoderBM.json \
		--decoder-json build/DecoderBM.json \
		--dropper-json build/Dropper.json \
		--pcap-dump $PCAP_DUMPS \
		--e2e $INPUT_PCAP \
        --log-console $LOG_DUMPS

sleep 2

IN_PCAP=$OUTDIR/${BASENAME}_in.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

cp $INPUT_PCAP $IN_PCAP
cp $PCAP_DUMPS/s2-eth2_in.pcap $OUT_PCAP

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

    if [[ `diff $IN_SRT $OUT_SRT | wc -l` != '0' ]]; then
        echo -e ${RED}TEST FAILED${NC}
        exit 1
    else
        echo -e ${GREEN}TEST SUCCEEDED${NC}
        exit 0
    fi
else
    echo -e "Difference between input and output:\n"
    diff $IN_SRT $OUT_SRT
    echo ""

    echo "Input and output contain different number of lines!"
    echo "($INLINES and $OUTLINES)"
    echo "Check $IN_TXT $OUT_TXT to compare"
    echo -e ${RED}TEST FAILED${NC}
    exit 1
fi

