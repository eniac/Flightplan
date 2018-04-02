#!/bin/bash -e

K=8
H=4
PACKET_COUNT=100
PAYLOAD_LENGTH=64

GENERATOR=../../../Utilities/PacketGenerator/PacketGenerator.py

$GENERATOR -t text -b $PACKET_COUNT -l $PAYLOAD_LENGTH -k $K -f $H Packet.user
$GENERATOR -t axi -b $PACKET_COUNT -l $PAYLOAD_LENGTH -k $K -f 0 Packet_feedback_in.axi

for i in $(seq $PACKET_COUNT)
do
  for j in $(seq $K)
  do
    echo "40"
  done
  for j in $(seq $H)
  do
    echo "30"
  done
done > Tuple.user

