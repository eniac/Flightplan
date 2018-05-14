#include "RSE_core_test.h"
#include "Encoder.h"

#include <stdlib.h>

void Verify_matrix_multiply(int fb_index, int Data_packet_count, int Parity_packet_count, int Position)
{
  for (int i = 0; i < Data_packet_count; i++)
    if (fbk[fb_index].pstat[i] != FEC_FLAG_KNOWN)
      return;
  for (int i = 0; i < Parity_packet_count; i++)
    if (fbk[fb_index].pstat[Data_packet_count + i] != FEC_FLAG_WANTED)
      return;

  fec_sym Data[FEC_MAX_N];
  for (int i = 0; i < Data_packet_count; i++)
  {
    if (Position < fbk[fb_index].plen[i])
      Data[i] = fbk[fb_index].pdata[i][Position];
    else
      Data[i] = 0;
    if (Position == fbk[fb_index].block_C - 1 && FEC_EXTRA_COLS > 0)
      Data[i] = fbk[fb_index].plen[i];
  }

  fec_sym Parity[FEC_MAX_H];
  for (int i = 0; i < FEC_MAX_H; i++)
    Parity[i] = 0;
  for (int i = 0; i < Data_packet_count; i++)
    Incremental_encode(Data[i], Parity, i, Parity_packet_count, i == 0);

  for (int i = 0; i < Parity_packet_count; i++)
    // fbk[fb_index].d[i][0] is output from Vencore's FEC
    // Parity[i] is output from Hans' FEC
    if (fcm.d[i][0] != Parity[i])
    {
      fputs("Encoder output is not matching.\n", stderr);
      exit(1);
    }
}

void encode_matrix(int fb_index, int Data_packet_count, int Parity_packet_count, int Position)
{
  fec_sym Data[FEC_MAX_N];
  for (int i = 0; i < Data_packet_count; i++)
  {
    if (Position < fbk[fb_index].plen[i])
      Data[i] = fbk[fb_index].pdata[i][Position];
    else
      Data[i] = 0;
    if (Position == fbk[fb_index].block_C - 1 && FEC_EXTRA_COLS > 0)
      Data[i] = fbk[fb_index].plen[i];
  }

  fec_sym Parity[FEC_MAX_H];
  for (int i = 0; i < FEC_MAX_H; i++)
    Parity[i] = 0;
  for (int i = 0; i < Data_packet_count; i++)
    Incremental_encode(Data[i], Parity, i, Parity_packet_count, i == 0);

  for (int i = 0; i < Parity_packet_count; i++)
    fcm.d[i][0] = Parity[i];
}
