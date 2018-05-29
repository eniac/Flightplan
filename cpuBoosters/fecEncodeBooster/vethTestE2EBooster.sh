#!/bin/bash

# run the empty booster.
ENCODER_NAME=fecTagEncodeBooster
FORWARD_NAME=forwardingNonbooster
DECODER_NAME=fecDecodeBooster
BOOSTER_NAME="${ENCODER_NAME}_${DECODER_NAME}"
INPUT_PCAP=$1
OUTPUT_PCAP=$(dirname "$INPUT_PCAP")/$BOOSTER_NAME/"_veth_"$(basename "$INPUT_PCAP")
ENCODED_OUTPUT_PCAP=$(dirname "$INPUT_PCAP")/$BOOSTER_NAME/"_veth_Encoded_"$(basename "$INPUT_PCAP")
echo "testing booster $BOOSTER_NAME with veth pairs."
echo "input pcap: $INPUT_PCAP"
echo "output pcap: $OUTPUT_PCAP"
echo "encoded output pcap: $ENCODED_OUTPUT_PCAP"

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

mkdir $(dirname "$INPUT_PCAP")/$BOOSTER_NAME
chown $real_user:$real_user $(dirname "$INPUT_PCAP")/$BOOSTER_NAME


# bring up veth pairs. 
# frontVeth1 = network side of cable. 
# backVeth1 = booster side of cable.
ip link add frontVeth1 type veth peer name backVeth1
sysctl net.ipv6.conf.frontVeth1.disable_ipv6=1
sysctl net.ipv6.conf.backVeth1.disable_ipv6=1
ifconfig frontVeth1 up promisc
ifconfig backVeth1 up promisc

ip link add frontVeth2 type veth peer name backVeth2
sysctl net.ipv6.conf.frontVeth2.disable_ipv6=1
sysctl net.ipv6.conf.backVeth2.disable_ipv6=1
ifconfig frontVeth2 up promisc
ifconfig backVeth2 up promisc

ip link add frontVeth3 type veth peer name backVeth3
sysctl net.ipv6.conf.frontVeth3.disable_ipv6=1
sysctl net.ipv6.conf.backVeth3.disable_ipv6=1
ifconfig frontVeth3 up promisc
ifconfig backVeth3 up promisc

ip link add frontVeth4 type veth peer name backVeth4
sysctl net.ipv6.conf.frontVeth4.disable_ipv6=1
sysctl net.ipv6.conf.backVeth4.disable_ipv6=1
ifconfig frontVeth4 up promisc
ifconfig backVeth4 up promisc

#NUM_WORKERS=8
#MAX_ID=7
NUM_WORKERS=1
MAX_ID=0

for WORKER_ID in `seq 0 $MAX_ID`
do
	echo "starting $ENCODER_NAME for worker $WORKER_ID"
	./$ENCODER_NAME -i backVeth1 -o frontVeth2 -w $WORKER_ID -t $NUM_WORKERS &
done

for WORKER_ID in `seq 0 $MAX_ID`
do
	echo "starting $FORWARD_NAME for worker $WORKER_ID"
	./$FORWARD_NAME -i backVeth2 -o frontVeth3 -w $WORKER_ID -t $NUM_WORKERS &
done

for WORKER_ID in `seq 0 $MAX_ID`
do
	echo "starting $DECODER_NAME for worker $WORKER_ID"
	./$DECODER_NAME -i backVeth3 -o frontVeth4 -w $WORKER_ID -t $NUM_WORKERS &
done


sleep 1
# start tcpdump to collect the packets that come back into the network from the device.
echo "starting tcpdump... OUTPUT_PCAP=$OUTPUT_PCAP and ENCODED_OUTPUT_PCAP=$ENCODED_OUTPUT_PCAP"
rm $OUTPUT_PCAP
tcpdump -Q in -i backVeth4 -w $OUTPUT_PCAP &
rm $ENCODED_OUTPUT_PCAP
tcpdump -Q in -i backVeth2 -w $ENCODED_OUTPUT_PCAP &
sleep 1

# start tcpreplay to send input from the network to the device (at 1k pps).
echo "starting tcpreplay..."
# do NOT use --topspeed parameter : boosters fall behind and input is lost
tcpreplay --preload-pcap --quiet --loop=1  -i frontVeth1 $INPUT_PCAP
sleep 1

# cleanup
chown $real_user:$real_user $OUTPUT_PCAP
chown $real_user:$real_user $ENCODED_OUTPUT_PCAP
killall tcpdump
killall $ENCODER_NAME
killall $FORWARD_NAME
killall $DECODER_NAME
ip link delete frontVeth1
ip link delete frontVeth2
ip link delete frontVeth3
ip link delete frontVeth4
