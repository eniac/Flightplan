## Configuring the boosters:  
Follow the instruction at ./Flightplan/cpuBoosters/bmv2, and configure the switch with  
```
make configure BOOSTERS="MEMCACHED COMPRESSION"
```

If there is a compile/syntax error at ./Flightplan/cpuBoosters/memcached/memcached.cpp, then use ```g++-6```.  
(You can simply add ```CC=g++-6``` at ./Flightplan/cpuBoosters/memcached/Makefile)

## Compiling p4 programs:  
random_drop extern for the dropper switch is installed along with the fec booster, so that the samples will likely fail if the switch is configured without the fec booster.  
You can take one of these options to fix it:
- comment dropper table and random_drop extern at ./Flightplan/Wharf/Sources/Dropper.p4.  
- remove the dropper from a topology when testing.  
- manually copying random_drop extern source codes to other boosters when installing.   

BMV2_REPO is hard-coded in many files.
- at ./Flightplan/Wharf/bmv2/start_flightplan_mininet.py, add BMV2_REPO environment variable (i.e. os.environ["BMV2_REPO"]= ...).  
- at ./Flightplan/Wharf/run_alv.sh, add BMV2_REPO enviornment variable (i.e. BMV2_REPO = ...).  
- at ./Flightplan/Wharf/splits/ALV_Complete_Without_FEC/tests.sh, add WHARF_REPO environment variable.  

Follow the instruction at ./Flightplan/Wharf for installing required dependencies, and type ```make bmv2 BOOSTERS="MEMCACHED COMPRESSION"``` which will compile p4 programs.

## Examples:  
Example for Crosspod (with fec, memcached, and compression) are located at ./Flightplan/Wharf/splits/ALV_Complete. Currently, it will not work due to missing fec source codes.  

Example for Crosspod (without FEC) is located at ./Flightplan/Wharf/splits/ALV_Complete_Without_FEC (minor modification from the above file).
At the test directory, type ```sudo ./tests.sh``` to run the test. You can modify tests.sh script to select different testing mode and .yml file to edit its topology.
