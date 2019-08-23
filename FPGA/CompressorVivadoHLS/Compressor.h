#ifndef HLS_COMPRESSOR
#define HLS_COMPRESSOR
#define ETH_HDR_LEN (14)
#define IPV4_HDR_LEN (20)
#define UDP_HDR_LEN (8)
#define MINIMUM_ETH_LEN (60)
#define UDP_IDENTIFIER (23)
#define DIVIDE_AND_ROUNDUP(Dividend, Divisor) ((Dividend + Divisor -1) / Divisor)
//Width in bits of AXI bus
#define MEM_AXI_BUS_WIDTH (64)
#define BYTES_PER_WORD (MEM_AXI_BUS_WIDTH / 8)
#define CACHE_SZ (1024)
#define ETYPE_COMPRESSED (0x1234)
#include <hls_stream.h>
#include <ap_int.h>
#include <stdint.h>

typedef ap_uint<MEM_AXI_BUS_WIDTH> Data_Word;
typedef ap_uint<8> Byte;

typedef struct
{
	ap_uint<1> Error;
	ap_uint<4> Count;
	Data_Word Data;
	ap_uint<1> End_of_frame;
	ap_uint<1> Start_of_frame;
}packet_interface;

#ifndef NO_FLIGHTPLAN_HEADER
typedef struct
{
    ap_uint<256> data;
    ap_uint<1> Is_valid;
} tuple_fph;
#endif

typedef struct
{
    ap_uint<4> Egress_port;
    ap_uint<4> Ingress_port;
} tuple_ioports; //8

typedef struct
{
    ap_uint<16> Id;
} tuple_local_state; // 16

typedef struct
{
    ap_uint<32> Size;
} tuple_Parser_extracts; //32

typedef struct
{
    ap_uint<22> Control;
} tuple_control; //22

typedef struct
{
    ap_uint<1> Stateful_valid;
} tuple_headerCompress_input;

typedef struct
{
	ap_uint<1> forward;

} tuple_checktcp;
typedef struct
{

    ap_uint<16> Type;
    ap_uint<48> Src;
    ap_uint<48> Dst;
    ap_uint<1> Is_valid;
} tuple_eth; //113

typedef struct
{
    ap_uint<16> Original_type;
    ap_uint<8> Packet_index;
    ap_uint<5> Block_index;
    ap_uint<3> Traffic_class;
    ap_uint<1> Is_valid;
} tuple_fec; //33
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

}tuple_ipv4; //161
typedef struct
{
	ap_uint<16> urgent;
	ap_uint<16> check;
	ap_uint<16> window;
	ap_uint<16> flags;
	ap_uint<32> ack;
	ap_uint<32> seq;
	ap_uint<16> dport;
	ap_uint<16> sport;
	ap_uint<1> isValid;
}tuple_tcp; //161

typedef struct
{
	tuple_tcp Tcp; //161
	tuple_ipv4 Ipv4; //161
	tuple_fec FEC; //33
	tuple_eth Eth; //113
#ifndef NO_FLIGHTPLAN_HEADER
	tuple_fph Fph; //256
#endif
} tuple_hdr; //468 + 256

typedef struct
{
	tuple_control Control; //22
	tuple_checktcp CheckTcp;
	tuple_hdr Hdr; //468
	tuple_ioports Ioports;
	tuple_local_state Local_state;
	tuple_Parser_extracts Parser_extracts;
	tuple_headerCompress_input headerCompress_input;
}input_tuples;

typedef struct
{
	ap_uint<10> slotID;
	ap_uint<1> seqChange;
	ap_uint<1> ackChange;
	ap_uint<4> __pad;

	ap_uint<16> totallen;
	ap_uint<16> identification;
	
	ap_uint<16> flags;
	ap_uint<16> window;
	ap_uint<16> check;
	ap_uint<16> urgent;	

}compressedHeader_t;

typedef struct
{
	uint16_t len;
	ap_uint<10> idx;

	tuple_ipv4 ipHeader;
	tuple_tcp tcpHeader;
}compressorTuple_t;
typedef struct
{
	tuple_control Control;//22
	tuple_checktcp CheckTcp; //1
	tuple_hdr Hdr; //468
	tuple_ioports Ioports; //8
	tuple_local_state Local_state; //16
	tuple_Parser_extracts Parser_extracts; //32
	tuple_headerCompress_input headerCompress_output; //1
} output_tuples;

void Compressor(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);

void EmptyCompressor(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);
void ejectPacket(hls::stream<packet_interface> &Packet_input, hls::stream<packet_interface> & Packet_output);
bool checkCache(compressorTuple_t curPktTup);
ap_uint<10> crchash(tuple_ipv4 ip, tuple_tcp tcp);
#endif

