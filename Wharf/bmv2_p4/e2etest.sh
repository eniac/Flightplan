#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 <test_file.pcap>"
fi

BMV2_REPO_M=$BMV2_REPO

INPUT_PCAP=`realpath $1`

TESTDIR=test_output
BASENAME=$(basename $INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/$BASENAME
mkdir -p $OUTDIR

THISDIR=`pwd`

cd $OUTDIR

sudo python $THISDIR/fec_demo.py \
		--behavioral-exe $BMV2_REPO_M/targets/booster_switch/simple_switch \
		--encoder-json $THISDIR/Encoder.json \
		--decoder-json $THISDIR/Decoder.json \
		--dropper-json $THISDIR/Dropper.json \
		--pcap-dump dump \
		--e2e $INPUT_PCAP

sleep 2

cd $THISDIR

IN_PCAP=$OUTDIR/${BASENAME}_in.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

cp $INPUT_PCAP $IN_PCAP
cp $OUTDIR/s2-eth1_in.pcap $OUT_PCAP

sleep 2
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

