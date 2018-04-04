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

#define HEADER_SIZE ((FEC_ETH_HEADER_SIZE + FEC_HEADER_SIZE) / 8)
#define LENGTH_SIZE (FEC_PACKET_LENGTH_SIZE / 8)

#define LENGTH_OFFSET ((FEC_ETH_HEADER_SIZE + FEC_HEADER_SIZE) / 8)
#define PAYLOAD_OFFSET (LENGTH_OFFSET + (FEC_PACKET_LENGTH_SIZE) / 8)

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
static fec_sym Packet_length_parity[FEC_PACKET_LENGTH_SIZE / 8][FEC_MAX_H];

static unsigned Maximum_packet_length;

static void Ignore_packet(packet_interface * Data, packet_interface Parity[FEC_MAX_PACKET_SIZE])
{
#pragma HLS inline

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

static void Encode_packet(tuple_interface Tuple, packet_interface * Data,
    packet_interface Parity[FEC_MAX_PACKET_SIZE])
{
#pragma HLS inline

  if (Tuple.Operation & FEC_OP_START_ENCODER)
    Maximum_packet_length = 0;

  unsigned Word_offset = 0;
  unsigned End = 0;
  unsigned Packet_length = 0;
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
        int Initialize = (Tuple.Operation & FEC_OP_START_ENCODER)
            || Offset >= Maximum_packet_length;
        fec_sym Symbol = (Input.Data >> 8 * (7 - Byte_offset)) & 0xFF;
        Incremental_encode(Symbol, Parity_buffer[Offset], Tuple.Index,
        FEC_MAX_H, Initialize);
      }
      Offset++;
    }

    Parity[Word_offset++] = Output;

    Packet_length += Input.Count;
  }
  while (!End);

  if (Packet_length > Maximum_packet_length)
    Maximum_packet_length = Packet_length;

  for (unsigned Offset = 0; Offset < FEC_PACKET_LENGTH_SIZE / 8; Offset++)
  {
#pragma HLS pipeline
    fec_sym Symbol = (Packet_length >> (8 * Offset)) & 0xFF;
    Incremental_encode(Symbol, Packet_length_parity[Offset], Tuple.Index,
    FEC_MAX_H, Tuple.Operation & FEC_OP_START_ENCODER);
  }
}

void Output_parity_packets(tuple_interface Tuple, packet_interface * Data,
    packet_interface Parity[FEC_MAX_PACKET_SIZE])
{
#pragma HLS inline

  unsigned Word_offset = 0;
  unsigned Input_finished = 0;
  unsigned End = 0;
  do
  {
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

    const packet_interface Empty = {0, 0, 0, 1, 0};

    packet_interface Input = Input_finished ? Empty : Data[Word_offset];

    Input_finished = Input.End_of_frame;

    unsigned Packet_length = Maximum_packet_length + HEADER_SIZE + LENGTH_SIZE;
    End = Word_offset == (Packet_length - 1) / 8;

    packet_interface Output;
    Output.Data = 0;
    unsigned Offset = 8 * Word_offset;
    for (unsigned Byte_offset = 0; Byte_offset < 8; Byte_offset++)
    {
      uint8 Input_byte = 0;
      if (Offset < LENGTH_OFFSET)
      {
        Input_byte = Input.Data >> (8 * Byte_offset);
      }
      else if (Offset < PAYLOAD_OFFSET)
      {
        unsigned Length_offset = Offset - LENGTH_OFFSET;
        Input_byte = Packet_length_parity[Length_offset][Tuple.Index - FEC_MAX_K];
      }
      else if (Offset < Packet_length)
      {
        unsigned Payload_offset = Offset - PAYLOAD_OFFSET;
        Input_byte = Parity_buffer[Payload_offset][Tuple.Index - FEC_MAX_K];
      }

      Output.Data <<= 8;
      Output.Data |= Input_byte;
      Offset++;
    }

    Output.Start_of_frame = Word_offset == 0;
    Output.End_of_frame = End;
    unsigned Remainder = Packet_length % 8;
    Output.Count = End && Remainder != 0 ? Remainder : 8;
    Output.Error = Input.Error;

    Parity[Word_offset++] = Output;
  }
  while (!End);
}

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

#pragma HLS ARRAY_PARTITION variable=Packet_length_parity complete dim=0

  if (!Tuple.Valid)
    Ignore_packet(Data, Parity);
  else if (Tuple.Operation & FEC_OP_ENCODE_PACKET)
    Encode_packet(Tuple, Data, Parity);
  else if (Tuple.Operation & FEC_OP_GET_ENCODED)
    Output_parity_packets(Tuple, Data, Parity);
}
