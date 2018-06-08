#include "MemHLS.h"
#include "Memcore.h"
#include <iostream>
static void Collect_packets(hls::stream<packet_interface> &Packet_input, hls::stream<Data_Word> DATA_FIFO)
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
	bool End = false;
	unsigned Packet_length = 0;
	packet_interface Input;
	do 
	{
		Input = Packet_input.read();
		End = Input.End_of_frame;
		RAW_DATA.write(Input.Data);
		Packet_length += Input.Count;
	}while(!End);


	//testing 
	Data_Word buffer;
	for (int j = 1; j<150; j++) {
	buffer = RAW_DATA.read();
	char temp[8];
	for (int i = 7; i >= 0; i--)
	{
		temp[i] = buffer % 256;
		buffer = buffer/256;
	}
	for (int i = 0; i< 8; i++)
	std::cout << temp[i];	
	}
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
}
