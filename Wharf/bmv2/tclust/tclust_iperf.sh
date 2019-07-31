#!/bin/bash

HERE=$(realpath "`dirname $0`/../")

TOPO="$HERE/topologies/tclust/tclust_complete.yml"
BASENAME=$(basename $INPUT .pcap)

SIP="10.0.0.9"
DIP="10.0.0.10"
SMAC="22:11:11:11:11:21"
DMAC="22:11:11:11:11:23"

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/tclust_$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files
rm -rf $OUTDIR
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --host-prog "iperf_s:iperf3 -s -p 4242" \
        --host-prog "iperf_c:iperf3 -c 10.0.0.12 -p 4242 -M 1000" \
        --time 15

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

echo "Bytes Transferred: MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s
echo "MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_s iperf_c
