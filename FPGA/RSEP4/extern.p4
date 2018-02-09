#define REG_SIZE 16
#define REG_ADDR_SIZE 8

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
extern bit<REG_SIZE> loop(in bit<REG_ADDR_SIZE> addr, in bit<REG_SIZE> max);

/* fec */
/* k and h in fec code */
/* feel free to modify */
#define FEC_QUEUE_NUMBER 8
#define FEC_PARITY_NUMBER 4

#define VTAG_SIZE 16
#define ETH_HEADER_SIZE 112
#define VETH_HEADER_SIZE (ETH_HEADER_SIZE + VTAG_SIZE)

#define PARITY_FLAG (1<<(VTAG_SIZE-1))
#define VID_MASK 0x7fffff

#define OP_START_ENCODER		(1<<0)
#define OP_ENCODE_PACKET		(1<<1)
#define OP_GET_ENCODED		(1<<2)


@Xilinx_MaxLatency(100)
extern bit<1> fec(in bit<4> operation, in bit<REG_SIZE> index, in bit<REG_SIZE> data_offset);

