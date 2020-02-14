#!/bin/bash

HERE=`dirname $0`
DUR=$1
BW=$2
QLEN=$3

run_exp() {
    #echo Running "$HERE/tclust_e2e.sh $HERE/../topologies/tclust/$1 $DUR $BW $QLEN;"
    $HERE/tclust_e2e.sh $HERE/../topologies/tclust/$1 $DUR $BW $QLEN;
    sleep 2
}

run_exp tclust_noop.yml
run_exp tclust_compression.yml
run_exp tclust_drop_compression.yml
run_exp tclust_fec_and_hc.yml
run_exp tclust_complete.yml
