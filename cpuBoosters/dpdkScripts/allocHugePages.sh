# allocate memory to hugepages. 
sudo ls > /dev/null
echo "allocating 1024 2MB hugepages on each socket. You may want to change this later if DPDK apps need more RAM."
echo "old number of hugepages:"
echo "node 0:"
cat /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages 
echo "node 1:"
cat /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages 

sudo su -c "echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages"
sudo su -c "echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages"

echo "new number of hugepages:"
echo "node 0:"
cat /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages 
echo "node 1:"
cat /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages 

# make hugepages mount dir.
mkdir -p /mnt/huge
HTLB_MOUNTED=$( mount | grep "type hugetlbfs" | wc -l)
if [ $HTLB_MOUNTED -eq 0 ]; then
 mount -t hugetlbfs hugetlb /mnt/huge
fi
