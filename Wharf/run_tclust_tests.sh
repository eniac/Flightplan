#!/bin/bash -e

LOG_DIR=bmv2/test_output/tclust_test_output

mkdir -p ${LOG_DIR}

tclust_test() {
  TITLE=$1
  SCRIPT=bmv2/tclust/$2
  PCAP=bmv2/pcaps/$3
  if [[ $# == 4 ]]; then
      EXPECTED=bmv2/pcaps/$4
  else
      EXPECTED=""
  fi

  OUTPUT="$LOG_DIR/$TITLE"
  echo "Running $TITLE"

  if [[ $VISIBLE == "1" ]]; then
    bash $SCRIPT $PCAP $EXPECTED
  else
    echo "$SCRIPT $PCAP $EXPECTED > $OUTPUT.stdout"
    bash $SCRIPT $PCAP $EXPECTED > $OUTPUT.stdout
  fi

  if [ $? -eq 0 ]; then
      echo "SUCCESS";
  else
      echo "FAILED";
  fi
}

tclust_test replay_complete tclust_complete.sh tcp_100.pcap
tclust_test mcd_complete tclust_mcd_complete.sh Memcached_in_short.pcap Memcached_expected_short.pcap
tclust_test no_op tclust_noop.sh tcp_100.pcap
tclust_test hc_oneFlow tclust_compression.sh oneFlow.pcap
tclust_test hc_twoFlows tclust_compression.sh twoFlows.pcap
tclust_test fec tclust_fec.sh tcp_100.pcap
tclust_test hc_fec_twoFlows tclust_fec_and_hc.sh twoFlows.pcap
tclust_test mcd_only tclust_mcd_only.sh Memcached_in_short.pcap Memcached_expected_short.pcap
