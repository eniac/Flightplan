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
        #--time ${TIME1%s} #2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

echo "Bytes Transferred: IPERF HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s
echo "IPERF HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_s iperf_c

echo "Bytes Transferred: MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_c fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp mcd_s
echo "MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_s mcd_c
echo "DONE."
