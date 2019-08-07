Go to dpdk/dpdkScripts and run allocHugePages.sh only ONCE! 

DO NOT run allocBigbufHugePages.sh, as it requests a lot of huge pages which almost saturates the system memory.

In the run_lua.sh script used to configure the dpdk capability of the system, make sure too many cores are not allocated to operations that are not being run. 

# -l <list of cores to use>
# -n <number of memory channels (always for for dell 720s)
# -m [cores for rx:cores for tx].[device #s to use (0 for first NIC)]
./app/x86_64-native-linuxapp-gcc/pktgen -l 0,1,2 -n 2 -w 08:00.1 -- -P -f $LUAFILE -m "[1:2].[0]" -s 0:$PCAPFILE

Here 1 core is assigned to rx and core 2 for tx.
Important to specify the correct device id, in this case it is 08:00.1.
To get the device id of the interface that you want run, 
ethtool -i <interface_name>
e.g. ethtool -i ens1f1

Also don't do any dpdk functionality on core0 where most of the statistics operations run and could interfere with network. 


