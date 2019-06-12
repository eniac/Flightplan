#include "Compressor.h"
#include <iostream>



static uint16_t Packet_num = 1;
using namespace std;

void Compressor(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output)
{
#pragma HLS DATA_PACK variable=Input_tuples
#pragma HLS DATA_PACK variable=Output_tuples
#pragma HLS DATA_PACK variable=Packet_input
#pragma HLS DATA_PACK variable=Packet_output
#pragma HLS INTERFACE ap_fifo port=Input_tuples
#pragma HLS INTERFACE ap_hs port=Output_tuples
#pragma HLS INTERFACE ap_fifo port=Packet_input
#pragma HLS INTERFACE ap_hs port=Packet_output

#pragma HLS dataflow
	int DATA_FIFO_SIZE = 400;
	int INST_FIFO_SIZE = 100;
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
	std::cout << "The No. "<< Packet_num << "Packet"  << std::endl;
	if (Packet_num % 100 ==0)
	cerr << "Current Pkt:" << Packet_num << endl;
	Packet_num++;

	input_tuples tuple_in;
	output_tuples tuple_out;
	bool doCompress = false;
	packet_interface packet;

	static compressorTuple_t compressorCache[CACHE_SZ] = {0};
	//inititalize the tuples	
	tuple_in = Input_tuples.read();
	tuple_out.Hdr = tuple_in.Hdr;
	tuple_out.Control = tuple_in.Control;
	tuple_out.Ioports = tuple_in.Ioports;
	tuple_out.Local_state = tuple_in.Local_state;
	tuple_out.Parser_extracts = tuple_in.Parser_extracts;
	tuple_out.CheckTcp = tuple_in.CheckTcp;
	tuple_out.headerCompress_output = tuple_in.headerCompress_input;
	doCompress = false;
	//compressorCache[27].ipHeader.srcAddr = 1;	
	if (tuple_in.headerCompress_input.Stateful_valid)
	{
		if (tuple_in.Hdr.Ipv4.totallen > 85)
			doCompress = true;
	}
	
	if (!doCompress)
	{
		Output_tuples.write(tuple_out);
		ejectPacket(Packet_input,Packet_output);
	}
	else
	{
		compressorTuple_t curPktTup;
		curPktTup.len = (ETH_HDR_LEN) +  tuple_in.Hdr.Ipv4.totallen;
		curPktTup.ipHeader = tuple_in.Hdr.Ipv4;
		curPktTup.tcpHeader = tuple_in.Hdr.Tcp;
		curPktTup.idx = crchash(tuple_in.Hdr.Ipv4, tuple_in.Hdr.Tcp) % CACHE_SZ;
		bool isHit = true;
		
		compressorTuple_t lastPkt = compressorCache[curPktTup.idx];
		// If all keys are equal, return true.
		if (lastPkt.ipHeader.srcAddr != curPktTup.ipHeader.srcAddr)
			isHit = false;
		if (lastPkt.ipHeader.dstAddr != curPktTup.ipHeader.dstAddr)
			isHit = false;
		if (lastPkt.tcpHeader.sport != curPktTup.tcpHeader.sport)
			isHit = false;
		if (lastPkt.tcpHeader.dport != curPktTup.tcpHeader.dport)
			isHit = false;
		if (!isHit)
		{
			compressorCache[curPktTup.idx] = curPktTup;
			Output_tuples.write(tuple_out);
			ejectPacket(Packet_input,Packet_output);
		}
		/*
		else 
		{
			curPktTup.ipHeader.srcAddr = 1;
			compressorCache[curPktTup.idx] = curPktTup;
			Output_tuples.write(tuple_out);
			ejectPacket(Packet_input,Packet_output);
		}
		*/
		
		else
		{
			
			//update compressed Hdr		
			compressorTuple_t lastPkt = compressorCache[curPktTup.idx];
			compressedHeader_t cHeader;
			cHeader.slotID = curPktTup.idx;
			cHeader.totallen = curPktTup.ipHeader.totallen;
			cHeader.identification = curPktTup.ipHeader.identification;
			cHeader.flags = curPktTup.tcpHeader.flags;
			cHeader.window = curPktTup.tcpHeader.window;
			cHeader.check = curPktTup.tcpHeader.check;
			cHeader.urgent = curPktTup.tcpHeader.urgent;
			
			if (lastPkt.tcpHeader.seq != curPktTup.tcpHeader.seq) 
				cHeader.seqChange = 1;
			else cHeader.seqChange = 0;
			
			if (lastPkt.tcpHeader.ack != curPktTup.tcpHeader.ack)
				cHeader.ackChange = 1;
			else cHeader.ackChange = 0;
			
			cout << "The SlotID is: " << cHeader.slotID << endl;
			cout << "The seqchange is: " << cHeader.seqChange << endl;
			cout << "The ackchange is: " << cHeader.ackChange << endl; 
			cout << "The totallen is: " << cHeader.totallen << endl;
			cout << "The id is: " << cHeader.identification << endl;
			cout << "The flag is: " << cHeader.flags << endl;
			cout << "The window is: " << cHeader.window << endl;
			cout << "The check is: " << cHeader.check << endl;
			cout << "The urgent is: " << cHeader.urgent << endl; 	
			cHeader.__pad = 0;
			//rebuild Tuple_out
			// Change Ethernet type
			tuple_out.Hdr.Eth = tuple_in.Hdr.Eth;
			tuple_out.Hdr.Eth.Type = ETYPE_COMPRESSED;
			
			//CompressedHeader
			tuple_out.Hdr.Ipv4.version = cHeader.slotID.range(9,6);
			tuple_out.Hdr.Ipv4.ihl = cHeader.slotID.range(5,2);
			tuple_out.Hdr.Ipv4.diffserv.range(7,6) = cHeader.slotID.range(1,0);
			tuple_out.Hdr.Ipv4.diffserv.range(5,5) = cHeader.seqChange;
			tuple_out.Hdr.Ipv4.diffserv.range(4,4) = cHeader.ackChange;
			tuple_out.Hdr.Ipv4.diffserv.range(3,0) = cHeader.__pad;
			tuple_out.Hdr.Ipv4.totallen = cHeader.totallen;
			tuple_out.Hdr.Ipv4.identification = cHeader.identification;
			tuple_out.Hdr.Ipv4.flags = cHeader.flags.range(15,13);
			tuple_out.Hdr.Ipv4.fragoffset = cHeader.flags.range(12,0);
			tuple_out.Hdr.Ipv4.ttl = cHeader.window.range(15,8);
			tuple_out.Hdr.Ipv4.protocol = cHeader.window.range(7,0);
			tuple_out.Hdr.Ipv4.hdrchecksum = cHeader.check;
			tuple_out.Hdr.Ipv4.srcAddr.range(31,16) = cHeader.urgent;	
			//Optional Field
			uint8_t optionalNum = cHeader.seqChange + cHeader.ackChange;
			if (cHeader.seqChange == 1 && cHeader.ackChange == 1)
			{
				tuple_out.Hdr.Ipv4.srcAddr.range(15,0) = curPktTup.tcpHeader.seq.range(31,16);
				tuple_out.Hdr.Ipv4.dstAddr.range(31,16) = curPktTup.tcpHeader.seq.range(15,0);
				tuple_out.Hdr.Ipv4.dstAddr.range(15,0) = curPktTup.tcpHeader.ack.range(31,16);
				tuple_out.Hdr.Tcp.sport = curPktTup.tcpHeader.ack.range(15,0);
			}	
			else if(cHeader.seqChange == 1 && cHeader.ackChange == 0)
			{
				tuple_out.Hdr.Ipv4.srcAddr.range(15,0) = curPktTup.tcpHeader.seq.range(31,16);
				tuple_out.Hdr.Ipv4.dstAddr.range(31,16) = curPktTup.tcpHeader.seq.range(15,0);
			}
			else if(cHeader.seqChange == 0 && cHeader.ackChange == 1)
			{
				tuple_out.Hdr.Ipv4.srcAddr.range(15,0) = curPktTup.tcpHeader.ack.range(31,16);
				tuple_out.Hdr.Ipv4.dstAddr.range(31,16) = curPktTup.tcpHeader.ack.range(15,0);
			}
			
			//Shift Packet into tuple field
			//pre-read header field in original packet
			for (int i = 0; i < 6; i++)
			{
			#pragma HLS pipeline II=1
				packet = Packet_input.read();
				Packet_output.write(packet);
			}
			packet = Packet_input.read();
			Data_Word pktdata = packet.Data;
				

			if (optionalNum == 2)
			{
				tuple_out.Hdr.Tcp.dport = pktdata.range(15,0);

				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.seq = pktdata.range(63,32);
				tuple_out.Hdr.Tcp.ack = pktdata.range(31,0);

				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.flags = pktdata.range(63,48);
				tuple_out.Hdr.Tcp.window = pktdata.range(47,32);
				tuple_out.Hdr.Tcp.check = pktdata.range(31,16);
				tuple_out.Hdr.Tcp.urgent = pktdata.range(15,0);	
			}

			else if (optionalNum == 1)
			{
				tuple_out.Hdr.Ipv4.dstAddr.range(15,0) = pktdata.range(15,0);
				
				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.sport = pktdata.range(63,48);
				tuple_out.Hdr.Tcp.dport = pktdata.range(47,32);
				tuple_out.Hdr.Tcp.seq = pktdata.range(31,0);
	
				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.ack = pktdata.range(63,32);
				tuple_out.Hdr.Tcp.flags = pktdata.range(31,16);
				tuple_out.Hdr.Tcp.window = pktdata.range(15,0);
				
				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.check = pktdata.range(63,48);
				tuple_out.Hdr.Tcp.urgent = pktdata.range(47,32);
			}
			else if (optionalNum == 0)
			{
				tuple_out.Hdr.Ipv4.srcAddr.range(15,0) = pktdata.range(15,0);
				
				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Ipv4.dstAddr = pktdata.range(63,32);
				tuple_out.Hdr.Tcp.sport = pktdata.range(31,16);
				tuple_out.Hdr.Tcp.dport = pktdata.range(15,0);
				tuple_out.Hdr.Tcp.seq = pktdata.range(31,0);
				
				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.seq = pktdata.range(63,32);
				tuple_out.Hdr.Tcp.ack = pktdata.range(31,0);

				packet = Packet_input.read();
				pktdata = packet.Data;
				tuple_out.Hdr.Tcp.flags = pktdata.range(63,48);
				tuple_out.Hdr.Tcp.window = pktdata.range(47,32);
				tuple_out.Hdr.Tcp.check = pktdata.range(31,16);
				tuple_out.Hdr.Tcp.urgent = pktdata.range(15,0);	
			}
			//Forward payload
			uint8_t ShiftCount;
			packet_interface TempPacket;
			if (optionalNum != 1)
			{
				ShiftCount = 2 * 8; // in bits
			}	
			else
			{	
				ShiftCount = 6 * 8; // in bits
				TempPacket.End_of_frame = 0;
				TempPacket.Start_of_frame = 0;
				TempPacket.Count = 8;
				TempPacket.Data.range(15,0) = pktdata.range(31,16);
				Packet_output.write(TempPacket);
				
			}
			uint8_t RemainCount = BYTES_PER_WORD * 8 - ShiftCount;
			TempPacket.End_of_frame = 0;
			TempPacket.Start_of_frame = 0;
			TempPacket.Data.range(63,64 - RemainCount) = pktdata.range(RemainCount - 1,0);
			TempPacket.Count = 8;

			packet = Packet_input.read();
			while(!packet.End_of_frame)
			{
			#pragma HLS pipeline II = 1
				TempPacket.Data.range(ShiftCount - 1,0) = packet.Data.range(63,64 - ShiftCount);
				TempPacket.Error = packet.Error;
				Packet_output.write(TempPacket);
				TempPacket.Data.range(63,64 - RemainCount) = packet.Data.range(RemainCount - 1,0);	
				packet = Packet_input.read();
			}

			if (packet.Count <= ShiftCount / 8)
			{
				TempPacket.Count = packet.Count + RemainCount / 8;
				TempPacket.Data.range(63 - RemainCount, 64 - 8*TempPacket.Count) 
					= packet.Data.range(63, 64 - 8*packet.Count); 
				TempPacket.End_of_frame = 1;
				Packet_output.write(TempPacket); 
			}
			else 
			{
				TempPacket.Count = 8;
				TempPacket.Data.range(ShiftCount - 1,0) = packet.Data.range(63,64 - ShiftCount);
				TempPacket.End_of_frame = 0;
				Packet_output.write(TempPacket);
				TempPacket.Count = packet.Count - ShiftCount / 8; 
				TempPacket.End_of_frame = 1;
				TempPacket.Data.range(63, 64 - TempPacket.Count * 8) 
					= packet.Data.range(RemainCount - 1, 64 - packet.Count * 8); 
				Packet_output.write(TempPacket);
			}
			
			Output_tuples.write(tuple_out);
		}
		
		
	}

		
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;

}

void ompressor(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
			 hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output)
{
#pragma HLS DATA_PACK variable=Input_tuples
#pragma HLS DATA_PACK variable=Output_tuples
#pragma HLS DATA_PACK variable=Packet_input
#pragma HLS DATA_PACK variable=Packet_output
#pragma HLS INTERFACE ap_fifo port=Input_tuples
#pragma HLS INTERFACE ap_hs port=Output_tuples
#pragma HLS INTERFACE ap_fifo port=Packet_input
#pragma HLS INTERFACE ap_hs port=Packet_output

#pragma HLS dataflow
	int DATA_FIFO_SIZE = 400;
	int INST_FIFO_SIZE = 100;
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
	std::cout << "The No. "<< Packet_num << "Packet"  << std::endl;
	Packet_num++;

	input_tuples tuple_in;
	output_tuples tuple_out;
	tuple_in = Input_tuples.read();
	tuple_out.Hdr = tuple_in.Hdr;
	tuple_out.Control = tuple_in.Control;
	tuple_out.Ioports = tuple_in.Ioports;
	tuple_out.Local_state = tuple_in.Local_state;
	tuple_out.Parser_extracts = tuple_in.Parser_extracts;
	tuple_out.CheckTcp = tuple_in.CheckTcp;
	tuple_out.headerCompress_output = tuple_in.headerCompress_input;
	Output_tuples.write(tuple_out);
	packet_interface packet;
	do 
	{
		packet = Packet_input.read();
		Packet_output.write(packet);
	}while(!packet.End_of_frame);
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
}
/*
bool checkCache(compressorTuple_t & curPktTup){  
#pragma HLS inline 
	compressorTuple_t lastPkt = compressorCache[curPktTup.idx];
	// If all keys are equal, return true.
	if(lastPkt.ipHeader.srcAddr == curPktTup.ipHeader.srcAddr){
	if(lastPkt.ipHeader.dstAddr == curPktTup.ipHeader.dstAddr){
	if(lastPkt.tcpHeader.sport == curPktTup.tcpHeader.sport){
	if(lastPkt.tcpHeader.dport == curPktTup.tcpHeader.dport){
		return true;
	}
	}
	}
	}
	return false;
}
*/
void ejectPacket(hls::stream<packet_interface> &Packet_input, hls::stream<packet_interface> & Packet_output)
{
#pragma HLS inline
	packet_interface data;
	do
	{
#pragma HLS pipeline II = 1
		data = Packet_input.read();
		Packet_output.write(data);
	}while(!data.End_of_frame);
}
ap_uint<10> crchash(tuple_ipv4 ip, tuple_tcp tcp)
{
#pragma HLS inline
        ap_uint<16> temp = 0;
        temp ^= (ip.srcAddr.range(31,16) ^ ip.srcAddr.range(15,0));
        temp ^= 0x8005;
        temp ^= (ip.dstAddr.range(31,16) ^ ip.dstAddr.range(15,0));
        temp.range(15,1) = temp.range(14,0);
        temp.range(0,0) = 0;
        temp ^= tcp.sport;
        temp.range(14,0) = temp.range(15,1);
        temp.range(15,15) = 1;
        temp ^= tcp.dport;

        return temp.range(9,0);
}
