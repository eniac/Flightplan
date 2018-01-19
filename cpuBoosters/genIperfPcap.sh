# get a TCP dump of an iperf to 158.130.4.214 (jsonch's traffic generator in DSL lab)

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi
echo "starting tcpdump"
tcpdump -i enp5s0f0 -n dst host 158.130.4.214 -w ./pcaps/iperfClient2Server.pcap &
tcpdump -i enp5s0f0 -n src host 158.130.4.214 -w ./pcaps/iperfServer2Client.pcap &
sleep 1
echo "starting iperf"
# -w 2800 -- set window size to 2800 for ~1400 byte tcp payloads.
iperf3 -c 158.130.4.214 -n 5M -w 2800
sleep 1
killall tcpdump

echo "pcap written to iperfOutTrace.pcap / iperfInTrace.pcap"
chown $real_user:$real_user ./pcaps/iperfClient2Server.pcap
chown $real_user:$real_user ./pcaps/iperfServer2Client.pcap