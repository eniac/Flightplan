#### Dpdk Scripts ####

Scripts to install and use DPDK packet generator. 

##### Installation #####
1. ./installDpdk.sh -- install dpdk to ./dpdkInstall/dpdk-stable-17.08.1 (with connectx4 drivers)
2. ./installPktgen.sh -- install pkt generator to ./dpdkInstall/pktgen-3.4.9 (with 1 GB for pcap rx)

##### Usage #####
1. ./runPktGen.sh -- start pktGen using 2 cores for rx and 2 cores for tx on the first ethernet interface available to DPDK (i.e., the mellanox cards).
*note:* pktGen needs a large terminal window to display properly.
2. ./runThroughput.sh -- run pktGen with a script to send packets out of port 1 and count packets on port 2 for 10 seconds.
2. ./runPcapThroughput.sh -- run pktGen with a script to send packets from pcaps/iperfClient2Server.pcap out of port 1 and count packets on port 2 for 10 seconds. Pcap is loaded into memory and looped.

##### pktgen scripts #####
runThroughput.sh and runPcapThroughput.sh use luaScripts/throughput.lua.

Read the getting started guide for more information on how to use pktGen: 
http://pktgen-dpdk.readthedocs.io/en/latest/running.html

and more about command line options:
http://pktgen-dpdk.readthedocs.io/en/latest/usage_pktgen.html