#ifndef HLS_MEMCACHED
#define HLS_MEMCACHED
//Assumptions
#define REQUEST_LINE_SIZE (500)
#define MAX_DATA_SIZE (2048)
#define MAX_PACKET_SIZE (REQUEST_LINE_SIZE+MAX_DATA_SIZE)
#define MAX_KEY_LEN (256)
#define MAX_MEMORY_SIZE 128
#define MAX_CMD_LEN (10)
#define NUM_OF_CMD (6)
#define MAX_RESPONSE_LEN (20)
#define NUM_OF_RESPONSE (8)
//Some consts in the hdr
#define IPV4_LEN_FIELD (16)
#define UDP_LEN_FIELD (38)
#define PAYLOAD_OFFSET_UDP (50) //Payload location under UDP include 8 bytes memcached header
#define MEMCACHED_UDP_HEADER (8)
#define ETH_HDR_LEN (14)
#define IPV4_HDR_LEN (20)
#define UDP_HDR_LEN (8)
#define MINIMUM_ETH_LEN (60)

#define UDP_IDENTIFIER (23)
#define DIVIDE_AND_ROUNDUP(Dividend, Divisor) ((Dividend + Divisor -1) / Divisor)
//Width in bits of AXI bus
#define MEM_AXI_BUS_WIDTH (64)
#define BYTES_PER_WORD (MEM_AXI_BUS_WIDTH / 8)

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

typedef struct Incomplete_Data_Word{
	Data_Word Data;
	ap_uint<8> len;
}Part_Word;

typedef struct Cache_Memory{
  Data_Word KEY[MAX_KEY_LEN/BYTES_PER_WORD];
  int KEY_LEN;
  Data_Word DATA[MAX_DATA_SIZE/BYTES_PER_WORD];
  long DATA_LEN;
  bool VALID;
}Cache;

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

// For Hash Function
#define MAGIC_NUM (31)

enum ascii_cmd {
  GET_CMD,
  SET_CMD,
  DELETE_CMD,
  VALUE_RESP,
  DELETED_RESP,
  UNKNOWN_CMD
};

enum mem_protocl{
	UDP_Protocl,
	TCP_Protocl
};


enum resp_index{
	_STORED,
	_VALUE,
	_END,
	_DELETED,
	_NOT_SPACE,
	_FOUND,
	_SPACE,
	_END_OF_LINE
};

typedef struct standard_command
{
	char cmd[MAX_CMD_LEN];
	int len;
	enum ascii_cmd cc;
}Cmd_Word;



const Part_Word Standard_Response[NUM_OF_RESPONSE]={ 0x53544F5245442000, 7,
													 0x56414C5545200000, 6,
											         0x454E440000000000, 3,
											         0x44454C4554454420, 8,
											         0x4E4F542000000000, 4,
											         0x464F554E44200000, 6,
											         0x2000000000000000, 1,
											         0x0D0A000000000000, 2};




const int Data_Stream_Size = MAX_PACKET_SIZE/BYTES_PER_WORD + 1;
const int Key_Stream_Size = MAX_KEY_LEN/BYTES_PER_WORD + 1;

void Memcore(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);

#endif

