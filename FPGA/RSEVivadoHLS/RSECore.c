#include <stdint.h>
#include <ap_cint.h>

#include "Encoder.h"

#define FEC_PACKET_SIZE 368
#define BYTES_PER_PACKET ((FEC_PACKET_SIZE + FEC_M - 1) / FEC_M)

#define TOKENPASTE(x, y) x ## y
#define TOKENPASTE2(x, y) TOKENPASTE(x, y)

#define PACKET_T TOKENPASTE2(uint, FEC_PACKET_SIZE)

#define OP_START_ENCODER    (1 << 0)
#define OP_ENCODE_PACKET    (1 << 1)
#define OP_GET_ENCODED      (1 << 2)

#define UNROLL_FACTOR (16)

typedef PACKET_T packet_t;

static fec_sym parity_buffer[BYTES_PER_PACKET][FEC_MAX_H];

void Matrix_multiply_HW(fec_sym Data[FEC_MAX_K], fec_sym Parity[FEC_MAX_H], int k, int h);

void RSE_core(uint8 operation, uint32 index, uint1 is_parity, packet_t data, packet_t * parity)
{
#pragma HLS ARRAY_PARTITION variable=parity_buffer complete dim=0
  int k = FEC_MAX_K;
  int h = FEC_MAX_H;

  *parity = 0;

  if (operation & OP_START_ENCODER)
  {
    for (int i = 0; i < BYTES_PER_PACKET; i++)
    {
#pragma HLS unroll
      for (int j = 0; j < FEC_MAX_H; j++)
      {
#pragma HLS unroll
        parity_buffer[i][j] = 0;
      }
    }
  }

  if (operation & OP_ENCODE_PACKET)
  {
    for (int i = 0; i < BYTES_PER_PACKET; i += UNROLL_FACTOR)
    {
#pragma HLS DEPENDENCE variable=parity_buffer inter false
#pragma HLS pipeline
      /*
       * The loop over j should not be necessary, but if I remove it and use an unroll pragma instead,
       * the synthesis tool finds false dependencies between different elements of parity_buffer.  I
       * suspect that the compiler tries to save loads and stores by combining loads/stores to adjacent
       * elements.  If I set an HLS dependency pragma to resolve it, the tool fails because it perceives
       * the dependencies as real dependencies.  By separating the loops, we do not flag the new
       * dependencies caused by unrolling as false dependencies.
       */
      for (int j = 0; j < UNROLL_FACTOR; j++)
      {
        if (i + j < BYTES_PER_PACKET)
          Incremental_encode(data & ((1 << FEC_M) - 1), parity_buffer[i + j], index, h,
              operation & OP_START_ENCODER);
        data >>= FEC_M;
      }
    }
  }
  else if (operation & OP_GET_ENCODED)
  {
    for (int i = 0; i < BYTES_PER_PACKET; i++)
    {
#pragma HLS unroll
      *parity |= parity_buffer[i][index];
      *parity <<= FEC_M;
    }
  }
}
