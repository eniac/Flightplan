#!/bin/bash

if [[ $# != 2 ]]; then
    echo "Usage $0 <input.pcap> <expected_output.pcap>"
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

USER=`logname`
PRE_INPUT_PCAP=`realpath $1`
EXPECTED=$2

TESTDIR=$HERE/test_output
BASENAME=$(basename $PRE_INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

INPUT_PCAP=$OUTDIR/${BASENAME}_in.pcap
echo "Putting pcap in $INPUT_PCAP"
python $HERE/pcap_sub.py $PRE_INPUT_PCAP $INPUT_PCAP 0

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
		--command-file $HERE/complete_commands.txt \
        --h2-prog "memcached -vv -u $USER -U 11211 -l 10.0.1.1 -B ascii > $LOG_DUMPS/mcd_out.txt 2> $LOG_DUMPS/mcd_err.txt  &" \
		--e2e $INPUT_PCAP  \
        --dropper-pcap $HERE/lldp_enable_fec.pcap \
        #--log-console $LOG_DUMPS \ log-console creates too many logs!

sleep 4

REQ_PCAP=$OUTDIR/${BASENAME}_req.pcap
EXP_PCAP=$OUTDIR/${BASENAME}_expected.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

python $HERE/pcap_clean.py $INPUT_PCAP $REQ_PCAP --rm-chksum &
python $HERE/pcap_sub.py $EXPECTED $EXP_PCAP 1 &
python $HERE/pcap_clean.py $PCAP_DUMPS/h1_in.pcap $OUT_PCAP --rm-chksum &
wait
python $HERE/pcap_clean.py $EXP_PCAP $EXP_PCAP --rm-chksum

sleep 1
REQ_TXT=$OUTDIR/${BASENAME}_req.txt
OUT_TXT=$OUTDIR/${BASENAME}_out.txt
EXP_TXT=$OUTDIR/${BASENAME}_exp.txt

python $HERE/pcap_print.py $REQ_PCAP $REQ_TXT &
python $HERE/pcap_print.py $EXP_PCAP $EXP_TXT &
python $HERE/pcap_print.py $OUT_PCAP $OUT_TXT &
wait

sudo chown -R $USER:$USER $OUTDIR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

python $HERE/pcap_mcd_compare.py $EXP_PCAP $OUT_PCAP

if [[ $? == 0 ]]; then
    echo -e ${GREEN}TEST SUCCEEDED${NC}
    echo "Check $EXP_TXT $OUT_TXT to compare"
    exit 0
else
    echo -e ${RED}TEST FAILED${NC}
    echo "Check $EXP_TXT $OUT_TXT to compare"
    exit 1
fi

