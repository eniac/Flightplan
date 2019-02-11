# Tofino setup
```
                                   __________LOOPBACK__________
_________________           ______|___________________________|_____            _________________
|    Tclust1    |           |                                       |           |    Tclust2    |
|    CLIENT     |___________|                 TOFINO                |___________|    SERVER     |
|               |           |                                       |           |               |
|_______________|           |___17/1__________17/2___________17/3___|           |_______________|
                                 |              |              |            
                           ______|______  ______|______  ______|______      
                           |   FPGA1   |  |   FPGA2   |  |   FPGA3    | 
                           |   bottom  |  |   middle  |  |    top     |
                           |  power #2 |  |  power #3 |  |  power #4  |
                           -------------  -------------  --------------
```

FPGA 1 : Runs KV cache

         Johnshack cable: `jsn-JTAG-SMT2NC-210308A46CBE`

         NOTE: Currently still plugged into arista on port 7/1

         
FPGA 2 : Runs Encoder

         Johnshack cable: ???? `jsn-JTAG-SMT2NC-210308A47676` ????


FPGA 3 : Runs decoder

         Johnshack cable: ???? `jsn-JTAG-SMT2NC-210308A5F0D3` ????


The tofino dataplane routes packets in the following order:

CLIENT -> FPGA1 -> FPGA2 -> LOOPBACK -> FPGA3 -> SERVER -> CLIENT
           kv       enc      dropper     dec   

Start the dataplane with:

`./Run.sh [-f] [-k] -d <drop_rate>`

If `-f` not provided, encoder and decoder will not be used
If `-k` not provided, kv store will not be used
`<drop_rate>` sets the rate at which packets are dropped when sent over the loopback
Only UDP traffic is routed through the cache
