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
    unsigned k, const packet_interface Packet_input[WORDS_PER_PACKET],
    hls::stream<data_word> Data_FIFOs[TRAFFIC_CLASS_COUNT],
    hls::stream<packet_info> Info_FIFOs[TRAFFIC_CLASS_COUNT], command & Command,
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
    Info_FIFOs[Traffic_class].write(Info);
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
    hls::stream<packet_info> & Input_info_FIFO, unsigned k, command Command,
    hls::stream<data_word> & Output_FIFO, hls::stream<packet_info> & Output_info_FIFO)
{
  if (Command == COMMAND_DECODE)
  {
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Input_info_FIFO.read();
      unsigned Bytes_per_packet = Info.Bytes_per_packet;
      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Bytes_per_packet, BYTES_PER_WORD);

      ap_uint<2 * FEC_AXI_BUS_WIDTH> Data = Bytes_per_packet;
      unsigned Count = Info.Data_packet ? FEC_PACKET_LENGTH_WIDTH / 8 : 0;
      unsigned Offset = 0;
      for (unsigned Word_offset = 0; Word_offset < Words_per_packet; Word_offset++)
      {
#pragma HLS pipeline
        data_word Input = Input_FIFO.read();

        for (unsigned Byte_offset = 0; Byte_offset < BYTES_PER_WORD; Byte_offset++)
        {
          bool Output = (Info.Data_packet && Offset < FEC_ETH_HEADER_SIZE / 8)
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

      Info.Bytes_per_packet -= HEADER_SIZE / 8;
      if (!Info.Data_packet)
        Info.Bytes_per_packet -= FEC_ETH_HEADER_SIZE / 8;
      else
        Info.Bytes_per_packet += FEC_PACKET_LENGTH_WIDTH / 8;
      Output_info_FIFO.write(Info);
    }
  }
}

static void Reorder_packets(hls::stream<data_word> & Input_FIFO,
    hls::stream<packet_info> & Input_info_FIFO, command Command, unsigned k,
    data_word Output_buffer[FEC_MAX_K][PING_PONG_BUFFER_SIZE],
    hls::stream<packet_info> & Output_info_FIFO, packet_index Packet_indices[FEC_MAX_K])
{
  if (Command == COMMAND_DECODE)
  {
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Input_info_FIFO.read();
      Output_info_FIFO.write(Info);
      Packet_indices[Packet] = Info.Packet_index;

      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Info.Bytes_per_packet, BYTES_PER_WORD);
      for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
        Output_buffer[Packet][Offset] = Input_FIFO.read();
    }
  }
}

static void Decode_packets(data_word Input_buffer[FEC_MAX_K][PING_PONG_BUFFER_SIZE],
    hls::stream<packet_info> & Input_info_FIFO, packet_index Packet_indices[FEC_MAX_K],
    command Command, unsigned k, hls::stream<data_word> & Output_data,
    hls::stream<packet_info> & Output_info_FIFO)
{
  if (Command == COMMAND_DECODE)
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Input_info_FIFO.read();

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

      Output_info_FIFO.write(Info);
    }
}

static void Postprocess_headers(hls::stream<data_word> & Input_FIFO,
    hls::stream<packet_info> & Input_info_FIFO, unsigned k, command Command,
    hls::stream<data_word> & Output_FIFO, hls::stream<packet_info> & Output_info_FIFO)
{
  if (Command == COMMAND_DECODE)
  {
    for (unsigned Packet = 0; Packet < k; Packet++)
    {
      packet_info Info = Input_info_FIFO.read();
      unsigned Bytes_per_packet = Info.Bytes_per_packet;
      unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(
          Info.Bytes_per_packet + FEC_PACKET_LENGTH_WIDTH / 8, BYTES_PER_WORD);

      ap_uint<2 * FEC_AXI_BUS_WIDTH> Data = 0;
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

      Output_info_FIFO.write(Info);
    }
  }
}

static void Output_packets(input_tuples Tuple_input, output_tuples Tuple_output[FEC_MAX_K],
    hls::stream<data_word> & Input_data_FIFO, hls::stream<packet_info> & Input_info_FIFO,
    unsigned Packet_count, packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
  unsigned Output_offset = 0;
  for (unsigned Packet = 0; Packet < Packet_count; Packet++)
  {
    packet_info Info = Input_info_FIFO.read();
    unsigned Bytes_per_packet = Info.Bytes_per_packet;
    unsigned Words_per_packet = DIVIDE_AND_ROUND_UP(Info.Bytes_per_packet, BYTES_PER_WORD);
    ap_uint<FEC_ETH_HEADER_SIZE> Header;
    for (unsigned Offset = 0; Offset < Words_per_packet; Offset++)
    {
#pragma HLS pipeline
      data_word Word = Input_data_FIFO.read();

      if (Offset < DIVIDE_AND_ROUND_UP(FEC_ETH_HEADER_SIZE / 8, BYTES_PER_WORD))
        Header = (Header << FEC_AXI_BUS_WIDTH) | Word;

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

    Tuple_output[Packet].Decoder_output.Packet_count = Packet_count;
    Tuple_output[Packet].Hdr.FEC = Tuple_input.Hdr.FEC;
    Tuple_output[Packet].Hdr.Eth = Header;
    Tuple_output[Packet].Ioports = Tuple_input.Ioports;
    Tuple_output[Packet].Local_state = Tuple_input.Local_state;
    Tuple_output[Packet].Parser_extracts = Tuple_input.Parser_extracts;
    Tuple_output[Packet].Update_fl = Tuple_input.Update_fl;
  }
}

static void Output_packets(input_tuples Tuple_input, output_tuples Tuple_output[FEC_MAX_K],
    hls::stream<data_word> & Decoded_data_FIFO, hls::stream<data_word> & Raw_data_FIFO,
    hls::stream<packet_info> & Decoded_info_FIFO, hls::stream<packet_info> & Raw_info_FIFO,
    unsigned Packet_count, command Command, unsigned k,
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
  if (Command == COMMAND_DECODE)
    Output_packets(Tuple_input, Tuple_output, Decoded_data_FIFO, Decoded_info_FIFO, k,
        Packet_output);
  else if (Command == COMMAND_OUTPUT_DATA)
    Output_packets(Tuple_input, Tuple_output, Raw_data_FIFO, Raw_info_FIFO, Packet_count,
        Packet_output);
  else
  {
    Tuple_output[0].Decoder_output.Packet_count = 0;
    Tuple_output[0].Hdr = Tuple_input.Hdr;
    Tuple_output[0].Ioports = Tuple_input.Ioports;
    Tuple_output[0].Local_state = Tuple_input.Local_state;
    Tuple_output[0].Parser_extracts = Tuple_input.Parser_extracts;
    Tuple_output[0].Update_fl = Tuple_input.Update_fl;
  }
}

void Process_packet(input_tuples Tuple_input, output_tuples Tuple_output[FEC_MAX_K],
    const packet_interface Packet_input[WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
#pragma HLS dataflow

  const int Stream_size = WORDS_PER_PACKET;

  data_word Ping_pong_buffer[FEC_MAX_K][PING_PONG_BUFFER_SIZE];
  packet_index Packet_indices[FEC_MAX_K];
  static hls::stream<data_word> Data_streams[TRAFFIC_CLASS_COUNT];
#pragma HLS STREAM variable=Data_streams depth=Stream_size
  static hls::stream<packet_info> Info_streams[TRAFFIC_CLASS_COUNT];
#pragma HLS STREAM variable=Info_streams depth=Stream_size
  hls::stream<data_word> Encoded_data_stream;
  hls::stream<data_word> Preprocessed_data_stream;
  hls::stream<data_word> Decoded_data_stream;
  hls::stream<data_word> Postprocessed_data_stream;
  hls::stream<data_word> Raw_data_stream;
  hls::stream<packet_info> Encoded_info_stream;
  hls::stream<packet_info> Preprocessed_info_stream;
  hls::stream<packet_info> Reordered_info_stream;
  hls::stream<packet_info> Decoded_info_stream;
  hls::stream<packet_info> Postprocessed_info_stream;
  hls::stream<packet_info> Raw_info_stream;
  command Command;
  unsigned Packet_count;

  tuple_Decoder_input Decoder_input = Tuple_input.Decoder_input;

  Collect_packets(Decoder_input.Traffic_class, Decoder_input.Block_index,
      Decoder_input.Packet_index, Decoder_input.k, Packet_input, Data_streams, Info_streams,
      Command, Packet_count, true);
  Select_packets(Decoder_input.Traffic_class, Data_streams, Info_streams, Decoder_input.k, Command,
      Packet_count, Raw_data_stream, Encoded_data_stream, Encoded_info_stream, Raw_info_stream);
  Preprocess_headers(Encoded_data_stream, Encoded_info_stream, Decoder_input.k, Command,
      Preprocessed_data_stream, Preprocessed_info_stream);
  Reorder_packets(Preprocessed_data_stream, Preprocessed_info_stream, Command, Decoder_input.k,
      Ping_pong_buffer, Reordered_info_stream, Packet_indices);
  Decode_packets(Ping_pong_buffer, Reordered_info_stream, Packet_indices, Command, Decoder_input.k,
      Decoded_data_stream, Decoded_info_stream);
  Postprocess_headers(Decoded_data_stream, Decoded_info_stream, Decoder_input.k, Command,
      Postprocessed_data_stream, Postprocessed_info_stream);
  Output_packets(Tuple_input, Tuple_output, Postprocessed_data_stream, Raw_data_stream,
      Postprocessed_info_stream, Raw_info_stream, Packet_count, Command, Decoder_input.k,
      Packet_output);
}

void Forward_packet(input_tuples Tuple_input, output_tuples Tuple_output[FEC_MAX_K],
    const packet_interface Packet_input[WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
  unsigned Offset = 0;
  packet_interface Input;
  do
  {
#pragma HLS pipeline
    Input = Packet_input[Offset];

    packet_interface Output;
    Output.Data = Input.Data;
    Output.Start_of_frame = Input.Start_of_frame;
    Output.End_of_frame = Input.End_of_frame;
    Output.Count = Input.Count;
    Output.Error = Input.Error;

    Packet_output[Offset++] = Output;
  }
  while (!Input.End_of_frame);

  Tuple_output[0].Decoder_output.Packet_count = 1;
  Tuple_output[0].Hdr = Tuple_input.Hdr;
  Tuple_output[0].Ioports = Tuple_input.Ioports;
  Tuple_output[0].Local_state = Tuple_input.Local_state;
  Tuple_output[0].Parser_extracts = Tuple_input.Parser_extracts;
  Tuple_output[0].Update_fl = Tuple_input.Update_fl;
}

void Decode(input_tuples Tuple_input, output_tuples Tuple_output[FEC_MAX_K],
    const packet_interface Packet_input[WORDS_PER_PACKET],
    packet_interface Packet_output[FEC_MAX_K * WORDS_PER_PACKET])
{
#pragma HLS DATA_PACK variable=Tuple_input
#pragma HLS DATA_PACK variable=Tuple_output
#pragma HLS DATA_PACK variable=Packet_input
#pragma HLS DATA_PACK variable=Packet_output
#pragma HLS INTERFACE ap_vld port=Tuple_input
#pragma HLS INTERFACE ap_hs port=Tuple_output
#pragma HLS INTERFACE ap_fifo port=Packet_input
#pragma HLS INTERFACE ap_hs port=Packet_output

  tuple_Decoder_input Decoder_input = Tuple_input.Decoder_input;
  if (Tuple_input.Decoder_input.Valid)
    Process_packet(Tuple_input, Tuple_output, Packet_input, Packet_output);
  else
    Forward_packet(Tuple_input, Tuple_output, Packet_input, Packet_output);
}