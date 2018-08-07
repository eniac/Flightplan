service memcached restart
sudo tcpdump -i lo -w TX.pcap dst port 11211 &
sudo tcpdump -i lo -w RX.pcap src port 11211 &
memaslap -s 127.0.0.1:11211 -x 500 -F ./.memaslap.cnf -U 
service memcached stop

