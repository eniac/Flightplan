#!/bin/bash

if [[ $# < 1 || $# > 4 ]]; then
    echo "Usage $0 topo.yml [duration] [bw] [qlen]"
    exit 1
fi

HERE=$(realpath "`dirname $0`/../" --relative-to $(pwd) )

TOPO="$1"
IPERF_TIME=$2
BW="$3"
QLEN="$4"

if [[ $BW != "" ]]; then
    BW_ARG="--bw $BW"
else
    BW="none";
fi

if [[ $QLEN != "" ]]; then
    QLEN_ARG="--qlen $QLEN"
else
    QLEN="none";
fi

if [[ $IPERF_TIME == "" ]]; then
    IPERF_TIME=100
fi

BASENAME=$(basename $TOPO .yml)

SIP="10.0.0.9"
DIP="10.0.0.10"
SMAC="00:02:c9:3a:84:00"
DMAC="7c:fe:90:1c:36:81"

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/tclust_e2e/bw_${BW}_q_${QLEN}_dur_${IPERF_TIME}/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files
TIMING_LOG=$OUTDIR/timing.txt

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

MCD_TIME=$(( $IPERF_TIME + 10 ))
N_GET=$(( $MCD_TIME * 90 ))
N_SET=$(( $MCD_TIME * 10 ))

if [ -f $TEST_PCAP ]; then
    echo "Skipping packet generation: already complete"
else
    echo "Generating $N_GET get $N_SET set packet trace $TEST_PCAP"
    python $HERE/../../MemcachedFPGATest/generate_memcached.py \
        --smac $SMAC --sip $SIP --dmac $DMAC --dip $DIP \
        --out $TEST_PCAP --warmup-out $WARMUP_PCAP \
        --n-get $N_GET --n-set $N_SET \
        --key-space 10000 --zipf 1.00 > $LOG_DUMPS/pkt_gen.out
fi

N_WARMUP=$( tcpdump -qr $WARMUP_PCAP | wc -l )
STARTUP_DELAY=5
WARMUP_TIME=$(( $N_WARMUP / 100 + 5 ))
IPERF_DELAY=5

echo "$STARTUP_DELAY # STARTUP_DELAY
$WARMUP_TIME # WARMUP_TIME
$IPERF_DELAY # IPERF_DELAY
$IPERF_TIME # IPERF_LENGTH" > $TIMING_LOG

TEST_START=$(( $STARTUP_DELAY + $WARMUP_TIME ))
IPERF_START=$(( $TEST_START + $IPERF_DELAY ))
TOTAL_TIME=$(( $IPERF_START + $IPERF_TIME ))


sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --host-prog "mcd_s:memcached -u $USER -U 11211 -B ascii" \
        --host-prog "mcd_c:sleep $STARTUP_DELAY && tcpreplay -i mcd_c-eth0 -p 100 $WARMUP_PCAP" \
        --host-prog "mcd_c:sleep $STARTUP_DELAY  && tcpreplay -i mcd_c-eth0 -p 100 $WARMUP_PCAP" \
        --host-prog "mcd_c:sleep $TEST_START  && tcpreplay -i mcd_c-eth0 -p 100 $TEST_PCAP" \
        --host-prog "iperf_s:iperf3 -s -p 4242" \
        --host-prog "iperf_c:sleep $IPERF_START  && iperf3 -P 10 -t $IPERF_TIME -c 10.0.0.12 -p 4242 -M 1000 -J -i 1" \
        --pcap-to mcd_c --pcap-from mcd_c $BW_ARG $QLEN_ARG \
        --time $TOTAL_TIME  2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py >&2
    echo Check logs in $LOG_DUMPS for more details: >&2
    ls -1 $LOG_DUMPS/* >&2
    echo -e $FAILURE >&2
    exit -1;
fi

#echo "Bytes Transferred: iperf"
#python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s iperf_c
#
#echo "Bytes Transferred: mcd"
#python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_c fpga_mcd mcd_s fpga_mcd mcd_c
