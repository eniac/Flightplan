iperf -c 10.0.0.2 -t 20 &
sleep 3
sudo ping 10.0.0.1 -i .001 -c 10000 > pingLog.txt
