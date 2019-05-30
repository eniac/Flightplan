#!/bin/bash

if [[ $# > 2 ]]; then
    echo "Usage $0 <rate> [time]"
    exit 1
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit 1
fi

HERE=`dirname $0`
BLD=$HERE/../build

RATE=$1

if [[ $RATE == "" ]]; then
    RATE=0;
fi

if [[ $# > 1 ]]; then
    TIME=$2
else
    TIME=10s
fi

USER=`logname`
BASENAME=fec_iperf_$RATE

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -rf $LOG_DUMPS
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $HERE/topologies/complete_topology.yml \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --host-prog "h2:iperf3 -s -p 4242" \
        --host-prog "h1:iperf3 -c 10.0.1.1 -p 4242 -b $RATE -t $TIME -M 1000" \
        --time ${TIME%s} 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

cat $LOG_DUMPS/h1_prog_1.log

echo "DONE."
