#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Usage $0 input.pcap"
    exit 1
fi

HERE="`dirname $0`"
TOPO=$HERE/../topologies/tclust/tclust_fec_and_hc.yml
bash $HERE/tclust_replay.sh $TOPO $1
