#!/bin/sh

echo "FEC_E2E"
./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap > FEC_E2E.stdout 2> FEC_E2E.stderr
if [ $? -eq 0 ]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "FEC_E2E_2-1 (TWO_HALVES=1)"
TWO_HALVES=1 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap > FEC_E2E_2-1.stdout 2> FEC_E2E_2-1.stderr
if [ $? -eq 0 ]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "FEC_E2E_2-2 (TWO_HALVES=2)"
TWO_HALVES=2 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap > FEC_E2E_2-2.stdout 2> FEC_E2E_2-2.stderr
if [ $? -eq 0 ]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "MCD_E2E"
./bmv2/complete_mcd_e2e.sh bmv2/pcaps/Memcached_in_short.pcap bmv2/pcaps/Memcached_expected_short.pcap > MCD_E2E.stdout 2> MCD_E2E.stderr
if [ $? -eq 0 ]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "HC_E2E"
./bmv2/compressor_e2e.sh bmv2/pcaps/collidingFlows.pcap > HC_E2E.stdout 2> HC_E2E.stderr
if [ $? -eq 0 ]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi
