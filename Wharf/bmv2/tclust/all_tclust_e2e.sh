#!/bin/bash

HERE=`dirname $0`
BW=$1

run_exp() {
    $HERE/tclust_e2e.sh $HERE/../topologies/tclust/$1 $BW;
}

run_exp tclust_noop.yml
run_exp tclust_compression.yml
run_exp tclust_drop_compression.yml
run_exp tclust_fec_and_hc.yml
run_exp tclust_complete.yml
