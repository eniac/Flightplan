#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 topo.yml"
    exit 1
fi

HERE=$(realpath "`dirname $0`/../" --relative-to $(pwd) )

TOPO="$1"
BASENAME=$(basename $TOPO .yml)

SIP="10.0.0.9"
DIP="10.0.0.10"
SMAC="22:11:11:11:11:21"
DMAC="22:11:11:11:11:23"

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/tclust_e2e_$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files
rm -rf $PCAP_DUMPS $LOG_DUMPS $OUTDIR
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILURE="${RED}TEST FAILED${NC}"
SUCCESS="${GREEN}TEST SUCCEEDED${NC}"

WARMUP_PCAP=$OUTDIR/warmup.pcap
TEST_PCAP=$OUTDIR/test.pcap


if [ -f $TEST_PCAP ]; then
    echo "Skipping packet generation: already complete"
else
    echo "Generating packet trace $TEST_PCAP"
    python $HERE/../../MemcachedFPGATest/generate_memcached.py \
        --smac $SMAC --sip $SIP --dmac $DMAC --dip $DIP \
        --out $TEST_PCAP --warmup-out $WARMUP_PCAP \
        --n-get 4500 --n-set 500 \
        --key-space 10000 --zipf 1.00 > $LOG_DUMPS/pkt_gen.out
fi

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --host-prog "mcd_s:memcached -u $USER -U 11211 -B ascii" \
        --host-prog "mcd_c:sleep 2 && tcpreplay -i mcd_c-eth0 -p 100 $WARMUP_PCAP" \
        --host-prog "mcd_c:sleep 8 && tcpreplay -i mcd_c-eth0 -p 100 $TEST_PCAP" \
        --host-prog "iperf_s:sleep 10 && iperf3 -s -p 4242" \
        --host-prog "iperf_c:sleep 10 && iperf3 -t 40 -c 10.0.0.12 -p 4242 -M 1000 -J -i .1" \
        --time 60  2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py >&2
    echo Check logs in $LOG_DUMPS for more details: >&2
    ls -1 $LOG_DUMPS/* >&2
    echo -e $FAILURE >&2
    exit -1;
fi

echo "Bytes Transferred: iperf"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s iperf_c

echo "Bytes Transferred: mcd"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_c fpga_mcd mcd_s fpga_mcd mcd_c
