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
	Data_Word Data;
	ap_uint<1> End_of_frame;
	ap_uint<1> Start_of_frame;
}packet_interface;



typedef struct
{

    ap_uint<16> Type;
    ap_uint<48> Src;
    ap_uint<48> Dst;
    ap_uint<1> Is_valid;
} tuple_eth;

typedef struct
{
    ap_uint<16> Original_type;
    ap_uint<8> Packet_index;
    ap_uint<5> Block_index;
    ap_uint<3> Traffic_class;
    ap_uint<1> Is_valid;
} tuple_fec;
typedef struct
{
	ap_uint<32> dstAddr;
	ap_uint<32> srcAddr;
	ap_uint<16> hdrchecksum;
	ap_uint<8> protocol;
	ap_uint<8> ttl;
	ap_uint<13> fragoffset;
	ap_uint<3> flags;
	ap_uint<16> identification;
	ap_uint<16> totallen;
	ap_uint<8> diffserv;
	ap_uint<4> ihl;
	ap_uint<4> version;
	ap_uint<1> isValid;

}tuple_ipv4;
typedef struct
{
	ap_uint<16> chksum;
	ap_uint<16> len;
	ap_uint<16> dport;
	ap_uint<16> sport;
	ap_uint<1> isValid;
}tuple_udp;

typedef struct
{
	tuple_udp Udp;
    tuple_ipv4 Ipv4;
    tuple_fec FEC;
	tuple_eth Eth;

} tuple_hdr;

typedef struct
{
    tuple_hdr Hdr;
} input_tuples;

typedef struct
{
    tuple_hdr Hdr;
} output_tuples;

void Memcore(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);

#endif

