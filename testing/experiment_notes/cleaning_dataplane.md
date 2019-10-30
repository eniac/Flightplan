This info is for cleaning the network before conducting any experiments.

This is done to avoid bandwidth being taken up by random packets and for ease of analysis purposes.

The main kind of broadcast packets seen were:

1)ICMP6 Router Solicitation packets:

  This is avoided by disabling the ipv6 functionality on that specific interface where the experiment is being run.

 sudo sysctl -w net.ipv6.conf.<interface>.disable_ipv6=1

2)BOOTP/DHCP packets:

 The way  to prevent this is by:
  On TCLUST machines, killing multiple instances of dhclient processes.
  On DCOMP1 ---> configure /etc/netplan/50-cloud-init.yml file to have dhcp4:false on that specific interface. Sometimes multiple dhclient processes may be running on DCOMP1 as well, in which case killing them is also required. 




