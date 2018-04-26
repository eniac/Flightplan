#include <fstream>

#include "Decoder.h"

void RSE_core(input_tuple Input_tuple, output_tuple * Output_tuple, packet_interface * Input_packet,
    packet_interface * Output_packet);

input_tuple Input_tuples[] = { {0, 0, 0, 5, 1}, {1, 0, 0, 5, 1}, {2, 0, 0, 5, 1}, {3, 0, 0, 5, 1}, {
    4, 0, 0, 5, 1}, {5, 0, 0, 5, 1}, {0, 1, 0, 5, 1}, {1, 1, 0, 5, 1}, {2, 1, 0, 5, 1}, {3, 1, 0, 5,
    1}, {4, 1, 0, 5, 1}, {5, 1, 0, 5, 1}, };

int main()
{
  std::ifstream Packet_stream("Packet_in.axi");

  int Iteration = 0;
  while (1)
  {
    input_tuple Input_tuple;
    output_tuple Output_tuple;
    packet_interface Input_packet[FEC_MAX_PACKET_SIZE];
    packet_interface Output_packet[FEC_MAX_PACKET_SIZE];

    int Position = 0;
    int End = 0;
    while (!End)
    {
      int Enables;
      unsigned long long Word;
      Packet_stream >> End >> std::hex >> Enables >> Word >> std::dec;
      if (Packet_stream.eof())
        break;

      if (!Packet_stream.good())
        exit(1);

      Input_packet[Position].Data = 0;
      for (int i = 0; i < 8; i++)
      {
        Input_packet[Position].Data <<= 8;
        Input_packet[Position].Data |= Word & 0xFF;
        Word >>= 8;
      }
      Input_packet[Position].Start_of_frame = (Position == 0);
      Input_packet[Position].End_of_frame = End;
      Input_packet[Position].Count = 0;
      while (Enables > 0)
      {
        if (Enables & 1)
          Input_packet[Position].Count++;
        Enables >>= 1;
      }
      Input_packet[Position].Error = 0;

      Position++;
    }

    if (Position == 0)
      break;

    Input_tuple = Input_tuples[Iteration++];

    Decode(Input_tuple, &Output_tuple, Input_packet, Output_packet);

    Position = 0;
    for (int Packet = 0; Packet < Output_tuple.Packet_count; Packet++)
    {
      while (1)
      {
        data_word Word = 0;
        for (int i = 0; i < 8; i++)
        {
          Word <<= 8;
          Word |= (Output_packet[Position].Data >> (8 * i)) & 0xFF;
        }

        std::cout << Output_packet[Position].Start_of_frame << ' '
            << Output_packet[Position].End_of_frame << ' ' << std::setfill('0') << std::setw(16)
            << std::hex << static_cast<unsigned long long>(Word) << std::dec << ' '
            << Output_packet[Position].Count << ' ' << Output_packet[Position].Error << std::endl;
        if (Output_packet[Position++].End_of_frame)
          break;
      };
    }
  }

  return 0;
}
