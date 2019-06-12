#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 <test_file.pcap>"
    exit 1
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit 1
fi

INPUT_PCAP=$1
HERE=`dirname $0`
TESTDIR=$HERE/test_output
BASENAME=$(basename $INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/HC_$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/

rm -rf $OUTDIR
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $HERE/topologies/compression_topology.yml \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay h1-s1:$INPUT_PCAP 2> $LOG_DUMPS/flightlpan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running start_flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

echo Comparing $PCAP_DUMPS/h1_to_s1.pcap and $PCAP_DUMPS/s2_to_h2.pcap
python $HERE/pcap_tools/comparePcaps.py $PCAP_DUMPS/h1_to_s1.pcap $PCAP_DUMPS/s2_to_h2.pcap

if [[ $? == 0 ]]; then
    echo Bytes Transferred:
    python $HERE/pcap_tools/pcap_size.py  $PCAP_DUMPS/{h1_to_s1,s1_to_s2,s2_to_h2}.pcap
fi
