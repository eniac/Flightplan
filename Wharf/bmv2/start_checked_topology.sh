
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

# FIXME hardcoded pcap file
sudo -E python $HERE/start_flightplan_mininet.py \
    $TOPO \
    --pcap-dump $PCAP_DUMPS \
    --log $LOG_DUMPS \
    --verbose \
    --time 2 \
    --replay h1-s1:bmv2/pcaps/tcp_100.pcap \
    2> $LOG_DUMPS/flightplan_mininet_log.err
# Previously experimented with following traffic from h1
#    --host-prog "h1:python $HERE/flightplan_packet.py h1-eth0" \
#    --host-prog "h1:ping -c 10 -I h1-eth0 192.168.1.1" \

echo "Bytes Transferred:"
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS h1 h2
echo ""
python2 $HERE/pcap_tools/pcap_path_size.py $TOPO $PCAP_DUMPS h2 h1
