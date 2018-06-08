#ifndef HLS_MEMCACHED
#define HLS_MEMCACHED
#include <hls_stream.h>
#include <ap_int.h>
#define DIVIDE_AND_ROUNDUP(Dividend, Divisor) ((Dividend + Divisor -1) / Divisor)
//Width in bits of AXI bus
#define MEM_AXI_BUS_WIDTH (64)
#define BYTES_PER_WORD (MEM_AXI_BUS_WIDTH / 8)
typedef ap_uint<MEM_AXI_BUS_WIDTH> Data_Word;

typedef struct
{
	ap_uint<1> Error;
	ap_uint<4> Count;
	Data_word Data;
	ap_uint<1> End_of_frame;
	ap_uint<1> Start_of_frame;
}packet_interface;

void Memcore(hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);

#endif

