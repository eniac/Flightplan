#!/bin/sh

LOG_DIR=regression_test_output

mkdir -p ${LOG_DIR}

do_test() {
  TITLE=$1
  FILENAME=$2
  CMD=$3
  echo "${TITLE}"
  eval ${CMD} > ${LOG_DIR}/${FILENAME}.stdout 2> ${LOG_DIR}/${FILENAME}.stderr
  if [ $? -eq 0 ]; then
      echo "SUCCESS";
  else
      echo "FAILED";
  fi
}

do_test "FEC_E2E" "FEC_E2E" "./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap"
do_test "FEC_E2E_2-1 (TWO_HALVES=1)" "FEC_E2E_2-1" "TWO_HALVES=1 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap"
do_test "FEC_E2E_2-2 (TWO_HALVES=2)" "FEC_E2E_2-2" "TWO_HALVES=2 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap"
do_test "MCD_E2E" "MCD_E2E" "./bmv2/complete_mcd_e2e.sh bmv2/pcaps/Memcached_in_short.pcap bmv2/pcaps/Memcached_expected_short.pcap"
do_test "HC_E2E" "HC_E2E" "./bmv2/compressor_e2e.sh bmv2/pcaps/collidingFlows.pcap"
