#!/bin/bash

if [[ $# < 1 ]]; then
    echo "Usage $0 <rate> [time]"
    exit
fi

BMV2_REPO_M=$BMV2_REPO
RUNTIME_CLI_DIR=$BMV2_REPO_M/tools

if [[ $BMV2_REPO_M == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit
fi

HERE=`dirname $0`
BLD=$HERE/../build
RATE=$1
if [[ $# > 1 ]]; then
    TIME=$2
else
    TIME=10s
fi
echo "Running for $TIME"
USER=`logname`
BASENAME=nofec_iperf_$RATE

TESTDIR=$HERE/test_output
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

echo "Encoder log:"
echo tail -f `realpath $LOG_DUMPS/encoder.log`
echo "Decoder log:"
echo tail -f `realpath $LOG_DUMPS/decoder.log`
echo "Dropper log:"
echo tail -f `realpath $LOG_DUMPS/dropper.log`

sudo mn -c 
sleep 1


sudo PYTHONPATH=$RUNTIME_CLI_DIR python $HERE/fec_demo.py \
		--behavioral-exe $BMV2_REPO_M/targets/booster_switch/simple_switch \
		--encoder-json $BLD/bmv2/Complete.json \
		--decoder-json $BLD/bmv2/Complete.json \
		--dropper-json $BLD/bmv2/Dropper.json \
		--pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
		--command-file $HERE/complete_commands.txt \
        --h2-prog 'iperf3 -s -p 4242 &' \
        --h1-prog "iperf3 -c 10.0.1.1 -p 4242 -b $RATE -t $TIME -M 1000"

sleep 4

echo "DONE."
