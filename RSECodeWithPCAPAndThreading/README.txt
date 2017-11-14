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
Versions	
--------------------------------------------------------------------------------

version 2017.10.31:  Supports packet lengths > 255 bytes (defined by FEC_MAX_COLS).
version 2017.10.19:  Fixed bugs. g++ compile option. Debug prints all optional.
version 2017.09.28:  Adds many new rsetest options, including a speed test.
version 2017.09.10:  First rewrite using Modified Reed-Solomon Code.

--------------------------------------------------------------------------------
Running	
--------------------------------------------------------------------------------
On a unix console (with gcc compiler) type:

$ make clean
$ make
$ ./rsetest

By default rsetest uses defaults for FEC block parameters. Command line options 
allow dynamic definition of configuration. See options by typing: 

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
(with FEC_MAX_COLS = 255)

Sending FEC Block n=7 c=3+1 (parities start at cbi-ef)
fbi-00 cbi-00: data d-00 (len=3):   --    8d    d3    f5  Known
fbi-01 cbi-01: data d-01 (len=3):   --    58    87    7f  Known
fbi-02 cbi-02: data d-02 (len=2):   --    --    fc    87  Known
fbi-03 cbi-fe: pari p-00 (len=4):   bf    cc    60     1  Known
fbi-04 cbi-fd: pari p-01 (len=4):   59    9e    6e    11  Known
fbi-05 cbi-fc: pari p-02 (len=4):   b0    d6    c2    30  Known
fbi-06 cbi-fb: pari p-03 (len=4):   e1    56    53    60  Known


Received FEC Block n=7 c=3+1 (parities start at cbi-ef)
fbi-00 cbi-00: data d-00 (len=0):   ??    ??    ??    ??  Wanted
fbi-01 cbi-01: data d-01 (len=3):   --    58    87    7f  Known
fbi-02 cbi-02: data d-02 (len=0):   ??    ??    ??    ??  Wanted
fbi-03 cbi-fe: pari p-00 (len=0):   ??    ??    ??    ??  Ignore
fbi-04 cbi-fd: pari p-01 (len=4):   59    9e    6e    11  Known
fbi-05 cbi-fc: pari p-02 (len=0):   ??    ??    ??    ??  Ignore
fbi-06 cbi-fb: pari p-03 (len=4):   e1    56    53    60  Known


Recovered FEC Block n=7 c=3+1 (parities start at cbi-ef)
fbi-00 cbi-00: data d-00 (len=3):   --    8d    d3    f5  Known
fbi-01 cbi-01: data d-01 (len=3):   --    58    87    7f  Known
fbi-02 cbi-02: data d-02 (len=2):   --    --    fc    87  Known
fbi-03 cbi-fe: pari p-00 (len=0):   ??    ??    ??    ??  Ignore
fbi-04 cbi-fd: pari p-01 (len=4):   59    9e    6e    11  Known
fbi-05 cbi-fc: pari p-02 (len=0):   ??    ??    ??    ??  Ignore
fbi-06 cbi-fb: pari p-03 (len=4):   e1    56    53    60  Known


$ ./rsetest -c 1500
(with FEC_MAX_COLS = 10000)

Sending FEC Block n=6 c=1500+2 (parities start at cbi-ef)
fbi-00 cbi-00: data d-00 (len=1500):   --    --    44    77    f3    99    b9    e7  ... (8 of 1502)Known
fbi-01 cbi-01: data d-01 (len=1500):   --    --    ba    3d    8a    39    2b    98  ... (8 of 1502)Known
fbi-02 cbi-02: data d-02 (len=1499):   --    --    --    6b    6e    aa    18    16  ... (8 of 1502)Known
fbi-03 cbi-fe: pari p-00 (len=1502):   f6    26    27    3a    e5    ae    a8    fc  ... (8 of 1502)Known
fbi-04 cbi-fd: pari p-01 (len=1502):   78    d7    a7    cc    cb    24     7    7a  ... (8 of 1502)Known
fbi-05 cbi-fc: pari p-02 (len=1502):   47    e2    72    32    32    37    15    a3  ... (8 of 1502)Known


Received FEC Block n=6 c=1500+2 (parities start at cbi-ef)
fbi-00 cbi-00: data d-00 (len=0):      ??    ??    ??    ??    ??    ??    ??    ??  ... (8 of 1502)Wanted
fbi-01 cbi-01: data d-01 (len=1500):   --    --    ba    3d    8a    39    2b    98  ... (8 of 1502)Known
fbi-02 cbi-02: data d-02 (len=0):      ??    ??    ??    ??    ??    ??    ??    ??  ... (8 of 1502)Wanted
fbi-03 cbi-fe: pari p-00 (len=1502):   f6    26    27    3a    e5    ae    a8    fc  ... (8 of 1502)Known
fbi-04 cbi-fd: pari p-01 (len=0):      ??    ??    ??    ??    ??    ??    ??    ??  ... (8 of 1502)Ignore
fbi-05 cbi-fc: pari p-02 (len=1502):   47    e2    72    32    32    37    15    a3  ... (8 of 1502)Known


Recovered FEC Block n=6 c=1500+2 (parities start at cbi-ef)
fbi-00 cbi-00: data d-00 (len=1500):   --    --    44    77    f3    99    b9    e7  ... (8 of 1502)Known
fbi-01 cbi-01: data d-01 (len=1500):   --    --    ba    3d    8a    39    2b    98  ... (8 of 1502)Known
fbi-02 cbi-02: data d-02 (len=1499):   --    --    --    6b    6e    aa    18    16  ... (8 of 1502)Known
fbi-03 cbi-fe: pari p-00 (len=1502):   f6    26    27    3a    e5    ae    a8    fc  ... (8 of 1502)Known
fbi-04 cbi-fd: pari p-01 (len=0):      ??    ??    ??    ??    ??    ??    ??    ??  ... (8 of 1502)Ignore
fbi-05 cbi-fc: pari p-02 (len=1502):   47    e2    72    32    32    37    15    a3  ... (8 of 1502)Known

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



