#include "RSE_core_test.h"

#include <stdlib.h>

void Verify_matrix_multiply(int Data_packet_count, int Parity_packet_count, int Position)
{
  for (int i = 0; i < Data_packet_count; i++)
    if (fb.pstat[i] != FEC_FLAG_KNOWN)
      return;
  for (int i = 0; i < Parity_packet_count; i++)
    if (fb.pstat[Data_packet_count + i] != FEC_FLAG_WANTED)
      return;

  fec_sym Data[FEC_MAX_N];
  for (int i = 0; i < Data_packet_count; i++)
  {
    if (Position < fb.plen[i])
      Data[i] = fb.pdata[i][Position];
    else
      Data[i] = 0;
    if (Position == fb.block_C - 1 && FEC_EXTRA_COLS > 0)
      Data[i] = fb.plen[i];
  }

  fec_sym Parity[FEC_MAX_H];
  Matrix_multiply_HW(Data, Parity, Data_packet_count, Parity_packet_count);

  for (int i = 0; i < Parity_packet_count; i++)
    if (fb.d[i][0] != Parity[i])
    {
      fputs("Encoder output is not matching.\n", stderr);
      exit(1);
    }
}
