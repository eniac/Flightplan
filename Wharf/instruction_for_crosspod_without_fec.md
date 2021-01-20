## Configuring the boosters:  
Follow the instruction at Flightplan/cpuBoosters/bmv2, and configure the switch with  
```
make configure BOOSTERS="MEMCACHED COMPRESSION"
```

If there is a compile/syntax error at cpuBoosters/memcached/memcached.cpp, then use g++-6.

## Compiling p4 programs:  
1) Either comment dropper table and random_drop extern at Flightplan/Wharf/Sources/Dropper.p4, or remove dropper switch from a topology when testing.  
2) At Flightplan/Wharf/bmv2/start_flightplan_mininet.py, add BMV2_REPO environment variable (i.e. os.environ["BMV2_REPO"]= ...).  
3) At Flightplan/Wharf/run_alv.sh, add BMV2_REPO enviornment variable (i.e. BMV2_REPO = ...).  
4) At Flightplan/Wharf/splits/ALV_Complete_Without_FEC/tests.sh, add WHARF_REPO environment variable.  
5) Follow the instruction at Flightplan/Wharf, and type ```make bmv2 BOOSTERS="MEMCACHED COMPRESSION"```

Example is located at Flightplan/Wharf/splits/ALV_Complete_Without_FEC
