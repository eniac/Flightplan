if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi
if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# bring up veth pairs. 
ip link add clientVeth1 type veth peer name clientVeth2
sysctl net.ipv6.conf.networkVeth1.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth1.disable_ipv6=1
ifconfig clientVeth1 up promisc
ifconfig clientVeth2 up promisc

ip link add serverVeth1 type veth peer name serverVeth2
sysctl net.ipv6.conf.networkVeth2.disable_ipv6=1
sysctl net.ipv6.conf.deviceVeth2.disable_ipv6=1
ifconfig serverVeth1 up promisc
ifconfig serverVeth2 up promisc
