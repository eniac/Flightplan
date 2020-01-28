#!/bin/bash

if [[ $# > 1 ]]; then
    echo "Usage $0 [--complete]"
    exit 1
fi
if [[ $# > 0 && $1 != "--complete" ]]; then
    echo "Usage $0 [--complete]"
    exit 1;
fi

HERE=$(realpath $(dirname $0)/../ --relative-to `pwd`)
if [[ $# == 0 ]]; then
    TOPO="$HERE/topologies/tclust/tclust_mcrouter.yml"
else
    TOPO="$HERE/topologies/tclust/tclust_mcrouter_complete.yml"
fi

export MCROUTER_CFG="$HERE/tclust/mcrouter_config.json"
BASENAME=$(basename $TOPO .yml)

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

BGSRC_IP="10.0.0.1"
BGSRC_MAC="24:8a:07:8f:eb:00"
BGDST_IP="10.0.0.2"
BGDST_MAC="24:8a:07:5b:15:35"

### Need to send packets in the background so that FEC will forward packets through
# TODO: should use timeout instead of forcing packets through with replays
BGINPUT=$HERE/pcaps/tcp_100.pcap
BGINPUT_REWRITTEN=$OUTDIR/bg_traffic.pcap
python2 $HERE/pcap_tools/pcap_sub.py $BGINPUT $BGINPUT_REWRITTEN \
    --sip=$BGSRC_IP --dip=$BGDST_IP --smac=$BGSRC_MAC --dmac=$BGDST_MAC


FAILURE="${RED}TEST FAILED${NC}"
SUCCESS="${GREEN}TEST SUCCEEDED${NC}"
sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

N_SETS=50
N_GETS=60

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --host-prog "iperf_c:tcpreplay -i iperf_c-eth0 -p 5 $BGINPUT_REWRITTEN" \
        --fg-host-prog "mcd_c:sleep 2 && memtier_benchmark -s 10.0.0.101 -p 11211 -n $N_SETS -c 1 -t 1  --hide-histogram -P memcache_text --ratio 1:0 --key-pattern=S:S" \
        --fg-host-prog "mcd_c:memtier_benchmark -s 10.0.0.101 -p 11211 -n $N_GETS -c 1 -t 1  --hide-histogram -P memcache_text --ratio 0:1 --key-pattern=S:S" \
        --time 1 2> $LOG_DUMPS/flightplan_mininet_log.err

RTN=$?
echo "Bytes Transferred: MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_c fpga_mcd mcrouter fpga_comp fpga_encd fpga_decd fpga_dcomp mcd_s
echo
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_s fpga_mcd mcd_c

cat $LOG_DUMPS/mcd_c_prog_0.log

if [[ $RTN != 0 ]]; then
    echo Error running flightplan_mininet.py >&2
    echo Check logs in $LOG_DUMPS for more details: >&2
    ls -1 $LOG_DUMPS/* >&2
    echo -e $FAILURE >&2
    exit -1;
fi

# STORED packets are all unique, so have to --include-tcp when counting responses
# (shouldn't be duplicates, since no drops between mcrouter and client)
N_BACK=`python $HERE/pcap_tools/pcap_count_unique.py $PCAP_DUMPS/tofino1_to_mcd_c.pcap --include-tcp`
N_MCD=`python $HERE/pcap_tools/pcap_count_unique.py $PCAP_DUMPS/tofino2_to_mcd_s.pcap`

if [[ $N_BACK != $(( $N_SETS + $N_GETS)) ]]; then
    ERROR="Number of returned psh packets incorrect ( $N_BACK != $(( $N_SETS + $N_GETS )) )"
else
    echo "Verified $N_BACK data packets sent to mcd_c"
fi

N_EXPECTED=$(( $N_GETS > $N_SETS ? $N_GETS : $N_SETS ))

if [[ $N_MCD != $N_EXPECTED ]]; then
    ERROR+="Number of packets delivered to mcd incorrect ( $N_MCD != $N_EXPECTED )"
else
    echo "Verified $N_MCD data packets sent to mcd_s"
fi

if [[ $ERROR != "" ]]; then
    echo "Error: $ERROR" >&2
    echo -e $FAILURE >&2
    exit -1;
fi

echo -e $SUCCESS >& 2
