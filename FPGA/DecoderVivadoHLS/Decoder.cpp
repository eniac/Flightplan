/* Original data packet:
 - 14-byte header
 - 64-byte payload
 =================
 78 bytes

 Tagged data packet:
 - 14-byte header
 - 4-byte FEC header
 - 64-byte payload

 Tagged parity packet:
 - 14-byte header
 - 4-byte FEC header
 - 2-byte payload length
 - 78-byte payload
 - 14-byte header
 - 64-byte payload
 */

#include "Decoder.h"

#include <hls_stream.h>

static const unsigned HEADER_SIZE = FEC_TRAFFIC_CLASS_WIDTH + FEC_BLOCK_INDEX_WIDTH
    + FEC_PACKET_INDEX_WIDTH + FEC_ETHER_TYPE_WIDTH;
static const unsigned TRAFFIC_CLASS_COUNT = 1 << FEC_TRAFFIC_CLASS_WIDTH;
static const unsigned PING_PONG_BUFFER_SIZE = DIVIDE_AND_ROUND_UP(
    FEC_MAX_PACKET_SIZE + FEC_PACKET_LENGTH_WIDTH / 8, BYTES_PER_WORD);

enum command
{
  COMMAND_IDLE, COMMAND_OUTPUT_DATA, COMMAND_DECODE
};

typedef ap_uint<FEC_PACKET_LENGTH_WIDTH> packet_length;

typedef struct
{
    bool Data_packet;
    packet_index Packet_index;
    packet_length Bytes_per_packet;
} packet_info;

static block_index Current_blocks[TRAFFIC_CLASS_COUNT];
static packet_index Packet_counts[TRAFFIC_CLASS_COUNT];
static k_type Data_packet_counts[TRAFFIC_CLASS_COUNT];

static data_word Decode_word(unsigned Packet, data_word Input[FEC_MAX_K],
    packet_index Packet_indices[FEC_MAX_K], unsigned k)
{
  for (unsigned i = 0; i < k; i++)
  {
    if (Packet == Packet_indices[i])
      return Input[i];
  }
  return 0xABCD12345678ABCD;
}

static command Select_command(bool Wait_for_data, bool Data_packet,
bool New_block, unsigned Traffic_class, unsigned k)
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

static bool Decide_to_drop(bool Wait_for_data, unsigned Traffic_class,
bool New_block, unsigned k)
{
  if (New_block)
    return false;
  else if (Wait_for_data)
    return Data_packet_counts[Traffic_class] >= k;
  else
    return Packet_counts[Traffic_class] >= k;
}

static void Collect_packets(unsigned Traffic_class, unsigned Block_index, unsigned Packet_index,
    unsigned k, const packet_interface Packet_input[FEC_MAX_K * WORDS_PER_PACKET],
    hls::stream<data_word> Data_FIFOs[TRAFFIC_CLASS_COUNT],
    hls::stream<packet_info> Packet_info_FIFOs[TRAFFIC_CLASS_COUNT], command & Command,
    unsigned & Packet_count, bool Wait_for_data)
{
  bool New_block = Block_index != Current_blocks[Traffic_class];
  bool Data_packet = Packet_index < k;
  bool Drop = Decide_to_drop(Wait_for_data, Traffic_class, New_block, k);

  bool End = false;
  unsigned Packet_offset = 0;
  unsigned Packet_length = 0;
  packet_interface Input;
  do
  {
#pragma HLS LOOP_TRIPCOUNT min=8 max=190
#pragma HLS pipeline

    Input = Packet_input[Packet_offset++];

    End = Input.End_of_frame;

    if (!Drop)
      Data_FIFOs[Traffic_class].write(Input.Data);

    Packet_length += Input.Count;
  }
  while (!End);

  if (!Drop)
  {
    packet_info Info;
    Info.Data_packet = Data_packet;
    Info.Packet_index = Packet_index;
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

static void Select_packets(unsigned Traffic_class,
    hls::stream<data_word> Input_FIFOs[TRAFFIC_CLASS_COUNT],
    hls::stream<packet_info> Input_info_FIFOs[TRAFFIC_CLASS_COUNT], unsigned k, command Command,
    unsigned Packet_count, hls::stream<data_word> & Output_raw_data_FIFO,
    hls::stream<data_word> & Output_encoded_data_FIFO,
    hls::stream<packet_info> & Output_raw_info_FIFO,
    hls::stream<packet_info> & Output_encoded_info_FIFO)
{
  if (Command == COMMAND_DECODE || Command == COMMAND_OUTPUT_DATA)
  {
    unsigned Count = Command == COMMAND_DECODE ? k : Packet_count;
    for (unsigned Packet = 0; Packet < Count; Packet++)
    {
      packet_info Info = Input_info_FIFOs[Traffic_class].read();
      if (Command == COMMAND_DECODE)
        Output_raw_info_FIFO.write(Info);
      else
        Output_encoded_info_FIFO.write(Info);

      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Info.Bytes_per_packet, BYTES_PER_WORD);
      for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
      {
        data_word Input = Input_FIFOs[Traffic_class].read();
        if (Command == COMMAND_DECODE)
          Output_encoded_data_FIFO.write(Input);
        else
          Output_raw_data_FIFO.write(Input);
      }
    }
  }
}

static void Preprocess_headers(hls::stream<data_word> & Input_FIFO,
    hls::stream<packet_info> & Input_packet_info_FIFO, unsigned k, command Command,
    hls::stream<data_word> & Output_FIFO, hls::stream<packet_info> & Output_packet_info_FIFO)
{
  if (Command == COMMAND_DECODE)
  {
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Packet_info = Input_packet_info_FIFO.read();
      unsigned Bytes_per_packet = Packet_info.Bytes_per_packet;
      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Bytes_per_packet, BYTES_PER_WORD);

      ap_uint<2 * FEC_AXI_BUS_WIDTH> Data = Bytes_per_packet;
      unsigned Count = Packet_info.Data_packet ? FEC_PACKET_LENGTH_WIDTH / 8 : 0;
      unsigned Offset = 0;
      for (unsigned Word_offset = 0; Word_offset < Words_per_packet; Word_offset++)
      {
#pragma HLS pipeline
        data_word Input = Input_FIFO.read();

        for (unsigned Byte_offset = 0; Byte_offset < BYTES_PER_WORD; Byte_offset++)
        {
          bool Output = (Packet_info.Data_packet && Offset < FEC_ETH_HEADER_SIZE / 8)
              || (Offset >= (FEC_ETH_HEADER_SIZE + HEADER_SIZE) / 8 && Offset < Bytes_per_packet);
          unsigned Byte = (Input >> (8 * (BYTES_PER_WORD - Byte_offset - 1))) & 0xFF;
          if (Output)
            Data = (Data << 8) | Byte;
          Count += Output ? 1 : 0;
          Offset++;
        }

        if (Count >= BYTES_PER_WORD)
        {
          Output_FIFO.write(Data >> (8 * (Count - BYTES_PER_WORD)));
          Count -= BYTES_PER_WORD;
        }
      }
      if (Count > 0)
        Output_FIFO.write(Data >> (8 * (BYTES_PER_WORD - Count)));

      Packet_info.Bytes_per_packet -= HEADER_SIZE / 8;
      if (!Packet_info.Data_packet)
        Packet_info.Bytes_per_packet -= FEC_ETH_HEADER_SIZE / 8;
      else
        Packet_info.Bytes_per_packet += FEC_PACKET_LENGTH_WIDTH / 8;
      Output_packet_info_FIFO.write(Packet_info);
    }
  }
}

static void Reorder_packets(hls::stream<data_word> & Input_FIFO,
    hls::stream<packet_info> & Input_packet_info_FIFO, command Command, unsigned k,
    data_word Output_buffer[FEC_MAX_K][PING_PONG_BUFFER_SIZE],
    hls::stream<packet_info> & Output_packet_info_FIFO, packet_index Packet_indices[FEC_MAX_K])
{
  if (Command == COMMAND_DECODE)
  {
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Input_packet_info_FIFO.read();
      Output_packet_info_FIFO.write(Info);
      Packet_indices[Packet] = Info.Packet_index;

      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Info.Bytes_per_packet, BYTES_PER_WORD);
      for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
        Output_buffer[Packet][Offset] = Input_FIFO.read();
    }
  }
}

static void Decode_packets(data_word Input_buffer[FEC_MAX_K][PING_PONG_BUFFER_SIZE],
    hls::stream<packet_info> & Input_packet_info_FIFO, packet_index Packet_indices[FEC_MAX_K],
    command Command, unsigned k, hls::stream<data_word> & Output_data,
    hls::stream<packet_info> & Output_packet_info_FIFO)
{
  if (Command == COMMAND_DECODE)
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Input_packet_info_FIFO.read();

      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Info.Bytes_per_packet, BYTES_PER_WORD);
      for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
      {
        data_word Input[FEC_MAX_K];
        for (int Packet_2 = 0; Packet_2 < k; Packet_2++)
          Input[Packet_2] = Input_buffer[Packet_2][Offset];

        data_word Output = Decode_word(Packet, Input, Packet_indices, k);

        if (Offset == 0)
        {
          Info.Bytes_per_packet = 78;
//          Info.Bytes_per_packet = Output >> (FEC_AXI_BUS_WIDTH - FEC_PACKET_LENGTH_WIDTH);
        }

        Output_data.write(Output);
      }

      Output_packet_info_FIFO.write(Info);
    }
}

static void Postprocess_headers(hls::stream<data_word> & Input_FIFO,
    hls::stream<packet_info> & Input_packet_info_FIFO, unsigned k, command Command,
    hls::stream<data_word> & Output_FIFO, hls::stream<packet_info> & Output_packet_info_FIFO)
{
  if (Command == COMMAND_DECODE)
  {
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Packet_info = Input_packet_info_FIFO.read();
      unsigned Bytes_per_packet = Packet_info.Bytes_per_packet;
      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(
          Packet_info.Bytes_per_packet + FEC_PACKET_LENGTH_WIDTH / 8, BYTES_PER_WORD);

      ap_uint<2 * FEC_AXI_BUS_WIDTH> Data = Bytes_per_packet;
      unsigned Count = 0;
      unsigned Offset = 0;
      for (unsigned Word_offset = 0; Word_offset < Words_per_packet; Word_offset++)
      {
#pragma HLS pipeline
        data_word Input = Input_FIFO.read();

        for (unsigned Byte_offset = 0; Byte_offset < BYTES_PER_WORD; Byte_offset++)
        {
          bool Output = Offset >= FEC_PACKET_LENGTH_WIDTH / 8;
          unsigned Byte = (Input >> (8 * (BYTES_PER_WORD - Byte_offset - 1))) & 0xFF;
          if (Output)
            Data = (Data << 8) | Byte;
          Count += Output ? 1 : 0;
          Offset++;
        }

        if (Count >= BYTES_PER_WORD)
        {
          Output_FIFO.write(Data >> (8 * (Count - BYTES_PER_WORD)));
          Count -= BYTES_PER_WORD;
        }
      }
      if (Count > 0)
        Output_FIFO.write(Data << (8 * (BYTES_PER_WORD - Count)));

      Output_packet_info_FIFO.write(Packet_info);
    }
  }
}

static void Output_decoded_packets(hls::stream<data_word> & Input_data_FIFO,
    hls::stream<packet_info> & Input_packet_info_FIFO, unsigned k,
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET], k_type & Packets_output)
{
  unsigned Output_offset = 0;
  for (unsigned Packet = 0; Packet < k; Packet++)
  {
    packet_info Packet_info = Input_packet_info_FIFO.read();
    unsigned Bytes_per_packet = Packet_info.Bytes_per_packet;
    unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Packet_info.Bytes_per_packet, BYTES_PER_WORD);
    for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
    {
#pragma HLS pipeline
      data_word Word = Input_data_FIFO.read();

      bool End = Offset == Words_per_packet - 1;

      packet_interface Output;
      Output.Data = Word;
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

static void Output_data_packets(hls::stream<data_word> & Input_data_FIFO,
    hls::stream<packet_info> & Input_packet_info_FIFO, unsigned Packet_count,
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET], k_type & Packets_output)
{
  unsigned Output_offset = 0;
  for (unsigned Packet = 0; Packet < Packet_count; Packet++)
  {
    packet_info Packet_info = Input_packet_info_FIFO.read();
    unsigned Bytes_per_packet = Packet_info.Bytes_per_packet;
    unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Packet_info.Bytes_per_packet, BYTES_PER_WORD);
    for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
    {
#pragma HLS pipeline
      data_word Word = Input_data_FIFO.read();

      bool End = Offset == Words_per_packet - 1;

      packet_interface Output;
      Output.Data = Word;
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

static void Output_packets(hls::stream<data_word> & Decoded_data_FIFO,
    hls::stream<data_word> & Raw_data_FIFO, hls::stream<packet_info> & Decoded_packet_info_FIFO,
    hls::stream<packet_info> & Raw_packet_info_FIFO, unsigned Packet_count, command Command,
    unsigned k, packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET],
    k_type & Packets_output)
{
  if (Command == COMMAND_DECODE)
    Output_decoded_packets(Decoded_data_FIFO, Decoded_packet_info_FIFO, k, Packet_output,
        Packets_output);
  else if (Command == COMMAND_OUTPUT_DATA)
    Output_data_packets(Raw_data_FIFO, Raw_packet_info_FIFO, Packet_count, Packet_output,
        Packets_output);
  else
    Packets_output = 0;
}

void Decode(input_tuple Tuple_input, output_tuple * Tuple_output,
    const packet_interface Packet_input[FEC_MAX_K * WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
#pragma HLS INTERFACE ap_hs port=Packet_input
#pragma HLS INTERFACE ap_hs port=Packet_output

  data_word Ping_pong_buffer[FEC_MAX_K][PING_PONG_BUFFER_SIZE];
  packet_index Packet_indices[FEC_MAX_K];
  static hls::stream<data_word> Data_streams[TRAFFIC_CLASS_COUNT];
  static hls::stream<packet_info> Packet_info_streams[TRAFFIC_CLASS_COUNT];
  hls::stream<data_word> Raw_data_stream_1;
  hls::stream<packet_info> Packet_info_stream_1;
  hls::stream<data_word> Data_stream_2;
  hls::stream<packet_info> Packet_info_stream_2;
  hls::stream<packet_info> Packet_info_stream_3;
  hls::stream<packet_info> Packet_info_stream_4;
  hls::stream<packet_info> Packet_info_stream_5;
  hls::stream<packet_info> Packet_info_stream_6;
  hls::stream<data_word> Encoded_data_stream;
  hls::stream<data_word> Decoded_data_stream;
  hls::stream<data_word> Raw_data_stream;
  hls::stream<data_word> Postprocessed_data_stream;
  command Command;
  unsigned Packet_count;

#pragma HLS dataflow
  Collect_packets(Tuple_input.Traffic_class, Tuple_input.Block_index, Tuple_input.Packet_index,
      Tuple_input.k, Packet_input, Data_streams, Packet_info_streams, Command, Packet_count, true);
  Select_packets(Tuple_input.Traffic_class, Data_streams, Packet_info_streams, Tuple_input.k,
      Command, Packet_count, Raw_data_stream, Encoded_data_stream, Packet_info_stream_1,
      Packet_info_stream_6);
  Preprocess_headers(Encoded_data_stream, Packet_info_stream_1, Tuple_input.k, Command,
      Data_stream_2, Packet_info_stream_2);
  Reorder_packets(Data_stream_2, Packet_info_stream_2, Command, Tuple_input.k, Ping_pong_buffer,
      Packet_info_stream_3, Packet_indices);
  Decode_packets(Ping_pong_buffer, Packet_info_stream_3, Packet_indices, Command, Tuple_input.k,
      Decoded_data_stream, Packet_info_stream_4);
  Postprocess_headers(Decoded_data_stream, Packet_info_stream_4, Tuple_input.k, Command,
      Postprocessed_data_stream, Packet_info_stream_5);
  Output_packets(Postprocessed_data_stream, Raw_data_stream, Packet_info_stream_5,
      Packet_info_stream_6, Packet_count, Command, Tuple_input.k, Packet_output,
      Tuple_output->Packet_count);
}
