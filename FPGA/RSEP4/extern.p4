#include "Configuration.h"

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
extern bit<FEC_PACKET_INDEX_WIDTH> loop(in bit<FEC_REG_ADDR_WIDTH> addr, in bit<FEC_PACKET_INDEX_WIDTH> max);

@Xilinx_MaxLatency(100)
extern bit<1> fec(in bit<FEC_OP_WIDTH> operation, in bit<FEC_PACKET_INDEX_WIDTH> index, in bit<FEC_OFFSET_WIDTH> payload_offset);

