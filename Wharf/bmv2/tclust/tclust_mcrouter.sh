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

FAILURE="${RED}TEST FAILED${NC}"
SUCCESS="${GREEN}TEST SUCCEEDED${NC}"
sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --fg-host-prog "mcd_c:memtier_benchmark -s 10.0.0.101 -p 11211 -n 100 -c 1 -t 1  --hide-histogram -P memcache_text" \
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


