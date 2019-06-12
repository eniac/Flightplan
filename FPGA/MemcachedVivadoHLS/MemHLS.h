#ifndef HLS_MEMCACHED
#define HLS_MEMCACHED
//Assumptions
#define REQUEST_LINE_SIZE (300)
#define MAX_DATA_SIZE (1200)
#define MAX_PACKET_SIZE (REQUEST_LINE_SIZE+MAX_DATA_SIZE)
#define MAX_KEY_LEN (256)
#define MAX_MEMORY_SIZE (1024)
#define MAX_CMD_LEN (10)
#define NUM_OF_CMD (6)
#define MAX_RESPONSE_LEN (20)
#define NUM_OF_RESPONSE (8)
//Some consts in the hdr
#define PAYLOAD_OFFSET_UDP (42) //Payload location under UDP include 8 bytes memcached header
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

#define PACKET_END (9)


#include <hls_stream.h>
#include <ap_int.h>
#include <stdint.h>

typedef ap_uint<MEM_AXI_BUS_WIDTH> Data_Word;
typedef ap_uint<8> Byte;
typedef ap_uint<1> MemcachedPkt;

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
	ap_uint<4> len;
	ap_uint<1> End;
}Part_Word;

typedef struct Cache_Memory{
  Data_Word KEY[MAX_KEY_LEN/BYTES_PER_WORD];
  int KEY_LEN;
  Data_Word DATA[MAX_DATA_SIZE/BYTES_PER_WORD];
  long DATA_LEN;
  bool VALID;
  Part_Word DATA_LEN_WORD;

}Cache;

typedef struct
{
    ap_uint<4> Egress_port;
    ap_uint<4> Ingress_port;
} tuple_ioports;

typedef struct
{
    ap_uint<16> Id;
} tuple_local_state;

typedef struct
{
    ap_uint<32> Size;
} tuple_Parser_extracts;

typedef struct
{
    ap_uint<22> Control;
} tuple_control;

typedef struct
{
    ap_uint<1> Stateful_valid;
} tuple_memcached_input;

typedef struct
{
	ap_uint<1> forward;

} tuple_checkcache;
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
	tuple_control Control;
	tuple_checkcache Checkcache;
	tuple_hdr Hdr;
	tuple_ioports Ioports;
    tuple_local_state Local_state;
    tuple_Parser_extracts Parser_extracts;
    tuple_memcached_input Memcached_input;
} input_tuples;

typedef struct
{
	tuple_control Control;//23
	tuple_checkcache Checkcache; //1
	tuple_hdr Hdr; //372
	tuple_ioports Ioports; //8
    tuple_local_state Local_state; //16
    tuple_Parser_extracts Parser_extracts; //32
    tuple_memcached_input Memcached_output; //1
} output_tuples;

// For Hash Function
#define MAGIC_NUM (31)

enum Parser_State{
	Consumption,
	Alignment,
	Not_Alignment
};
enum Pkt_Status{
	set_pkt,
	get_pkt,
	delete_pkt,
	value_pkt,
	get_collision,
	get_miss,
	NotFound_pkt,
	invalid
};
typedef struct
{
	uint16_t index;
	ap_uint<3> response;
	Data_Word MemHdr;
}instr;

typedef struct
{
	uint16_t index;
	enum Pkt_Status pkt;
	Data_Word MemHdr;
	uint8_t keylen;
	uint16_t Datalen;
}metadata;

enum Ascii_cmd {
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
	enum Ascii_cmd cc;
}Cmd_Word;

typedef ap_uint<4> Command_line;
typedef struct Instruction_Collection
{
	ap_uint<4> cmd;
	uint16_t index;
}Instruction;





const int Data_Stream_Size = MAX_PACKET_SIZE/BYTES_PER_WORD + 1;
const int Key_Stream_Size = MAX_KEY_LEN/BYTES_PER_WORD + 1;

void Memcore(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);

#endif

