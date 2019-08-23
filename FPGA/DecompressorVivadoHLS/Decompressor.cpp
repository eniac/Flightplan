#include "Decompressor.h"
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
	tuple_out.headerDecompress_output = tuple_in.headerDecompress_input;
	doCompress = false;
	//compressorCache[27].ipHeader.srcAddr = 1;	
#ifndef NO_FLIGHTPLAN_HEADER
	for (int i = 0; i < 4; i++)
	{
	#pragma HLS pipeline II=1
		packet = Packet_input.read();
		Packet_output.write(packet);
	}
#endif
	if (tuple_in.headerDecompress_input.Stateful_valid)
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
		curPktTup.idx = (curPktTup.ipHeader.srcAddr) % CACHE_SZ;
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
			
			cHeader.__pad = 0;
			//rebuild Tuple_out
			// Change Ethernet type
			tuple_out.Hdr.Eth = tuple_in.Hdr.Eth;
			tuple_out.Hdr.Eth.Type = ETYPE_COMPRESSED;
			
			//CompressedHeader
			tuple_out.Hdr.Ipv4.version = cHeader.slotID.range(7,4);
			tuple_out.Hdr.Ipv4.ihl = cHeader.slotID.range(3,0);
			tuple_out.Hdr.Ipv4.diffserv.range(1,0) = cHeader.slotID.range(9,8);
			tuple_out.Hdr.Ipv4.diffserv.range(2,2) = cHeader.seqChange;
			tuple_out.Hdr.Ipv4.diffserv.range(3,3) = cHeader.ackChange;
			tuple_out.Hdr.Ipv4.diffserv.range(7,4) = cHeader.__pad;
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

void Decompressor(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
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
	tuple_out.headerDecompress_output = tuple_in.headerDecompress_input;
	packet_interface packet;
		
	bool doDecompress = false;
	static compressorTuple_t compressorCache[CACHE_SZ];
	if (tuple_in.headerDecompress_input.Stateful_valid)
	{
		if (tuple_in.Hdr.Cmp.isValid)
			doDecompress = true;
		else if (tuple_in.Hdr.Ipv4.totallen > 85)
		{
			compressorTuple_t curPktTup;
			curPktTup.len = (ETH_HDR_LEN) +  tuple_in.Hdr.Ipv4.totallen;
			curPktTup.ipHeader = tuple_in.Hdr.Ipv4;
			curPktTup.tcpHeader = tuple_in.Hdr.Tcp;
			curPktTup.idx = crchash(tuple_in.Hdr.Ipv4, tuple_in.Hdr.Tcp) % CACHE_SZ;
			compressorCache[curPktTup.idx] = curPktTup;

		}
	}
	if (!doDecompress)
	{
		Output_tuples.write(tuple_out);
		ejectPacket(Packet_input,Packet_output);
	}
	else
	{	
		tuple_out.Hdr.Cmp.isValid = 0;
		compressorTuple_t curPktTup;
		curPktTup.idx = tuple_in.Hdr.Cmp.slotID;		
		curPktTup = compressorCache[curPktTup.idx];
		tuple_out.Hdr.Eth.Type = 0x0800;
		tuple_out.Hdr.Ipv4 = curPktTup.ipHeader;
		tuple_out.Hdr.Tcp = curPktTup.tcpHeader;
		tuple_out.Hdr.Tcp.urgent = tuple_in.Hdr.Cmp.urgent;
		tuple_out.Hdr.Tcp.flags = tuple_in.Hdr.Cmp.flags;
		tuple_out.Hdr.Tcp.window = tuple_in.Hdr.Cmp.window;
		tuple_out.Hdr.Tcp.check = tuple_in.Hdr.Cmp.check;
		tuple_out.Hdr.Ipv4.identification = tuple_in.Hdr.Cmp.identification;
		tuple_out.Hdr.Ipv4.totallen = tuple_in.Hdr.Cmp.totallen;
		tuple_out.Parser_extracts.Size = 0x1b0; //size of tcp +ip + eth Headers
			
		uint8_t optional_num = 0;
		packet_interface packet;
		for (int i = 0; i < 4; i++)
			packet = Packet_input.read(); 
		
		if (tuple_in.Hdr.Cmp.seqChange)
		{
			optional_num++;
			tuple_out.Hdr.Tcp.seq = packet.Data.range(31,0);
		}
		if (tuple_in.Hdr.Cmp.ackChange)
		{
			if (optional_num) packet = Packet_input.read();
			tuple_out.Hdr.Tcp.ack = packet.Data.range(31 + 32 * optional_num,  32 * optional_num);
			optional_num++;
		}
		
		tuple_out.Hdr.Ipv4.hdrchecksum = chksumcalc(tuple_out.Hdr.Ipv4);	
		Output_tuples.write(tuple_out);
		//ejectPacket(Packet_input,Packet_output);
		
		//Output Pkt
		packet_interface out;
		out.Start_of_frame = 1;
		out.Data = 0;
		out.Count = 8;
		out.Error = 0;
		out.End_of_frame = 0;
		Packet_output.write(out);
		out.Start_of_frame = 0;
		for (int i = 1; i < 6; i++)
		#pragma HLS pipeline II = 1
			Packet_output.write(out);
		
		uint8_t shift = 0;	
		uint8_t remain = 0;
		if (optional_num == 1)
		{
			packet = Packet_input.read();
			out.Data.range(15,0) = packet.Data.range(63,48);
			remain = 6;
			Packet_output.write(out);
		}
		else
		{
			out.Data.range(15,0) = packet.Data.range(31,16);
			remain = 2;
			Packet_output.write(out);
		}
		shift = 8 - remain;
		out.Data.range(63, 64 - remain * 8) = packet.Data.range(remain * 8 -1, 0);
		packet = Packet_input.read();
		while(!packet.End_of_frame)
		{
		#pragma HLS pipeline II = 1
			out.Data.range(shift * 8 - 1, 0) = packet.Data.range(63, 64 - 8 * shift);
			Packet_output.write(out);
			out.Data.range(63, 64 - remain * 8) = packet.Data.range(remain * 8 -1, 0);
			packet = Packet_input.read();
		}
		if (packet.Count <= shift)
		{
			out.End_of_frame = 1;
			out.Count = packet.Count + remain;
			out.Data.range(shift * 8 - 1, 64 - out.Count * 8) = packet.Data.range(63, 64 - packet.Count * 8);
			Packet_output.write(out);
		}
		else
		{
			out.Data.range(shift*8 -1 , 0) = packet.Data.range(63, 64 - 8 * shift);
			Packet_output.write(out);
			out.End_of_frame = 1;
			out.Count = packet.Count + remain - 8;
			out.Data.range(63, 64 - out.Count * 8) = packet.Data.range(63 - 8 * shift, 64 - packet.Count * 8);
			Packet_output.write(out);
		}
	
			
	}
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
}

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
ap_uint<16> chksumcalc(tuple_ipv4 ip)
{
#pragma HLS inline
	ap_uint<32> temp = 0;
	ap_uint<16> Byte;
	Byte.range(15,12) = ip.version;
	Byte.range(11,8) = ip.ihl;
	Byte.range(7,0) = ip.diffserv;
	temp += Byte;
	temp = temp + ip.totallen;
	temp = temp + ip.identification;
	Byte.range(15,13) = ip.flags;
	Byte.range(12,0) = ip.fragoffset;
	temp += Byte;
	Byte.range(15,8) = ip.ttl;
	Byte.range(7,0) = ip.protocol;
	temp += Byte;
	temp = temp + ip.srcAddr.range(31,16) + ip.srcAddr.range(15,0);
	temp = temp + ip.dstAddr.range(31,16) + ip.dstAddr.range(15,0);
	ap_uint<16> ans = temp.range(19,16) + temp.range(15,0);	
	ans = ~ans;
	return ans;
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
