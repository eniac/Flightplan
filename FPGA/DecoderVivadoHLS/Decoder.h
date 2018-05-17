#ifndef HEADER_DECODER
#define HEADER_DECODER

#include "Configuration.h"

#include <cstddef>
#include <hls_stream.h>
#include <ap_int.h>

#define DIVIDE_AND_ROUND_UP(Dividend, Divisor) ((Dividend + Divisor - 1) / Divisor)

#define WORDS_PER_PACKET (DIVIDE_AND_ROUND_UP(FEC_MAX_PACKET_SIZE, 8))
#define BYTES_PER_WORD (FEC_AXI_BUS_WIDTH / 8)

typedef ap_uint<FEC_TRAFFIC_CLASS_WIDTH> traffic_class;
typedef ap_uint<FEC_BLOCK_INDEX_WIDTH> block_index;
typedef ap_uint<FEC_PACKET_INDEX_WIDTH> packet_index;
typedef ap_uint<FEC_K_WIDTH> k_type;
typedef ap_uint<FEC_AXI_BUS_WIDTH> data_word;

typedef struct
{
    k_type Packet_count;
    k_type k;
} tuple_Update_fl;

typedef struct
{
    ap_uint<FEC_ETHER_TYPE_WIDTH> Type;
    ap_uint<48> Src;
    ap_uint<48> Dst;
    ap_uint<1> Is_valid;
} tuple_eth;

typedef struct
{
    traffic_class Traffic_class;
    block_index Block_index;
    packet_index Packet_index;
    ap_uint<FEC_ETHER_TYPE_WIDTH> Original_type;
    ap_uint<1> Is_valid;
} tuple_fec;

typedef struct
{
    tuple_fec FEC;
    tuple_eth Eth;
} tuple_hdr;

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
    ap_uint<23> Control;
} tuple_control;

typedef struct
{
    packet_index Packet_index;
    block_index Block_index;
    traffic_class Traffic_class;
    k_type k;
    ap_uint<1> Stateful_valid;
} tuple_Decoder_input;

typedef struct
{
    tuple_control Control;
    tuple_Update_fl Update_fl;
    tuple_hdr Hdr;
    tuple_ioports Ioports;
    tuple_local_state Local_state;
    tuple_Parser_extracts Parser_extracts;
    tuple_Decoder_input Decoder_input;
} input_tuples;

typedef struct
{
    k_type Packet_count;
} tuple_Decoder_output;

typedef struct
{
    tuple_control Control;
    tuple_Update_fl Update_fl;
    tuple_hdr Hdr;
    tuple_ioports Ioports;
    tuple_local_state Local_state;
    tuple_Parser_extracts Parser_extracts;
    tuple_Decoder_output Decoder_output;
} output_tuples;

typedef struct
{
    ap_uint<1> Error;
    ap_uint<4> Count;
    data_word Data;
    ap_uint<1> End_of_frame;
    ap_uint<1> Start_of_frame;
} packet_interface;

void Decode(hls::stream<input_tuples> & Tuple_input, hls::stream<output_tuples> & Tuple_output,
    hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output);

#endif
