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

#define HEADER_SIZE (FEC_ETH_HEADER_SIZE / 8)
#define LENGTH_SIZE (FEC_PACKET_LENGTH_WIDTH / 8)

#define LENGTH_OFFSET (HEADER_SIZE)
#define PAYLOAD_OFFSET (LENGTH_OFFSET + LENGTH_SIZE)

#define CONCATENATE_INTERNAL(x, y) x ## y
#define CONCATENATE(x, y) CONCATENATE_INTERNAL(x, y)

typedef CONCATENATE(uint, FEC_PACKET_INDEX_WIDTH) index_type;
typedef CONCATENATE(uint, FEC_K_WIDTH) k_type;
typedef CONCATENATE(uint, FEC_H_WIDTH) h_type;

#define STR(x) #x
#define PRAGMA(x) _Pragma(STR(x))

typedef struct
{
  // Note the reverse order with respect to parameter order in external function
  // declaration.
  h_type h;
  k_type k;
  uint1 Valid;
} input_tuple;

typedef struct
{
  // Note the reverse order with respect to parameter order in external function
  // declaration.
  index_type Packet_index;
} output_tuple;

typedef struct
{
  // Note the reverse order with respect to parameter order in external function
  // declaration.
  uint1 Error;
  uint4 Count;
  uint64 Data;
  uint1 End_of_frame;
  uint1 Start_of_frame;
} packet_interface;

static fec_sym Header[HEADER_SIZE];

static fec_sym Parity_buffer[FEC_MAX_PACKET_SIZE][FEC_MAX_H];
static fec_sym Packet_length_parity[FEC_PACKET_LENGTH_WIDTH / 8][FEC_MAX_H];

static index_type Packet_index;

static unsigned Maximum_packet_length;

static void Ignore_packet(packet_interface * Input_packet,
    packet_interface Output_packet[(FEC_MAX_PACKET_SIZE + 7) / 8])
{
#pragma HLS inline

  unsigned Word_offset = 0;
  unsigned End = 0;
  do
  {
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

    packet_interface Input = Input_packet[Word_offset];
    End = Input.End_of_frame;
    Output_packet[Word_offset++] = Input;
  }
  while (!End);
}

static void Encode_packet(input_tuple Input_tuple, output_tuple * Output_tuple,
    packet_interface * Input_packet, packet_interface Output_packet[(FEC_MAX_PACKET_SIZE + 7) / 8])
{
#pragma HLS inline

  if (Packet_index == 0)
    Maximum_packet_length = 0;

  unsigned Word_offset = 0;
  unsigned End = 0;
  unsigned Packet_length = 0;
  do
  {
#pragma HLS DEPENDENCE variable=Parity_buffer inter false
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

    packet_interface Input = Input_packet[Word_offset];
    packet_interface Output = Input;

    End = Input.End_of_frame;

    unsigned Offset = 8 * Word_offset;
    for (unsigned Byte_offset = 0; Byte_offset < 8; Byte_offset++)
    {
      if (Offset < HEADER_SIZE)
        Header[Offset] = (Input.Data >> 8 * (7 - Byte_offset)) & 0xFF;

      if (Byte_offset < Input.Count)
      {
        int Initialize = (Packet_index == 0) || Offset >= Maximum_packet_length;
        fec_sym Symbol = (Input.Data >> 8 * (7 - Byte_offset)) & 0xFF;
        Incremental_encode(Symbol, Parity_buffer[Offset], Packet_index, Input_tuple.h, Initialize);
      }
      Offset++;
    }

    Output_packet[Word_offset++] = Output;

    Packet_length += Input.Count;
  }
  while (!End);

  if (Packet_length > Maximum_packet_length)
    Maximum_packet_length = Packet_length;

  for (unsigned Offset = 0; Offset < FEC_PACKET_LENGTH_WIDTH / 8; Offset++)
  {
#pragma HLS pipeline
    fec_sym Symbol = (Packet_length >> (8 * Offset)) & 0xFF;
    Incremental_encode(Symbol, Packet_length_parity[Offset], Packet_index, Input_tuple.h,
        Packet_index == 0);
  }

  Output_tuple->Packet_index = Packet_index;

  Packet_index++;
}

void Output_parity_packet(input_tuple Input_tuple, output_tuple * Output_tuple,
    packet_interface Output_packet[(FEC_MAX_PACKET_SIZE + 7) / 8])
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

    unsigned Packet_length = Maximum_packet_length + HEADER_SIZE + LENGTH_SIZE;
    End = Word_offset == (Packet_length - 1) / 8;

    packet_interface Output;
    Output.Data = 0;
    unsigned Offset = 8 * Word_offset;
    for (unsigned Byte_offset = 0; Byte_offset < 8; Byte_offset++)
    {
      uint8 Input_byte = 0;
      if (Offset < LENGTH_OFFSET)
        Input_byte = Header[Offset];
      else if (Offset < PAYLOAD_OFFSET)
      {
        unsigned Length_offset = Offset - LENGTH_OFFSET;
        Input_byte = Packet_length_parity[Length_offset][Packet_index - Input_tuple.k];
      }
      else if (Offset < Packet_length)
      {
        unsigned Payload_offset = Offset - PAYLOAD_OFFSET;
        Input_byte = Parity_buffer[Payload_offset][Packet_index - Input_tuple.k];
      }

      Output.Data <<= 8;
      Output.Data |= Input_byte;
      Offset++;
    }

    Output.Start_of_frame = Word_offset == 0;
    Output.End_of_frame = End;
    unsigned Remainder = Packet_length % 8;
    Output.Count = End && Remainder != 0 ? Remainder : 8;
    Output.Error = 0;

    Output_packet[Word_offset++] = Output;
  }
  while (!End);

  Output_tuple->Packet_index = Packet_index;

  Packet_index++;
  if (Packet_index == Input_tuple.k + Input_tuple.h)
    Packet_index = 0;
}

void RSE_core(input_tuple Input_tuple, output_tuple * Output_tuple, packet_interface * Input_packet,
    packet_interface Output_packet[(FEC_MAX_PACKET_SIZE + 7) / 8])
{
#pragma HLS DATA_PACK variable=Input_tuple
#pragma HLS DATA_PACK variable=Input_packet
#pragma HLS DATA_PACK variable=Output_packet
#pragma HLS INTERFACE ap_vld port=Input_tuple
#pragma HLS INTERFACE ap_vld port=Output_tuple
#pragma HLS INTERFACE ap_fifo port=Input_packet
#pragma HLS INTERFACE ap_hs port=Output_packet

#pragma HLS ARRAY_PARTITION variable=Header cyclic factor=8
#pragma HLS ARRAY_PARTITION variable=Parity_buffer cyclic factor=8 dim=1
#pragma HLS ARRAY_PARTITION variable=Parity_buffer complete dim=2
#pragma HLS ARRAY_PARTITION variable=Packet_length_parity complete dim=0

  if (!Input_tuple.Valid)
    Ignore_packet(Input_packet, Output_packet);
  else if (Packet_index < Input_tuple.k)
    Encode_packet(Input_tuple, Output_tuple, Input_packet, Output_packet);
  else
    Output_parity_packet(Input_tuple, Output_tuple, Output_packet);
}
