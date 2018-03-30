#!/bin/bash -e

PAYLOAD_LENGTH=64

GENERATOR=../../../Utilities/PacketGenerator/PacketGenerator.py

$GENERATOR -t text -l $PAYLOAD_LENGTH Packet.user
$GENERATOR -t axi -f 0 -l $PAYLOAD_LENGTH Packet_feedback_in.axi

for i in $(seq 3)
do
  for j in $(seq 8)
  do
    echo "40"
  done
  for j in $(seq 4)
  do
    echo "30"
  done
done > Tuple.user

