Architecture

tclust1(10.0.0.1)----------------->dcomp1(10.0.0.101)----->FORWARDS

1) tclust1 sends a udp packet to 10.0.0.105:11230 via the 10.0.0.101 machine. i.e, set the routing table on tclust1 to have its gateway as 10.0.0.101 for any IP address in the 10.0.0.0/24 network. 

2) Add arp entry for 10.0.0.101 on tclust1
   Add arp entry for 10.0.0.1 on dcomp1

3) On tofino, from the pointToPoint topology run 
	./stop.sh
	./run.sh 1-112

Setting ufw rules on dcomp1, prior to all the above steps:

Inorder for the forwarding rule to work, in /etc/ufw/sysctl.conf, uncomment ipv4.forwarding=1

Let the default forward policy be DROP. Set this in /etc/default/ufw by setting DEFAULT_FORWARD_POLICY="DROP"
 
Add a rule to /etc/ufw/before.rules which basically ACCEPTS packets on --dport=11230 for forwarding. See before_fwd_rules in testing/ufw/execution for reference.

To measure latency let this be the last rule that matches the input packets.

Run 'sudo ufw disable && sudo ufw enable'. NOTE: Make sure that /etc/ufw/user.rules contains a rule that allows ssh connections on ufw, else you will lose remote connection.

The UFW Output throughput will appear to be higher than UFW Input throughput, but this is purely a function of the way that throughput is being measured in these experiments. Throughput = Total Bytes / (Last packet timestamp - First packet timestamp) . 
Now as there is some higher packet latency for the initial set of packets, the First output packet timestamp is pushed ahead as compared to the last output packets. As a result the denominator of the above equation contracts causing an inflation in the value. For all purposes, the input and output throughput of this experiment remains the same.   

Input file:
	P4Boosters/testing/ufw/execution/pcaps/ufw_dcomp.pcap

ANALYSIS FILE:
	P4Boosters/testing/ufw/analysis/ufw_analysis.ipynb
 
