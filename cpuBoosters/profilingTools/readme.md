#### Profiling tools for fec booster ####

perfCounterInterface.h -- functions to start and stop counters in code. 
vethProfileE2E.sh -- script to run an instrumented end-to-end booster veth trial.
parseCounters.py -- analyze the output from vethProfileE2E.

results.txt -- manual analysis using: 
```sudo ./vethProfileE2E.sh ../pcaps/iperfClient2Server.pcap tag_all_10_4.txt 1 3```
*with 1 to 4 packets dropped in each block*


Code that needs to be integrated:
forwardingNonBooster.c -- forwarding booster with option to drop first N packets of each block. 
rse.bkp.c -- snapshot of rse.c used to get results.txt.