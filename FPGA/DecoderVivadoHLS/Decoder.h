#ifndef HEADER_DECODER
#define HEADER_DECODER

#include "Configuration.h"

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
    // Note the reverse order with respect to parameter order in external function
    // declaration.
    packet_index Packet_index;
    block_index Block_index;
    traffic_class Traffic_class;
    k_type k;
    ap_uint<1> Valid;
} input_tuple;

typedef struct
{
    // Note the reverse order with respect to parameter order in external function
    // declaration.
    k_type Packet_count;
} output_tuple;

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

void Decode(input_tuple Tuple_input, output_tuple * Tuple_output,
    const packet_interface Packet_input[FEC_MAX_K * WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET]);

#endif
