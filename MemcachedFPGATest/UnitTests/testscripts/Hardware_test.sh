RECV_CLIENT=fpga@client.pcap
RECV_SERVER=fpga@server.pcap
echo Please Make Sure the Memcached Service is NOT Running.
if [ $# != 2 ]
then
	echo ERROR: Require network interface and pcap file to send as inputs
else
	echo Starting tcpdump to capture response memcached packets
	sudo tcpdump -Q in -i $1 src port 11211 -w $RECV_CLIENT &
	sudo tcpdump -Q in -i $1 dst port 11211 -w $RECV_SERVER &
	echo Sending $2 through $1 
        sudo tcpreplay --topspeed -i $1 $2
	sleep 5
	echo Waiting for recving all pkts... 
	sudo killall tcpdump	
fi
