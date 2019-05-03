#!/bin/bash

usage() {
    echo "Usage $0 <test_file.pcap>"
    exit 1
}


if [[ $# != 1 ]]; then
    usage;
    exit 1
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit 1
fi

HERE=`dirname $0`
BLD=$HERE/../build

USER=`logname`
INPUT_PCAP=`realpath $1`

TESTDIR=$HERE/test_output
BASENAME=$(basename $INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/sample_extern_obj_$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -rf $OUTDIR
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

TOPO=$HERE/topologies/sample_extern_obj_topology.yml;

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --log $LOG_DUMPS \
        --verbose \
        --replay h1-s1:$INPUT_PCAP 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

echo
echo Showing dumps from switch 1: $LOG_DUMPS/s1.log
echo "**********"
echo

grep --color=always -B2 -A2 SampleExtern $LOG_DUMPS/s1.log | head -50
