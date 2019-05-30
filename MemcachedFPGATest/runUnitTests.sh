#!/bin/bash
NUMBER_OF_TESTS=3
cd UnitTests
for i in $(seq $NUMBER_OF_TESTS); do
	Test="Test$i"
	echo "$Test:"
	cd $Test
	rm *.pcap
	rm *.log
	./test.sh
	cd ..
	echo ""
done


