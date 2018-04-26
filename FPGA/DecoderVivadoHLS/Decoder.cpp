#include "Decoder.h"

#include <hls_stream.h>

#define HEADER_SIZE ((FEC_ETH_HEADER_SIZE + FEC_TRAFFIC_CLASS_WIDTH + FEC_BLOCK_INDEX_WIDTH + FEC_PACKET_INDEX_WIDTH + FEC_ETHER_TYPE_WIDTH) / 8)
#define WORDS_PER_PACKET ((FEC_MAX_PACKET_SIZE + 7) / 8)
#define BYTES_PER_PACKET_WIDTH (11)
#define WORDS_PER_PACKET_WIDTH (BYTES_PER_PACKET_WIDTH - 3)
#define TRAFFIC_CLASS_COUNT (1 << FEC_TRAFFIC_CLASS_WIDTH)
#define BYTES_PER_WORD (AXI_BUS_WIDTH / 8)

enum command
{
  COMMAND_IDLE, COMMAND_OUTPUT_DATA, COMMAND_DECODE
};

typedef ap_uint<FEC_TRAFFIC_CLASS_WIDTH> traffic_class;
typedef ap_uint<FEC_BLOCK_INDEX_WIDTH> block_index;
typedef ap_uint<FEC_PACKET_INDEX_WIDTH> packet_index;
typedef ap_uint<FEC_K_WIDTH> k_type;
typedef ap_uint<WORDS_PER_PACKET_WIDTH> words_per_packet;
typedef ap_uint<BYTES_PER_PACKET_WIDTH> bytes_per_packet;
typedef ap_uint<AXI_BUS_WIDTH> data_word;

typedef struct
{
    bool Data_packet;
    bytes_per_packet Bytes_per_packet;
} packet_info;

static block_index Current_blocks[TRAFFIC_CLASS_COUNT];
static packet_index Packet_counts[TRAFFIC_CLASS_COUNT];
static k_type Data_packet_counts[TRAFFIC_CLASS_COUNT];

static data_word Decode_word(data_word Input[FEC_MAX_K], packet_index Packet)
{
  return Input[Packet];
}

static command Select_command(bool Wait_for_data, bool Data_packet, bool New_block,
    traffic_class Traffic_class, k_type k)
{
  command Command;

  if (Wait_for_data)
  {
    if (!New_block)
    {
      if (Data_packet_counts[Traffic_class] == k && Data_packet)
        Command = COMMAND_OUTPUT_DATA;
      else
        Command = COMMAND_IDLE;
    }
    else
    {
      if (Packet_counts[Traffic_class] < k)
        Command = COMMAND_OUTPUT_DATA;
      else if (Data_packet_counts[Traffic_class] < k)
        Command = COMMAND_DECODE;
      else
        Command = COMMAND_IDLE;
    }
  }
  else
  {
    if (!New_block)
    {
      if (Packet_counts[Traffic_class] != k)
        Command = COMMAND_IDLE;
      else if (Data_packet_counts[Traffic_class] == k)
        Command = COMMAND_OUTPUT_DATA;
      else
        Command = COMMAND_DECODE;
    }
    else
    {
      if (Packet_counts[Traffic_class] < k)
        Command = COMMAND_OUTPUT_DATA;
      else
        Command = COMMAND_IDLE;
    }
  }

  return Command;
}

static bool Decide_to_drop(bool Wait_for_data, traffic_class Traffic_class,
bool New_block, k_type k)
{
  if (New_block)
    return false;
  else if (Wait_for_data)
    return Data_packet_counts[Traffic_class] >= k;
  else
    return Packet_counts[Traffic_class] >= k;
}

static void Collect_packets(traffic_class Traffic_class, block_index Block_index,
    packet_index Packet_index, k_type k,
    packet_interface Packet_input[FEC_MAX_K * (FEC_MAX_PACKET_SIZE + 7) / 8],
    hls::stream<data_word> Data_FIFOs[TRAFFIC_CLASS_COUNT],
    hls::stream<packet_info> Packet_info_FIFOs[TRAFFIC_CLASS_COUNT], command & Command,
    packet_index & Packet_count,
    bool Wait_for_data)
{
  bool New_block = Block_index != Current_blocks[Traffic_class];
  bool Data_packet = Packet_index < k;
  bool Drop = Decide_to_drop(Wait_for_data, Traffic_class, New_block, k);

  bool End = false;
  words_per_packet Packet_offset = 0;
  data_word Previous_word = 0;
  bytes_per_packet Packet_length = 0;
  packet_interface Input;
  do
  {
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline
    Input = Packet_input[Packet_offset];

    End = Input.End_of_frame;

    data_word Data;
    if (HEADER_SIZE % 8 == 0)
      Data = Input.Data;
    else
    {
      Data = Previous_word << (8 * (HEADER_SIZE % 8));
      Data |= Input.Data >> (8 * (8 - HEADER_SIZE % 8));
    }

    if (Packet_offset > HEADER_SIZE / 8 && !Drop)
      Data_FIFOs[Traffic_class].write(Data);

    Packet_length += Input.Count;
    Packet_offset++;

    Previous_word = Input.Data;
  }
  while (!End);

  if (HEADER_SIZE % 8 > 0 && Input.Count > HEADER_SIZE % 8 && !Drop)
  {
    data_word Data = Previous_word << (8 * (HEADER_SIZE % 8));
    Data_FIFOs[Traffic_class].write(Data);
  }

  Packet_length -= HEADER_SIZE;

  if (!Drop)
  {
    packet_info Info;
    Info.Data_packet = Data_packet;
    Info.Bytes_per_packet = Packet_length;
    Packet_info_FIFOs[Traffic_class].write(Info);
  }

  if (!New_block)
  {
    if (Data_packet)
      Data_packet_counts[Traffic_class]++;
    Packet_counts[Traffic_class]++;
  }

  Packet_count = Packet_counts[Traffic_class];

  Command = Select_command(Wait_for_data, Data_packet, New_block, Traffic_class, k);

  if (New_block)
  {
    Packet_counts[Traffic_class] = 1;
    Data_packet_counts[Traffic_class] = 0;
    if (Data_packet)
      Data_packet_counts[Traffic_class]++;
    Current_blocks[Traffic_class] = Block_index;
  }
}

static void Reorder_packets(traffic_class Traffic_class,
    hls::stream<data_word> Input_FIFOs[TRAFFIC_CLASS_COUNT],
    hls::stream<packet_info> Packet_info_FIFOs[TRAFFIC_CLASS_COUNT], k_type k, command Command,
    packet_index Packet_count, data_word Output_buffer[FEC_MAX_K][WORDS_PER_PACKET],
    hls::stream<data_word> & Output_FIFO, hls::stream<bytes_per_packet> & Packet_length_FIFO,
    words_per_packet & Packet_length)
{
  if (Command == COMMAND_DECODE)
  {
    for (k_type Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Packet_info_FIFOs[Traffic_class].read();
      for (words_per_packet Offset = 0; Offset < Info.Bytes_per_packet; Offset++)
        Output_buffer[Packet][Offset++] = Input_FIFOs[Traffic_class].read();
      Packet_length = Info.Bytes_per_packet;
    }
  }
  else if (Command == COMMAND_OUTPUT_DATA)
  {
    for (packet_index Packet = 0; Packet < Packet_count; Packet++)
    {
      packet_info Info = Packet_info_FIFOs[Traffic_class].read();
      words_per_packet Words_per_packet = (Info.Bytes_per_packet + BYTES_PER_WORD - 1)
          / BYTES_PER_WORD;
      for (words_per_packet Offset = 0; Offset < Words_per_packet; Offset++)
      {
        data_word Input = Input_FIFOs[Traffic_class].read();
        if (Info.Data_packet)
          Output_FIFO.write(Input);
      }
      if (Info.Data_packet)
        Packet_length_FIFO.write(Info.Bytes_per_packet);
    }
  }
}

static void Decode_packets(data_word Input_buffer[FEC_MAX_K][WORDS_PER_PACKET], command Command,
    k_type k, words_per_packet Packet_length, hls::stream<data_word> & Output_data)
{
  if (Command == COMMAND_DECODE)
    for (k_type Packet = 0; Packet < k; Packet++)
      for (words_per_packet Offset = 0; Offset < Packet_length; Offset++)
      {
        data_word Input[FEC_MAX_K];
        for (int Packet_2 = 0; Packet_2 < k; Packet_2++)
          Input[Packet_2] = Input_buffer[Packet_2][Offset];

        Output_data.write(Decode_word(Input, Packet));
      }
}

static void Output_packets(hls::stream<data_word> & Decoded_data_FIFO,
    hls::stream<data_word> & Raw_data_FIFO, hls::stream<bytes_per_packet> & Packet_length_FIFO,
    packet_index Packet_count, command Command, k_type k,
    packet_interface Packet_output[FEC_MAX_K * (FEC_MAX_PACKET_SIZE + 7) / 8],
    k_type & Packets_output)
{
  if (Command == COMMAND_DECODE)
  {
    unsigned Output_offset = 0;
    for (k_type Packet = 0; Packet < k; Packet++)
    {
      bytes_per_packet Bytes_per_packet = Decoded_data_FIFO.read();
      Bytes_per_packet |= (Decoded_data_FIFO.read() & ((1 << (16 - BYTES_PER_PACKET_WIDTH)) - 1))
          << 8;
      words_per_packet Words_per_packet = (Bytes_per_packet + BYTES_PER_WORD - 1) / BYTES_PER_WORD;

      for (words_per_packet Offset = 0; Offset < Words_per_packet; Offset++)
      {
        bool End = Offset == Words_per_packet - 1;
        packet_interface Output;
        Output.Data = Decoded_data_FIFO.read();
        Output.Start_of_frame = Offset == 0;
        Output.End_of_frame = End;
        Output.Count = Bytes_per_packet % 8;
        if (!End || Output.Count == 0)
          Output.Count = 8;
        Output.Error = 0;
        Packet_output[Output_offset++] = Output;
      }
    }
    Packets_output = k;
  }
  else if (Command == COMMAND_OUTPUT_DATA)
  {
    unsigned Output_offset = 0;
    for (k_type Packet = 0; Packet < Packet_count; Packet++)
    {
      bytes_per_packet Bytes_per_packet = Packet_length_FIFO.read();
      words_per_packet Words_per_packet = (Bytes_per_packet + BYTES_PER_WORD - 1) / BYTES_PER_WORD;
      for (words_per_packet Offset = 0; Offset < Words_per_packet; Offset++)
      {
        bool End = Offset == Words_per_packet - 1;
        packet_interface Output;
        Output.Data = Raw_data_FIFO.read();
        Output.Start_of_frame = Offset == 0;
        Output.End_of_frame = End;
        Output.Count = Bytes_per_packet % 8;
        if (!End || Output.Count == 0)
          Output.Count = 8;
        Output.Error = 0;
        Packet_output[Output_offset++] = Output;
      }
    }
    Packets_output = Packet_count;
  }
}

void Decode(input_tuple Tuple_input, output_tuple * Tuple_output,
    packet_interface Packet_input[FEC_MAX_K * WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
#pragma HLS INTERFACE ap_hs port=Packet_input
#pragma HLS INTERFACE ap_hs port=Packet_output

  data_word Ping_pong_buffer[FEC_MAX_K][WORDS_PER_PACKET];
  static hls::stream<data_word> Data_streams[TRAFFIC_CLASS_COUNT];
  static hls::stream<packet_info> Packet_info_streams[TRAFFIC_CLASS_COUNT];
  hls::stream<data_word> Raw_data_stream;
  hls::stream<bytes_per_packet> Packet_length_stream;
  hls::stream<data_word> Decoded_data_stream;
  command Command;
  packet_index Packet_count;
  words_per_packet Packet_length;

#pragma HLS dataflow
  Collect_packets(Tuple_input.Traffic_class, Tuple_input.Block_index, Tuple_input.Packet_index,
      Tuple_input.k, Packet_input, Data_streams, Packet_info_streams, Command, Packet_count,
      true);
  Reorder_packets(Tuple_input.Traffic_class, Data_streams, Packet_info_streams, Tuple_input.k,
      Command, Packet_count, Ping_pong_buffer, Raw_data_stream, Packet_length_stream,
      Packet_length);
  Decode_packets(Ping_pong_buffer, Command, Tuple_input.k, Packet_length, Decoded_data_stream);
  Output_packets(Decoded_data_stream, Raw_data_stream, Packet_length_stream, Packet_count, Command,
      Tuple_input.k, Packet_output, Tuple_output->Packet_count);
}
