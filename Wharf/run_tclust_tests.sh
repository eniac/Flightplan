#!/bin/bash -e

LOG_DIR=bmv2/test_output/tclust_test_output

mkdir -p ${LOG_DIR}

tclust_test() {
  TITLE=$1
  SCRIPT=bmv2/tclust/$2
  PCAP=bmv2/pcaps/$3
  VISIBLE_FLAG=$4


  if [[ $VISIBLE_FLAG == "" ]]; then
    VISIBLE=0
  elif [[ $VISIBLE_FLAG == "--visible" ]]; then
    VISIBLE=1
  else
    echo "tclust_test() usage: TITLE SCRIPT_BASENAME PCAP_BASENAME [--visible]"
    exit 1
  fi

  OUTPUT="$LOG_DIR/$TITLE"
  echo "Running $TITLE"

  if [[ $VISIBLE == "1" ]]; then
    bash $SCRIPT
  else
    echo "$SCRIPT $PCAP > $OUTPUT.stdout"
    bash $SCRIPT $PCAP > $OUTPUT.stdout
  fi

  if [ $? -eq 0 ]; then
      echo "SUCCESS";
  else
      echo "FAILED";
  fi
}

tclust_test no_op tclust_noop.sh tcp_100.pcap
tclust_test hc_oneFlow tclust_compression.sh oneFlow.pcap
tclust_test hc_twoFlows tclust_compression.sh twoFlows.pcap
tclust_test fec tclust_fec.sh tcp_100.pcap
tclust_test hc_fec_twoFlows tclust_fec_and_hc.sh twoFlows.pcap
