sudo tcpdump -i lo -w capture.pcap dst port 13211 &
sudo tcpdump -i lo -w output.pcap src port 13211 &
memaslap -s 127.0.0.1:13211 --udp -x 100 -F ./.memaslap.cnf
sudo killall tcpdump
sudo killall memaslap
