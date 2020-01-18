#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 input.pcap"
    exit 1
fi

HERE="`dirname $0`"
TOPO=$HERE/../topologies/tclust/tclust_compression.yml
bash $HERE/tclust_replay.sh $TOPO $1

OUTPUT="$HERE/../test_output/tclust_replay/$( basename $TOPO .yml )_$( basename $1 .pcap)"

python $HERE/../pcap_tools/pcap_size.py \
    $OUTPUT/pcap_dump/iperf_c_to_tofino1.pcap \
    $OUTPUT/pcap_dump/tofino1_to_dropper.pcap

if [[ $? != 1 ]]; then
    echo "NO COMPRESSION OCCURRED"
    exit 1
fi
exit 0
