tcpdump -i lo -w capture.pcap dst port 11211 &
tcpdump -i lo -w output.pcap src port 11211 -w capture.pcap &
memaslap -s 127.0.0.1:11211 -x 500 -F ./.memaslap.cnf -U 


