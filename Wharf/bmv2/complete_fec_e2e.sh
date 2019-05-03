#!/bin/bash

usage() {
    echo "Usage $0 <test_file.pcap> [--no-header-compression]"
    exit 1
}


if [[ $# < 1 || $# > 2 ]]; then
    usage;
    exit 1
fi

if [[ $BMV2_REPO == "" ]]; then
    echo "Must set BMV2_REPO before running this test!"
    exit 1
fi

NO_HC=0

if [[ $# > 1 ]]; then
    ## getopt parsing:
    for PARAM in ${@:2}; do
        case $PARAM in
            --no-header-compression)
                NO_HC=1
                ;;
            *)
                usage
                ;;
        esac
    done
fi


HERE=`dirname $0`
BLD=$HERE/../build

USER=`logname`
INPUT_PCAP=`realpath $1`

TESTDIR=$HERE/test_output
BASENAME=$(basename $INPUT_PCAP .pcap)
OUTDIR=$TESTDIR/$BASENAME
PCAP_DUMPS=$OUTDIR/pcap_dump/
LOG_DUMPS=$OUTDIR/log_files/
rm -rf $OUTDIR
rm -f $OUTDIR/*.pcap
rm -f $OUTDIR/pcap_dump/*.pcap
mkdir -p $PCAP_DUMPS
mkdir -p $LOG_DUMPS

sudo mn -c 2> $LOG_DUMPS/mininet_clean.err

if [[ $NO_HC == 0  ]]; then
    echo "Using complete topology WITH header compression";
    if [[ $TWO_HALVES == "" ]]; then
        TOPO=$HERE/topologies/complete_topology.yml;
    elif [[ $TWO_HALVES == "1" ]]; then
        TOPO=$HERE/topologies/complete_topology_split.yml;
    elif [[ $TWO_HALVES == "2" ]]; then
        TOPO=$HERE/topologies/complete_topology_split_further.yml;
    fi
else
    echo "Using complete topology WITHOUT header compression";
    TOPO=$HERE/topologies/complete_no_hc_topology.yml
fi

sudo -E python $HERE/start_flightplan_mininet.py \
        $TOPO \
        --pcap-dump $PCAP_DUMPS \
        --log $LOG_DUMPS \
        --verbose \
        --replay h1-s1:$INPUT_PCAP 2> $LOG_DUMPS/flightplan_mininet_log.err

if [[ $? != 0 ]]; then
    echo Error running flightplan_mininet.py
    echo Check logs in $LOG_DUMPS for more details:
    ls -1 $LOG_DUMPS/*
    exit -1;
fi

cp $INPUT_PCAP $OUTDIR/input.pcap
IN_PCAP=$OUTDIR/${BASENAME}_in.pcap
OUT_PCAP=$OUTDIR/${BASENAME}_out.pcap

python2 $HERE/pcap_tools/pcap_clean.py  $PCAP_DUMPS/h1_to_s1.pcap $IN_PCAP --rm-chksum
python2 $HERE/pcap_tools/pcap_clean.py $PCAP_DUMPS/h2_from_s3.pcap $OUT_PCAP --rm-chksum

OUT_TXT=$OUTDIR/${BASENAME}_out.txt
IN_TXT=$OUTDIR/${BASENAME}_in.txt

IN_SRT=$OUTDIR/sorted_in.txt
OUT_SRT=$OUTDIR/sorted_out.txt

tcpdump -XXtenr $IN_PCAP > $IN_TXT
tcpdump -XXtenr $OUT_PCAP > $OUT_TXT

INLINES=$(cat $IN_TXT | wc -l)
OUTLINES=$(cat $OUT_TXT | wc -l)

sort $IN_TXT > $IN_SRT
sort $OUT_TXT > $OUT_SRT

sudo chown -R $USER:$USER $OUTDIR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo Bytes Transferred:
if [[ $TWO_HALVES == "2" ]]; then
  python2 $HERE/pcap_tools/pcap_size.py \
      $PCAP_DUMPS/{h1_to_s1,s1_to_s1compress,s1compress_to_s1,s1_to_s2,s2_to_s3,s3_to_h2}.pcap
else
  python2 $HERE/pcap_tools/pcap_size.py \
      $PCAP_DUMPS/{h1_to_s1,s1_to_s2,s2_to_s3,s3_to_h2}.pcap
fi


if [[ $INLINES == $OUTLINES ]]; then
    echo "Input and output both contain $INLINES lines"
    echo "Running diff:"
    diff $IN_SRT $OUT_SRT | head -100
    echo "Diff complete (possibly truncated)"

    if [[ $INLINES == 0 ]]; then
        echo -e ${RED}TEST FAILED${NC}
        exit 1;
    fi

    if [[ `diff $IN_SRT $OUT_SRT | wc -l` != '0' ]]; then
        echo -e ${RED}TEST FAILED${NC}
        echo "Check $IN_TXT $OUT_TXT to compare"
        exit 1
    else
        echo -e ${GREEN}TEST SUCCEEDED${NC}
        exit 0
    fi
else
    echo -e "Difference between input and output:\n"
    diff $IN_SRT $OUT_SRT | head -100
    echo "(diff possibly truncated)"

    echo "Input and output contain different number of lines!"
    echo "($INLINES and $OUTLINES)"
    echo "Check $IN_TXT $OUT_TXT to compare"
    echo -e ${RED}TEST FAILED${NC}
    exit 1
fi

