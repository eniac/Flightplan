if ! [ $(id -u) = 0 ]; then
	echo "The script needs to be run as root." >&2
	exit 1
fi
if [ $SUDO_USER ]; then
	real_user=$SUDO_USER
else
	real_user=$(whoami)
fi

ip link delete clientVeth1
ip link delete serverVeth1
