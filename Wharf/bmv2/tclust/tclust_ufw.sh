#!/bin/bash

COMPLETE=0
DESCRIBE=0
while [ "${1:-}" != "" ]; do
    case "$1" in
      "-c" | "--complete")
        COMPLETE=1
        ;;
      "-d" | "--describe")
        DESCRIBE=1
        ;;
       *)
        echo "Usage $0 [--complete] [--describe]"
        echo "(--describe option shows only the script's purpose)"
        exit 1
    esac
    shift
done

if [[ $DESCRIBE == 1 ]]; then
echo "::: $0 :::
In this test, two sets of packets are sent (using tcpreplay) between the hosts iperf_c and iperf_s.
One set of packets is sent to port 80, the other to port 666.

Packets are routed by the 'tofino1' switch through a host running ufw.
Ufw is set to discard packets sent to port 666.

The test ensures there is no difference between the set of packets sent to port 80,
and those received by iperf_s.

If the --complete option is provided, traffic is also routed through the
compressor, encoder, dropper, decoder, and decompressor, and the same
validity checks are performed.
"
exit 0
fi

HERE="$(realpath `dirname $0`/../ --relative-to $(pwd))"
BASENAME="tcp_ufw_both"

if [[ $COMPLETE == 1 ]]; then
    TOPO=$HERE/topologies/tclust/tclust_ufw_complete.yml
    BASENAME+='_complete'
else
    TOPO=$HERE/topologies/tclust/tclust_ufw_only.yml
fi

INPUT_THRU=$HERE/pcaps/tcp_100.pcap
INPUT_BLOCK=$HERE/pcaps/tcp_666.pcap


SIP="10.0.0.11"
DIP="10.0.0.12"
SMAC="24:8a:07:8f:eb:00"
DMAC_S="24:8a:07:5b:15:35"
DMAC_UFW="e4:43:4b:1e:40:44"

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/tclust_ufw/tclust_$BASENAME
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

REWRITTEN_THRU=$OUTDIR/pcap_in_thru.pcap
REWRITTEN_BLOCK=$OUTDIR/pcap_in_block.pcap
python2 $HERE/pcap_tools/pcap_sub.py $INPUT_THRU $REWRITTEN_THRU \
    --sip="$SIP" --dip="$DIP" --smac="$SMAC" --dmac="$DMAC_UFW"
python2 $HERE/pcap_tools/pcap_sub.py $INPUT_BLOCK $REWRITTEN_BLOCK \
    --sip="$SIP" --dip="$DIP" --smac="$SMAC" --dmac="$DMAC_UFW"

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay "iperf_c-tofino1:$REWRITTEN_THRU" \
        --replay "iperf_c-tofino1:$REWRITTEN_BLOCK" \
        --time 1 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py >&2
    echo Check logs in $LOG_DUMPS for more details: >&2
    ls -1 $LOG_DUMPS/* >&2
    echo -e $FAILURE >&2
    exit -1;
fi

echo "Bytes Transferred: forwards"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_c ufw fpga_mcd fpga_comp fpga_encd fpga_decd fpga_dcomp iperf_s
echo "Bytes Transferred: backwards"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS iperf_s iperf_c

python2 $HERE/pcap_tools/pcap_diff.py --no-ip $REWRITTEN_THRU $PCAP_DUMPS/tofino2_to_iperf_s.pcap

if [[ $? == 0 ]]; then
    echo "No difference between packets!"
    echo -e $SUCCESS >&2
    exit 0
else
    echo "Difference between input and output"
    echo -e $FAILURE >&2
    exit 1
fi
