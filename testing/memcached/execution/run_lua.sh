#!/bin/bash
HERE=$(realpath $(dirname $0))
LUAFILE=$(realpath $1)
PCAPFILE=$(realpath $2)

cd $HERE
echo $LUAFILE
cd dpdkScripts
. ./setDpdkPaths.bash
cd $PKTGEN_DIR
# -l <list of cores to use>
# -n <number of memory channels (always for for dell 720s)
# -m [cores for rx:cores for tx].[device #s to use (0 for first NIC)]
./app/x86_64-native-linuxapp-gcc/pktgen -l 0,1,2 -n 2 -w 08:00.1 -- -P -f $LUAFILE -m "[1:2].[0]" -s 0:$PCAPFILE 
