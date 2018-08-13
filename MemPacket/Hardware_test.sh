echo Please Make Sure the Memcached Service is NOT Running.
if [ $# != 3 ]
then
	echo ERROR: Require network interface and Packet to send as inputs
else
	echo Starting tcpdump to capture response memcached packets
	sudo tcpdump -i $1 src port 11211 -w $3 &
	echo Sending $2 through $1 
        sudo tcpreplay --topspeed -i $1 $2
	sleep 5 
	sudo killall tcpdump	
fi
