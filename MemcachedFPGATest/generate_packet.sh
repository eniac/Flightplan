sudo killall tcpdump
sudo service memcached stop
memcached  -U 11211  -l 127.0.0.1 -B ascii&
sudo tcpdump -i lo -w TX.pcap dst port 11211 &
sudo tcpdump -i lo -w RX.pcap src port 11211 &
sleep 0.5
echo "Starting memaslap"
memaslap -c 1 -s 127.0.0.1:11211 -x 10 -F ./memaslap.cnf -U 
echo Wait 3s to make sure all packets are captured 
sleep 2

sudo killall memcached
sudo killall tcpdump
