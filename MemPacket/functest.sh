#!/bin/bash

if [[ $# != 1 ]]; then
    echo "Require Test Packets Folder"
    exit
fi

TEST_DIR=`realpath $1`

rm -rf test_output
mkdir test_output
OUTPUT_DIR=`realpath test_output`
INTERFACE="enp3s0f0"
HERE=`pwd`
ln -s ../Wharf/bmv2_p4/pcap_clean.py
ln -s ../Wharf/bmv2_p4/pcap_mcd_compare.py

cd $TEST_DIR
test_case=0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
ComparePkt1=c1.pcap
ComparePkt2=c2.pcap

for input_pcap in In_*.pcap; do

	[ -f "$input_pcap" ] || (echo "No input pcap found" && break)
	num=$(($num + 1))
	echo "Test Case: $test_case"
	PktsToClient="$OUTPUT_DIR/ToC_${input_pcap:3}"
	PktsToServer="$OUTPUT_DIR/ToS_${input_pcap:3}"

	#send and capture packets
	sudo tcpdump -i $INTERFACE src port 11211 -w "$PktsToClient" &
	sudo tcpdump -i $INTERFACE dst port 11211 -w "$PktsToServer" &
	sudo tcpreplay --topspeed -i $INTERFACE $input_pcap
	sleep 2
	sudo killall tcpdump

	#compare
	echo "Client packets comparation"
	ExpectToClient="OutC_${input_pcap:3}"
	python $HERE/pcap_clean.py $PktsToClient $ComparePkt1 --rm-chksum
	python $HERE/pcap_clean.py $ExpectToClient $ComparePkt2 --rm-chksum
	python $HERE/pcap_mcd_compare.py $ComparePkt1 $ComparePkt2 
	if [[ $? == 0 ]]; then
	    echo -e ${GREEN}TEST SUCCEEDED${NC}
	    echo "Check $IN_TXT $OUT_TXT to compare"
	else
	    echo -e ${RED}TEST FAILED${NC}
	    echo "Check $IN_TXT $OUT_TXT to compare"
	    exit 1
	    rm $HERE/pcap_clean.py
	    rm $HERE/pcap_mcd_compare.py
	fi
i	echo "Server packets comparation"
	ExpectToServer="OutS_${input_pcap:3}"
	python $HERE/pcap_clean.py $PktsToServer $ComparePkt1 --rm-chksum
	python $HERE/pcap_clean.py $ExpectToServer $ComparePkt2 --rm-chksum	
	if [[ $? == 0 ]]; then
	    echo -e ${GREEN}TEST SUCCEEDED${NC}
	    echo "Check $IN_TXT $OUT_TXT to compare"
	else
	    echo -e ${RED}TEST FAILED${NC}
	    echo "Check $IN_TXT $OUT_TXT to compare"
	    exit 1
	    rm $HERE/pcap_clean.py
	    rm $HERE/pcap_mcd_compare.py

	fi

		
done

echo "All Test Passed!!"
rm $HERE/pcap_clean.py
rm $HERE/pcap_mcd_compare.py




