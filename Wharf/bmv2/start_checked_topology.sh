
if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test"
    exit 1
fi

HERE=`dirname $0`
BLD=$HERE/../build

USER=`logname`
TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/checked/
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -rf $OUTDIR
mkdir -p $LOG_DUMPS
mkdir -p $PCAP_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

TOPO=$HERE/topologies/complete_topology_checked.yml

sudo -E python $HERE/start_flightplan_mininet.py \
    $TOPO \
    --pcap-dump $PCAP_DUMPS \
    --log $LOG_DUMPS \
    --verbose \
    --host-prog "h1:python $HERE/flightplan_packet.py h1-eth0" \
    --time 2 \
    2> $LOG_DUMPS/flightplan_mininet_log.err

echo "Bytes Transferred:"
python2 $HERE/pcap_tools/pcap_size.py \
    $PCAP_DUMPS/{h1_to_s1,s1_to_s2,s2_to_s3,s3_to_h2}.pcap

echo 

python2 $HERE/pcap_tools/pcap_size.py \
    $PCAP_DUMPS/{h2_to_s3,s3_to_s2,s2_to_s1,s1_to_h1}.pcap
