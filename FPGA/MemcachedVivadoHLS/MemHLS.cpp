#include "MemHLS.h"
#include "Memcore.h"
#include <iostream>
static void Collect_packets(hls::stream<packet_interface> & Packet_input,hls::stream<Data_Word> DATA_FIFO)
{
	bool End = false;
	unsigned Packet_length = 0;
	packet_interface Input;
	do 
	{
		Input = Packet_input.read();
		End = Input.End_of_frame;
		DATA_FIFO.write(Input.Data);
		Packet_length += Input.Count;
		std::cout << Input.Data << std::endl;
	}while(!End);
}
void Memcore(hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output)
{
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
	hls::stream<Data_Word> RAW_DATA;
	Collect_packets(Packet_input, RAW_DATA);	
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
}
