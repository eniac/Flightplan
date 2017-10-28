--------------------------------------------------------------------------------
Packet Forward Erasure Correcting code  
--------------------------------------------------------------------------------

This package implements a flexible high speed packet Forward Error Correction 
(FEC) code. Encoders (possibly distributed) add h redundant FEC packets to k 
data packets; decoders reconstruct up to h lost (erased, not errored) data 
packets.  Features which make this implementation desirable are:
  a) It does not modify the data packets (Systematic code).
  b) Handles arbitrary-sized and variable-sized packets.
  c) FEC packets depend only on data packet, so can be incrementally generated.  
  d) Decoder need not know how many FEC packets were added.
  e) Decoder do not calculate missing parity packets.  
  f) No copying packets: FEC block only contains pointers to each packet. 
  g) Decoder is O(k.h.h) per byte (or 16-bit word) and can also encode. 
  h) Encoder **NOT YET IMPLEMENTED** is O(k.h) per byte (or 16-bit word) 

--------------------------------------------------------------------------------
Files in Package
--------------------------------------------------------------------------------

Makefile	Compiles program into an executable (rsetest) that can be run.
README.txt	This overview
rse.h		Defines FEC parameters, FEC block and print debug options.
rse.c   	Implements the modified Reed-Solomon Erasure Code.
rsetest.c	Creates random data packets, FEC block & erasure channel emulation.

--------------------------------------------------------------------------------
Running	
--------------------------------------------------------------------------------
On a unix console (with gcc compiler) type:

$ make clean
$ make
$ ./rsetest

Without specify configuration, rsetest uses defaults for FEC block parameters.
However, command line options allow their dynamic definition. See options by 
typing: 

$ ./rsetest help
     [-k Number of Data packets in the FEC block]
     [-h Number of Parity packets in the FEC block]
     [-c Max number of (1-byte) Symbols in a data packet]
     [-e FEC Block index of packet erased in comms emulation]
     [-o Offset when selecting which parities to generate]
     [-r Number of runs in a speed test of encoder and decoder]
     [-s Seed for generating random data values]

For example:

$ ./rsetest -k 3 -h 4 -c 3 -e 0 -e 2 -e 3 -e 5

Sending FEC Block n=7 c=4 c-xtra=1. Parities from cbi-08
fbi-00 cbi-00: data d-00 (len=3):   --    8d    d3    f5  Known
fbi-01 cbi-01: data d-01 (len=3):   --    58    87    7f  Known
fbi-02 cbi-02: data d-02 (len=2):   --    --    fc    87  Known
fbi-03 cbi-0b: pari p-00 (len=4):   4a    2b    29    83  Known
fbi-04 cbi-0a: pari p-01 (len=4):   ec    57    11    1e  Known
fbi-05 cbi-09: pari p-02 (len=4):   8b    f4    a6    50  Known
fbi-06 cbi-08: pari p-03 (len=4):   2f    5d    36    c0  Known

Receiving FEC Block into Coder: pseudo random data, except first symbol is length
FEC Block n=7 c=4 c-xtra=1. Parities from cbi-08
fbi-00 cbi-00: data d-00 (len=0):   ??    ??    ??    ??  Wanted
fbi-01 cbi-01: data d-01 (len=3):   --    58    87    7f  Known
fbi-02 cbi-02: data d-02 (len=0):   ??    ??    ??    ??  Wanted
fbi-03 cbi-0b: pari p-00 (len=0):   ??    ??    ??    ??  Ignore
fbi-04 cbi-0a: pari p-01 (len=4):   ec    57    11    1e  Known
fbi-05 cbi-09: pari p-02 (len=0):   ??    ??    ??    ??  Ignore
fbi-06 cbi-08: pari p-03 (len=4):   2f    5d    36    c0  Known

Recovered FEC Block n=7 c=4 c-xtra=1. Parities from cbi-08
fbi-00 cbi-00: data d-00 (len=3):   --    8d    d3    f5  Known
fbi-01 cbi-01: data d-01 (len=3):   --    58    87    7f  Known
fbi-02 cbi-02: data d-02 (len=2):   --    --    fc    87  Known
fbi-03 cbi-0b: pari p-00 (len=0):   ??    ??    ??    ??  Ignore
fbi-04 cbi-0a: pari p-01 (len=4):   ec    57    11    1e  Known
fbi-05 cbi-09: pari p-02 (len=0):   ??    ??    ??    ??  Ignore
fbi-06 cbi-08: pari p-03 (len=4):   2f    5d    36    c0  Known


--------------------------------------------------------------------------------
RSE.C User-callable functions
--------------------------------------------------------------------------------

1. int  rse_init(void)
-----------------------
Initializes the math and FEC tables using the parameters from rse.h. 
This function is called exactly once, before calling rse_code().
  
2. int  rse_code(void);
-----------------------
Encodes or decodes and returns 0 if the operation is successful. It uses 
the FEC block defined by global variable fb to pass all parameters. The
k + h packets in an FEC block can be defined in any order, with the 
codeword index defining whether it is an data or parity packet:
fb.block_C;		How many m-bit symbols in the Parity packets
fb.block_N;		How many packets in the FEC block.
*fb.pdata[FEC_N-1];   	Pointer to memory for each data or parity packet.
fb.plen[FEC_N-1];	Number of symbols in each data or parity packet
			(if len < fb.block_C, coder (virtually) fills with 0's)
fb.pstat[FEC_N-1];	Status of each data or parity packet
           		 - FEC_FLAG_KNOWN  => Packet is known
           		 - FEC_FLAG_WANTED => Packet is unknown and wanted
           		 - FEC_FLAG_IGNORE => Packet is unknown but unwanted
fb.cbi[FEC_N-1];	FEC codeword index for each packet (data packet
			if chi < FEC_MAX_K, else a parity packet).

E.g., For k=3, h=2, c=3
                <-----------------DATA------------------>  length   status   code index
data packet 0:  *(pdata[0]+0) *(pdata[0]+1) *(pdata[0]+2)  plen[0]  pstat[0]  cbi[0]
data packet 1:  *(pdata[1]+0) *(pdata[1]+1) *(pdata[1]+2)  plen[1]  pstat[1]  cbi[1]
data packet 2:  *(pdata[2]+0) *(pdata[2]+1) *(pdata[2]+2)  plen[2]  pstat[2]  cbi[2]
-------------------------------------------------------------------------------------
 fec packet 0:  *(pdata[3]+0) *(pdata[3]+1) *(pdata[3]+2)  plen[3]  pstat[3]  cbi[3]
 fec packet 1:  *(pdata[4]+0) *(pdata[4]+1) *(pdata[4]+2)  plen[4]  pstat[4]  cbi[4]

Limits on the number and size of packets are set by the constants in rse.h
  k       Number of data packets             (0 < k <=  FEC_MAX_K)
  h       Number of FEC packets              (0 < h <= FEC_MAX_H)
  c       Maximum symbols in any data packet (0 < c <= FEC_MAX_COLS)
          and the size of all FEC packet

3. void fec_block_print(void);
------------------------------
Prints contents of data and fec packets in the FEC block defined by fb  

4. void fec_block_delete(int *);
--------------------------------
Delete packets from FEC Block with FEC block indices stored in the array passed
to the function. The last element in the array must be FEC_MAX_N, marking the 
end of erasure list. For example, to erasure the second (index = 1) and fifth 
(index = 4) packets, the array elements would be {1, 4, FEC_MAX_N}  



