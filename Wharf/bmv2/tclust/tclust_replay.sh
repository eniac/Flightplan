#!/bin/bash

if [[ $# != 2 ]]; then
    echo "Usage $0 topo.yml input.pcap"
    exit 1
fi

HERE="`dirname $0`/../"

TOPO="$1"
INPUT=`realpath $2`
BASENAME=$(basename $INPUT .pcap)

SIP="10.0.0.11"
DIP="10.0.0.12"
SMAC="22:11:11:11:11:20"
DMAC="22:11:11:11:11:22"

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/tclust_$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files
rm -rf $OUTDIR
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILURE="${RED}TEST FAILED${NC}"
SUCCESS="${GREEN}TEST SUCCEEDED${NC}"

REWRITTEN=$OUTDIR/pcap_in.pcap
python2 $HERE/pcap_tools/pcap_sub.py $INPUT $REWRITTEN \
    --sip="$SIP" --dip="$DIP" --smac="$SMAC" --dmac="$DMAC"

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay "iperf_c-tofino1:$REWRITTEN" \
        --time 1 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    echo -e $FAILURE >&2
    exit -1;
fi

echo "Bytes Transferred: forwards"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s
echo "Bytes Transferred: backwards"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_s iperf_c

python2 $HERE/pcap_tools/pcap_diff.py $PCAP_DUMPS/iperf_c_to_tofino1.pcap $PCAP_DUMPS/tofino2_to_iperf_s.pcap

if [[ $? == 0 ]]; then
    echo "No difference between packets!"
    echo -e $SUCCESS >&2
    exit 0
else
    echo "Difference between input and output"
    echo -e $FAILURE >&2
    exit 1
fi
