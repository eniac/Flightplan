sudo killall tcpdump
service memcached restart
sudo tcpdump -i lo -w TX.pcap dst port 11211 &
sudo tcpdump -i lo -w RX.pcap src port 11211 &
sleep 0.5
memaslap -s 127.0.0.1:11211 -x 100 -F ./.memaslap.cnf -U 
echo Wait 3s to make sure all packets are captured 
sleep 2

service memcached stop
sudo killall tcpdump
