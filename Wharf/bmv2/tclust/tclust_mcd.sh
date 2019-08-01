#!/bin/bash

if [[ $# != 3 ]]; then
    echo "Usage $0 topo.yml input.pcap expected.pcap"
    exit 1
fi

HERE=$(realpath "`dirname $0`/../")

TOPO="$1"
INPUT=`realpath $2`
EXPECTED=`realpath $3`
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


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILURE="${RED}TEST FAILED${NC}"
SUCCESS="${GREEN}TEST SUCCEEDED${NC}"

REWRITTEN=$OUTDIR/pcap_in.pcap
python2 $HERE/pcap_tools/pcap_sub.py $INPUT $REWRITTEN \
    --sip="$SIP" --dip="$DIP" --smac="$SMAC" --dmac="$DMAC"
REWRITTEN_EXPECTED=$OUTDIR/pcap_expected.pcap
python2 $HERE/pcap_tools/pcap_sub.py $EXPECTED $REWRITTEN_EXPECTED 1 \
    --sip="$SIP" --dip="$DIP" --smac="$SMAC" --dmac="$DMAC"
sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay "mcd_c-tofino1:$REWRITTEN" \
        --host-prog "mcd_s:memcached -u $USER -U 11211 -B ascii -vvv" 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py >&2
    echo Check logs in $LOG_DUMPS for more details: >&2
    ls -1 $LOG_DUMPS/* >&2
    echo -e $FAILURE >&2
    exit -1;
fi

echo "Bytes Transferred: MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_c fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp mcd_s
echo "MCD HOSTS"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS mcd_s fpga_mcd mcd_c

python2 $HERE/pcap_tools/pcap_diff.py $PCAP_DUMPS/tofino1_to_mcd_c.pcap $REWRITTEN_EXPECTED --no-ip --clear-chksum

if [[ $? == 0  ]]; then
    echo -e $SUCCESS >&2
else
    echo -e $FAILURE >&2
    exit 1
fi
