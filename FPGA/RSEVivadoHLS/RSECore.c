#include <stdint.h>
#include <ap_cint.h>

#include "rse.h"

#define FEC_PACKET_SIZE 368

#define TOKENPASTE(x, y) x ## y
#define TOKENPASTE2(x, y) TOKENPASTE(x, y)

#define PACKET_T TOKENPASTE2(uint, FEC_PACKET_SIZE)

#define OP_PREPARE_ENCODING (1 << 0)
#define OP_ENCODE           (1 << 1)
#define OP_GET_ENCODED      (1 << 2)

typedef PACKET_T packet_t;

static packet_t data_buffer[FEC_MAX_K];
static packet_t parity_buffer[FEC_MAX_H];

void Matrix_multiply_HW(fec_sym Data[FEC_MAX_K], fec_sym Parity[FEC_MAX_H], int k, int h);

void RSE_core(uint8 operation, uint32 index, uint1 is_parity, packet_t data, packet_t * parity)
{
#pragma HLS ARRAY_PARTITION variable=data_buffer complete dim=1
#pragma HLS ARRAY_PARTITION variable=parity_buffer complete dim=1
  int k = FEC_MAX_K;
  int h = FEC_MAX_H;

  if ((operation & OP_PREPARE_ENCODING) != 0)
    data_buffer[index] = data;
  else if ((operation & OP_ENCODE) != 0)
  {
    for (int i = 0; i < FEC_PACKET_SIZE; i += FEC_M)
    {
#pragma HLS pipeline
      fec_sym input[FEC_MAX_K];
      for (int j = 0; j < k; j++)
        input[j] = (data_buffer[j] >> i) & 0xFF;
      fec_sym output[FEC_MAX_H];
      Matrix_multiply_HW(input, output, k, h);
      for (int j = 0; j < h; j++)
        parity_buffer[j] = (parity_buffer[j] & ~((uint368) 0xFF << i))
            | (((uint368) output[j]) << i);
    }
  }
  else if ((operation & OP_GET_ENCODED) != 0)
    *parity = parity_buffer[index];
}
