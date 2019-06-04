#!/bin/bash
NUMBER_OF_TESTS=3
INTERFACE=enp3s0f1
cd UnitTests
for i in $(seq $NUMBER_OF_TESTS); do
	Test="Test$i"
	echo "$Test:"
	cd $Test
	rm *.pcap
	rm *.log
	./fpgatest.sh $INTERFACE
	cd ..
	echo ""
done


