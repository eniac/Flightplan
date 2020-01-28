#!/bin/bash

if [[ $# > 1 ]]; then
    echo "Usage $0 [--complete]"
    exit 1
fi

if [[ $# == 1 && $1 != "--complete" ]]; then
    echo "Usage $0 [--complete]"
    exit 1;
fi


HERE="$(realpath `dirname $0`/../ --relative-to $(pwd))"
BASENAME="snort"

if [[ $1 == '--complete' ]]; then
    TOPO=$HERE/topologies/tclust/tclust_snort_complete.yml
    BASENAME+='_complete'
else
    TOPO=$HERE/topologies/tclust/tclust_snort_only.yml
fi

INPUT=$HERE/pcaps/tcp_100.pcap

SIP="10.0.0.11"
DIP="10.0.0.12"
SMAC="24:8a:07:8f:eb:00"
DMAC="24:8a:07:5b:15:35"

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
        --host-prog "iperf_c:ping -i .2 10.0.0.12" \
        --time 5 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py >&2
    echo Check logs in $LOG_DUMPS for more details: >&2
    ls -1 $LOG_DUMPS/* >&2
    echo -e $FAILURE >&2
    exit -1;
fi

echo "Bytes Transferred: forwards"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c snort fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s
echo "Bytes Transferred: backwards"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_s iperf_c

RTN=0
python2 $HERE/pcap_tools/pcap_diff.py --extras-ok $REWRITTEN $PCAP_DUMPS/tofino2_to_iperf_s.pcap

if [[ $? == 0 ]]; then
    echo "No difference between packets packets sent by client to server!"
else
    echo "Difference between input and output to server"
    echo -e $FAILURE >&2
    RTN=1
fi

python2 $HERE/pcap_tools/pcap_diff.py --no-ip $INPUT $PCAP_DUMPS/tofino1_to_snort.pcap

if [[ $? == 0 ]]; then
    echo "No difference between TCP packets replayed by client and snort received!"
else
    echo "Difference between input and output to snort"
    echo -e $FAILURE >&2
    RTN=1
fi

SNORT_LOG=$LOG_DUMPS/snort_prog_1.log
N_RECEIVED=$(grep Received $SNORT_LOG | sed -e 's/\s\+Received:\s\+//g')
N_SENT=$(tcpdump -qr $INPUT | wc -l)

if [[ $N_RECEIVED != $N_SENT ]]; then
    echo "Snort did not receive and process all $N_SENT packets: only $N_RECEIVED"
    echo -e $FAILURE >&2
    RTN=1
else
    echo "Snort received all $N_SET packets"
fi

if [[ $RTN == 0 ]]; then
    echo -e $SUCCESS >&2
fi

exit $RTN
