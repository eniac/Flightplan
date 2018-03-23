#include <stdint.h>

#ifndef IN_SOFTWARE
#include <ap_cint.h>
#else
typedef uint8_t uint1;
typedef uint8_t uint3;
typedef uint8_t uint4;
typedef uint8_t uint8;
typedef uint16_t uint11;
typedef uint64_t uint64;
#endif

#include "Encoder.h"

#define CONCATENATE_INTERNAL(x, y) x ## y
#define CONCATENATE(x, y) CONCATENATE_INTERNAL(x, y)

typedef CONCATENATE(uint, FEC_PACKET_INDEX_WIDTH) index_type;
typedef CONCATENATE(uint, FEC_OP_WIDTH) operation_type;

typedef struct
{
  // Note the reverse order with respect to paramter order in external function
  // declaration.
  index_type Index;
  operation_type Operation;
  uint1 Valid;
} tuple_interface;

typedef struct
{
  // Note the reverse order with respect to paramter order in external function
  // declaration.
  uint1 Error;
  uint4 Count;
  uint64 Data;
  uint1 End_of_frame;
  uint1 Start_of_frame;
} packet_interface;

static fec_sym Parity_buffer[FEC_MAX_PACKET_SIZE][FEC_MAX_H];

void RSE_core(tuple_interface Tuple, packet_interface * Data,
    packet_interface Parity[FEC_MAX_PACKET_SIZE])
{
#pragma HLS DATA_PACK variable=Tuple
#pragma HLS DATA_PACK variable=Data
#pragma HLS DATA_PACK variable=Parity
#pragma HLS INTERFACE ap_vld port=Tuple
#pragma HLS INTERFACE ap_fifo port=Data
#pragma HLS INTERFACE ap_hs port=Parity

// Ideally, I want to reshape along dimension 2 such that Incremental_encode
// touches only one word at a time, and I want to partition along dimension 1
// to put every consecutive indices into different BRAMs.  Using partitioning
// and reshaping together is not possible however...
#pragma HLS ARRAY_PARTITION variable=Parity_buffer cyclic factor=8 dim=1
#pragma HLS ARRAY_PARTITION variable=Parity_buffer complete dim=2
//#pragma HLS ARRAY_RESHAPE variable=Parity_buffer cyclic factor=4 dim=2

  if (!Tuple.Valid)
  {
    unsigned Word_offset = 0;
    unsigned End = 0;
    do
    {
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

      packet_interface Input = Data[Word_offset];
      End = Input.End_of_frame;
      Parity[Word_offset++] = Input;
    }
    while (!End);
  }
  else if (Tuple.Operation & FEC_OP_ENCODE_PACKET)
  {
    unsigned Word_offset = 0;
    unsigned End = 0;
    do
    {
#pragma HLS DEPENDENCE variable=Parity_buffer inter false
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

      packet_interface Input = Data[Word_offset];
      packet_interface Output = Input;

      End = Input.End_of_frame;

      unsigned Offset = 8 * Word_offset;
      for (unsigned Byte_offset = 0; Byte_offset < 8; Byte_offset++)
      {
        if (Byte_offset < Input.Count)
        {
          fec_sym Symbol = (Input.Data >> 8 * (7 - Byte_offset)) & 0xFF;
          Incremental_encode(Symbol, Parity_buffer[Offset], Tuple.Index,
          FEC_MAX_H, Tuple.Operation & FEC_OP_START_ENCODER);
        }
        Offset++;
      }

      Parity[Word_offset++] = Output;
    }
    while (!End);
  }
  else if (Tuple.Operation & FEC_OP_GET_ENCODED)
  {
    unsigned Word_offset = 0;
    unsigned Input_finished = 0;
    unsigned End = 0;
    unsigned New_packet_length = FEC_ETH_HEADER_SIZE / 8;
    do
    {
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

      // I applied a couple of tricks to get the clock period down to 3 ns.
      // The loop exit condition (End) took several cycles to compute
      // originally.  Because of that, the initiation interval was 3 instead of
      // 1.  I found out that if-statements had a bad effect on the latency, so
      // I replaced them with conditional expressions.  I would have expected
      // the tool to do if-conversion if needed, but apparently that did not
      // happen.  This change was not enough, so I broke the computation apart
      // by calculating the packet length a cycle earlier.  That did the trick.

      const packet_interface Empty = {0, 0, 0, 1, 0};

      unsigned Packet_length = New_packet_length;

      packet_interface Input = Input_finished ? Empty : Data[Word_offset];
      New_packet_length += Input_finished ? 0 : Input.Count;

      packet_interface Output = Input;

      Input_finished = Input.End_of_frame;

      End = (Word_offset == (Packet_length / 8));

      Output.Data = 0;
      unsigned Offset = 8 * Word_offset;
      for (unsigned Byte_offset = 0; Byte_offset < 8; Byte_offset++)
      {
        Output.Data <<= 8;
        if (8 * Offset < FEC_ETH_HEADER_SIZE + FEC_HEADER_SIZE)
          Output.Data |= (Input.Data >> 8 * Byte_offset) & 0xFF;
        else if (Offset < Packet_length)
        {
          int Payload_offset = Offset - (FEC_ETH_HEADER_SIZE + FEC_HEADER_SIZE) / 8;
          Output.Data |= Parity_buffer[Payload_offset][Tuple.Index - FEC_MAX_K] & 0xFF;
        }
        Offset++;
      }

      Output.Start_of_frame = Word_offset == 0;
      Output.End_of_frame = End;
      Output.Count = End ? Packet_length % 8 : 8;
      Output.Error = Input.Error;

      Parity[Word_offset++] = Output;
    }
    while (!End);
  }
}
