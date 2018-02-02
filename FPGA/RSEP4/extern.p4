/*	
	Get the number at "addr". 
	THEN, add a number to the value in storage.
	This number's absolute value is "delta", sign is "plus" 
*/
extern bit<32> get_and_add(bit<32> addr, bit<32> delta, bit<1> plus);


/*
	while(true)
	{
		output reg[addr];
		reg[addr] ++;
		if reg[addr] == max;
			reg[addr] = 0;
	}
*/
@Xilinx_MaxLatency(100)
extern bit<32> loop(in bit<32> addr,in bit<32> max);



/* 
	Simulated counter using get_and_add.
	Return times this function has been called.
	Avoid using COUNTER_ADDR for other purposes.
*/
#define COUNTER_ADDR 65535

#define counter() get_and_add(COUNTER_ADDR, 1, 1)



/* [TODO] compile never finish if set to 1500*8 */
/* ethernet MTU, in bits */
#define ETH_MTU 64
	
/* feed the packet back to this switch */
//extern bit<1> feedback(in bit<ETH_MTU> packet);

/* [TODO] this may not work in real fpga. Maybe switch to get_and_add */
/* read and write register, address is 32 bit long */
//@Xilinx_MaxLatency(16)
extern bit<32> readr(in bit<32> addr);
//@Xilinx_MaxLatency(16)
extern bit<1> writer(in bit<32> addr, in bit<32> data);

/* fec */
#define FEC_QUEUE_NUMBER 8
#define FEC_PARITY_NUMBER 4

#define FEC_PAYLOAD_SIZE 256
#define ETH_HEADER_SIZE 112
#define FEC_PACKET_SIZE 368
#define VETH_HEADER_SIZE 136
#define FEC_ENCODED_PACKET_SIZE 504

#define PARITY_FLAG (1<<23)
#define VID_MASK 0x7fffff

#define OP_PREPARE_ENCODING	(1<<0)
#define OP_ENCODE			(1<<1)
#define OP_GET_ENCODED		(1<<2)
#define OP_PREPARE_DECODING (1<<3)
#define OP_DECODE			(1<<4)
#define OP_GET_DECODED		(1<<5)

#define COMBINED_INTERFACE

#ifdef COMBINED_INTERFACE

/* parameters may be reused across different operations.(see individual definitions below)
	there may be 2 operations in the same call, e.g., prepare_encoding and encode
	return anying if no return value is required (bit<1> below)
	the latency is a random number (16) now; can be changed to any meaningful number */
//@Xilinx_MaxLatency(16)
@Xilinx_MaxLatency(100)
extern bit<FEC_PACKET_SIZE> fec(in bit<8> operation, in bit<32> index, in bit<1> is_parity, in bit<FEC_PACKET_SIZE> packet);

#else

extern bit<1> fec_prepare_encoding(in bit<1> do_prepare_encoding, in bit<FEC_PACKET_SIZE> packet, in bit<32> index);
extern bit<1> fec_encode(in bit<1> do_encode);
extern bit<FEC_PACKET_SIZE> fec_get_encoded (in bit<1> do_get_encoded, in bit<32> index);

extern bit<1> fec_prepare_decoding(in bit<1> do_prepare_decoding, in bit<FEC_PACKET_SIZE> packet, in bit<32> index, in bit<1> is_parity);
extern bit<1> fec_decode(in bit<1> do_decode);
extern bit<FEC_PACKET_SIZE> fec_get_decoded (in bit<1> do_get_decoded, in bit<32> index);

#endif


