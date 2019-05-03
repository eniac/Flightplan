echo "***** RUNNING FEC E2E *****"
./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap

if [[ $? != 0 ]]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "***** RUNNING FEC E2E TWO_HALVES=1*****"
TWO_HALVES=1 ./bmv2/complete_fec_e2e.sh bmv2/pcaps/tcp_100.pcap

if [[ $? != 0 ]]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "***** RUNNING MCD E2E *****"
./bmv2/complete_mcd_e2e.sh bmv2/pcaps/Memcached_in_short.pcap bmv2/pcaps/Memcached_expected_short.pcap

if [[ $? != 0 ]]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi

echo "***** RUNNING COMPRESSION E2E *****"
./bmv2/compressor_e2e.sh bmv2/pcaps/collidingFlows.pcap

if [[ $? != 0 ]]; then
    echo "FAILED";
else
    echo "SUCCESS";
fi
