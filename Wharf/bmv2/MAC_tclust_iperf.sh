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

# TIME- seconds to run the iperf
# TIME1- seconds to run the mininet topology
# TIME1 > TIME
if [[ $# > 1 ]]; then
    TIME=$2
    TIME1=`expr $2 + 5`
else
    TIME=10s
    TIME1=15s
fi


USER=`logname`
BASENAME=tclust_MAC_fec_iperf_$RATE

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$TESTDIR/checked/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -rf $LOG_DUMPS
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

TOPO=$HERE/topologies/MAC_tclust_topology.yml

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --host-prog "iperf_s:iperf3 -s -p 4242" \
        --host-prog "iperf_c:iperf3 -c 10.0.0.12 -p 4242 -b $RATE -t $TIME -M 1000" \
	--time ${TIME1%s} 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

cat $LOG_DUMPS/iperf_c_prog_1.log

echo "Bytes Transferred:"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c fpga_enc tofino1 fpga_dec iperf_s
echo ""
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_s iperf_c

echo "DONE."
