#!/bin/bash

if [[ $# != 2 ]]; then
    echo "Usage $0 input.pcap expected.pcap"
    exit 1
fi


HERE=$(realpath "`dirname $0`/../")
TOPO="$HERE/topologies/tclust/tclust_mcd_complete.yml"

$HERE/tclust/tclust_mcd.sh $TOPO $1 $2
exit $?
