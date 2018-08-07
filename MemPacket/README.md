#Memcached Hardware Testing

##Generate packets
Use scripts generate\_packets.sh to generate testing packets and standard response from actual memcached service. The length of KEY and DATA could be modified in config file .memaslap.cnf

##Testing
Use tcpreplay or dpdk to send packets. And use tcpdump or dpdk to capture response packets.
