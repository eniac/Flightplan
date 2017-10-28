#!/bin/bash

# This script generates a random packet of the specified argument size.
# Test whether command-line argument is present (non-empty).
if [ -n "$1" ]
then
	payloadSize=$1
else
	echo "usage : ./randomPacketGen.sh <size_of_payload> <numOfPackets>"
	exit 1;
fi


if [ -n "$2" ]
then
	numOfPackets=$2
else
	echo "usage : ./randomPacketGen.sh <size_of_payload> <numOfPackets>"
	exit 1;
fi

# generate random data and send it as a packet 
for (( c=0; c<$numOfPackets; c++ )); do 
	base64 /dev/urandom | head -c $payloadSize | netcat localhost 8080;
	sleep 1;
done