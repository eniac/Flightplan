#ifndef HEADER_DECODER
#define HEADER_DECODER

#include "Configuration.h"

#include <cstddef>
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
    ap_uint<FEC_TRAFFIC_CLASS_WIDTH + FEC_BLOCK_INDEX_WIDTH + FEC_PACKET_INDEX_WIDTH + 16> FEC;
    ap_uint<FEC_ETH_HEADER_SIZE> Eth;
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
    packet_index Packet_index;
    block_index Block_index;
    traffic_class Traffic_class;
    k_type k;
    ap_uint<1> Valid;
} tuple_Decoder_input;

typedef struct
{
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
    tuple_Update_fl Update_fl;
    tuple_hdr Hdr;
    tuple_ioports Ioports;
    tuple_local_state Local_state;
    tuple_Parser_extracts Parser_extracts;
    tuple_Decoder_output Decoder_output;
} output_tuples;

typedef struct
{
    // Note the reverse order with respect to parameter order in external function
    // declaration.
    ap_uint<1> Error;
    ap_uint<4> Count;
    data_word Data;
    ap_uint<1> End_of_frame;
    ap_uint<1> Start_of_frame;
} packet_interface;

void Decode(input_tuples Tuple_input, output_tuples Tuple_output[FEC_MAX_K],
    const packet_interface Packet_input[WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET]);

#endif
