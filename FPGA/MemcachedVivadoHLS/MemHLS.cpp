#include "MemHLS.h"
#include <iostream>



static Cache Memory[MAX_MEMORY_SIZE];
static uint16_t Packet_num;
uint16_t hash(Data_Word Data)
{
#pragma HLS inline
	Data_Word temp = Data;
	uint16_t result = 0;
	Data = (~Data) + (Data << 21);
	Data = Data ^ (Data >> 24);
	Data = (Data + (Data << 3)) + (Data << 8);
	Data = Data ^ (Data >> 14);
	Data = (Data + (Data << 2)) + (Data << 4);
	Data = Data ^ (Data >> 28);
	Data = Data + (Data << 31);
	result = (uint16_t) (Data % MAX_MEMORY_SIZE);
	result ^= temp.range(16,0);
	result %= MAX_MEMORY_SIZE;
	return result;
}


uint8_t Find_delimiter(Data_Word &buffer)
{
#pragma HLS inline
	uint8_t result = 8;
	for (int i = 7; i >=0; i--)
	{
#pragma HLS unroll
		if (buffer.range((BYTES_PER_WORD - i)*8-1, (BYTES_PER_WORD - i -1)*8) == 0x0d || buffer.range((BYTES_PER_WORD - i)*8-1, (BYTES_PER_WORD - i -1)*8) == 0x20) result = i;
	}
	return result;
}

void Pktclassifier(hls::stream<input_tuples> &tuple_in,
				  hls::stream<input_tuples> &tuple_out,//1,hls::stream<input_tuples> &tuple_out2,
				  hls::stream<packet_interface> &pkt_in,
				  hls::stream<packet_interface> &pkt_out1, hls::stream<packet_interface> &pkt_out2,
				  hls::stream<MemcachedPkt> &Mempkt)
{
	input_tuples tuple = tuple_in.read();
    tuple_out.write(tuple);
	//if (tuple.Hdr.Ipv4.protocol != 0x11 || tuple.Hdr.Eth.Type != 0x0800 || tuple.Hdr.Udp.dport !=11211)
	//if (1)
    if (tuple.Memcached_input.Stateful_valid == 0)
	{
		//tuple_out.write(tuple);
		bool End = false;
		packet_interface Data;
		do
		{
	#pragma HLS pipeline II=1
			Data = pkt_in.read();
			End = Data.End_of_frame;
			pkt_out2.write(Data);
		}while(!End);
		MemcachedPkt mempkt = false;
		Mempkt.write(mempkt);


	}
	else
	{
		bool End = false;
		packet_interface Data;
		//tuple_out2.write(tuple);
		do
		{
	#pragma HLS pipeline II=1
			Data = pkt_in.read();
			End = Data.End_of_frame;
			pkt_out1.write(Data);
			pkt_out2.write(Data);
		}while(!End);
		MemcachedPkt mempkt = true;
		Mempkt.write(mempkt);
	}
}
void Extract_Data(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
				  hls::stream<packet_interface> &Packet_input, hls::stream<Part_Word> &Data_out)
{
	MemcachedPkt mempkt = Mempkt.read();
	Mempkt_out.write(mempkt);
	if (mempkt)
	{
		bool pktcomplete;
		pktcomplete = false;
		packet_interface tempin;
		Part_Word tempout;
		do
		{
	#pragma HLS pipeline II=1
	#pragma HLS loop_tripcount min=8 max=190
			tempin = Packet_input.read();
			tempout.len = tempin.Count;
			tempout.Data = tempin.Data;
			tempout.End = tempin.End_of_frame;
			Data_out.write(tempout);
		}while (!tempin.End_of_frame);
		//input_tuples Tuple = tuple_in.read();
		//tuple_out.write(Tuple);
	}

}

void Parse_Eth_Hdr(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
				   hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out)
{
	 MemcachedPkt mempkt = Mempkt.read();
	 Mempkt_out.write(mempkt);
	 if (mempkt)
	 {	 bool pktcomplete;
		 pktcomplete = false;
		 static enum Parser_State State;
		 State = Consumption;
		 int Hdrlength = PAYLOAD_OFFSET_UDP;
		 uint8_t remainlen;
		 Part_Word tempin, tempout;
		 Part_Word remainword;
		 Part_Word EndWord = {0,0};
		 do
		 {
	#pragma HLS pipeline II=1
	#pragma HLS loop_tripcount min=8 max=190

			 tempin = Data_in.read();
			 pktcomplete = tempin.End;
			 if (State == Consumption)
			 {
				 if (Hdrlength < 8)
				 {
					 remainlen = BYTES_PER_WORD - Hdrlength;
					 remainword.Data = 0;
					 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
					 State = Alignment;
				 }
				 else Hdrlength -=8;
			 }
			 else
			 {
				 if (tempin.len > Hdrlength)

					 {
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = false;
					 }
				 else if (tempin.len == Hdrlength)
					 {
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = true;
					 }
				 else
					 {
						 tempout.len = BYTES_PER_WORD -Hdrlength + tempin.len;
						 tempout.End = true;
					 }
				 tempout.Data = remainword.Data;
				 tempout.Data(63 - 8 * remainlen, 0) = tempin.Data.range(63, 64 - 8 * Hdrlength);
				 remainword.len = tempin.len - Hdrlength;
				 remainword.End = true;
				 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
				 Data_out.write(tempout);
			 }
		 }while(!pktcomplete);
		 if (tempin.len > Hdrlength)
			 Data_out.write(remainword);
	 }
}
void Parse_Memcached_Hdr(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
						 hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out, hls::stream<metadata> &Metadata)
{
	MemcachedPkt mempkt = Mempkt.read();
	Mempkt_out.write(mempkt);
	if (mempkt)
	{	bool pktcomplete;
		enum Parser_State State;
		Part_Word tempin;
		metadata Metadataout = {0,0,0};
		State = Consumption;
		do
		{
	#pragma HLS pipeline II=1
			tempin = Data_in.read();
			pktcomplete = tempin.End;
			if (State == Consumption)
			{
				Metadataout.MemHdr = tempin.Data;
				Metadataout.MemHdr.range(15, 0) = 0;
				Metadata.write(Metadataout);
				State = Alignment;
			}
			else
			{
				Data_out.write(tempin);
			}
		}while(!pktcomplete);
	}
}
void Parse_CMD(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
			   hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out, hls::stream<metadata> &Metain, hls::stream<metadata> &Metaout)
{
	 MemcachedPkt mempkt = Mempkt.read();
	 Mempkt_out.write(mempkt);
	 if (mempkt)
	 {	 bool pktcomplete;
		 pktcomplete = false;
		 enum Parser_State State;
		 State = Consumption;
		 int removelength;
		 uint8_t remainlen;
		 Part_Word tempin, tempout;
		 metadata Metadata;
		 Part_Word remainword;
		 Part_Word EndWord = {0,0};
		 Metadata = Metain.read();
		 do
		 {
	#pragma HLS pipeline II=1
	#pragma HLS loop_tripcount min=8 max=190

			 tempin = Data_in.read();
			 pktcomplete = tempin.End;
			 if (State == Consumption)
			 {
				 switch (tempin.Data.range(63,32))
				 {
					 case (0x73657420):
					{
						 Metadata.cmd = 1;
						 removelength = 4;
						 break;
					}
					 case (0x67657420):
					{
						 Metadata.cmd = 0;
						 removelength = 4;
						 break;
					}
					 case (0x64656c65):
					{
						 Metadata.cmd = 2;
						 removelength = 7;
						 break;
					}


				 }
				 std::cout << removelength << std::endl;
				 State = Alignment;
				 Metaout.write(Metadata);
				 remainlen = BYTES_PER_WORD - removelength;
				 remainword.Data = 0;
				 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
			 }
			 else
			 {
				 if (tempin.len > removelength)

					 {
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = false;
					 }
				 else if (tempin.len == removelength)
					 {
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = true;
					 }
				 else
					 {
						 tempout.len = BYTES_PER_WORD -removelength + tempin.len;
						 tempout.End = true;
					 }
				 tempout.Data = remainword.Data;
				 tempout.Data(63 - 8 * remainlen, 0) = tempin.Data.range(63, 64 - 8 * removelength);
				 remainword.len = tempin.len - removelength;
				 remainword.End = true;
				 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
				 Data_out.write(tempout);
			 }
		 }while(!pktcomplete);
		 if (tempin.len > removelength)
			 Data_out.write(remainword);
	 }
}
void Parse_Key(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
			   hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out,
		       hls::stream<metadata> &Metain, hls::stream<metadata> &Metaout,
			   hls::stream<metadata> &Metaout2, hls::stream<Part_Word> &Key_out)
{
	 MemcachedPkt mempkt = Mempkt.read();
	 Mempkt_out.write(mempkt);
	 if (mempkt)
	 {
		 bool pktcomplete;
		 pktcomplete = false;
		 enum Parser_State State;
		 uint16_t index = 0;
		 State = Consumption;
		 int removelength;
		 uint8_t remainlen;
		 uint8_t delimiter = 8;
		 Part_Word tempin, tempout, key;
		 metadata Metadata;
		 Part_Word remainword;
		 Part_Word EndWord = {0,0};
		 Metadata = Metain.read();
		 do
		 {
	#pragma HLS pipeline II=1
	#pragma HLS loop_tripcount min=8 max=190

			 tempin = Data_in.read();
			 pktcomplete = tempin.End;
			 if(State == Consumption)
			 {
				 delimiter = Find_delimiter(tempin.Data);
				 if (delimiter == 8)
				 {
					 key.Data = tempin.Data;
					 key.len = tempin.len;
					 key.End = 0;
					 Key_out.write(key);
					 index ^= hash(key.Data);
				 }
				 else if (delimiter == 7)
				 {
					 key.len = delimiter;
					 key.Data = 0;
					 key.Data.range(63,64 - key.len * 8) = tempin.Data.range(63, 64 - key.len *8);
					 key.End = true;
					 Key_out.write(key);
					 index ^= hash(key.Data);
					 State = Not_Alignment;
					 Metadata.index = index;
					 Metaout.write(Metadata);
					 Metaout2.write(Metadata);

				 }
				 else
				 {
					 if (delimiter!= 0)
					 {
						 key.len = delimiter;
						 key.Data = 0;
						 key.Data.range(63,64 - key.len * 8) = tempin.Data.range(63, 64 - key.len *8);
						 key.End = true;
						 Key_out.write(key);
						 index ^= hash(key.Data);
					 }
					 else
					 {
						 key.len = 0;
						 key.Data = 0;
						 key.End = true;
						 Key_out.write(key);
					 }
					 State = Alignment;
					 removelength = delimiter + 1;
					 remainlen = BYTES_PER_WORD - removelength;
					 remainword.Data = 0;
					 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
					 Metadata.index = index;
					 Metaout.write(Metadata);
					 Metaout2.write(Metadata);
				 }
			 }
			 else if (State == Not_Alignment)
			 {
				 Data_out.write(tempin);
			 }
			 else
			 {
				 if (tempin.len > removelength)

					 {
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = false;
					 }
				 else if (tempin.len == removelength)
					 {
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = true;
					 }
				 else
					 {
						 tempout.len = BYTES_PER_WORD -removelength + tempin.len;
						 tempout.End = true;
					 }
				 tempout.Data = remainword.Data;
				 tempout.Data(63 - 8 * remainlen, 0) = tempin.Data.range(63, 64 - 8 * removelength);
				 remainword.len = tempin.len - removelength;
				 remainword.End = true;
				 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
				 Data_out.write(tempout);
			 }
		 }while(!pktcomplete);
		 if (State == Alignment && tempin.len > removelength)
			 Data_out.write(remainword);
	 }
}

void Process_Key(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
				 hls::stream<Part_Word> &Key_in, hls::stream<Part_Word> &Key_out,
				 //hls::stream<input_tuples> &tuple_in,
				 //hls::stream<input_tuples> & tuple_out,
				 hls::stream<metadata> &Metain, hls::stream<instr> &instrout1)//, hls::stream<instr> &instrout2)
{
	 MemcachedPkt mempkt = Mempkt.read();
	 Mempkt_out.write(mempkt);
	if (mempkt)
	{
		bool keycomplete;
		bool collision = false;
		uint8_t keylen = 0;
		uint16_t index;
		Part_Word key;
		int count = 0;
		bool State; //0 for saving; 1 for compare
		metadata Metadata;
		instr Instruction;
		Metadata = Metain.read();
		Instruction.MemHdr = Metadata.MemHdr;
		index = Metadata.index;
		Instruction.index = index;
		std::cout << "Index is " << index << std::endl;
		if (index == 6) std::cout << "!!!!!" << std::endl;
		if (Metadata.cmd == 1)
			{
				State = 0;
				Instruction.response = 0; //Stored
				instrout1.write(Instruction);
				//instrout2.write(Instruction);

			}
		else if (Metadata.cmd == 0)
			{
				State = 1;
				Instruction.response = 1;
			}
		do
		{
	#pragma HLS pipeline II=1
	#pragma HLS loop_tripcount min=2 max=32
			key = Key_in.read();
			keycomplete = key.End;
			if (State == 0)
			{
				keylen += key.len;
				Memory[index].KEY[count] = 0;
				Memory[index].KEY[count] = key.Data;
				count++;
				Memory[index].KEY_LEN = keylen;
			}
			else
			{
				if (Memory[index].KEY[count] != key.Data)
					{
						collision = true;
						std::cout << "Collision" << std::endl;
					}
				count ++;
				Key_out.write(key);
			}
		}while(!keycomplete);
		if (collision) Instruction.response = 2;
		if (State != 0) {
			instrout1.write(Instruction);
			//instrout2.write(Instruction);
		}
		//input_tuples tuple = tuple_in.read();
		//tuple_out.write(tuple);
	}
}
void Remove(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
			hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out,
		    hls::stream<metadata> &metain, hls::stream<metadata> &metaout)
{
	MemcachedPkt mempkt = Mempkt.read();
	Mempkt_out.write(mempkt);
	if (mempkt)
	{
		metadata Metadata;
		bool pktcomplete = false;
		Part_Word tempin, tempout;
		Metadata = metain.read();
		enum Parser_State State = Consumption;
		metaout.write(Metadata);
		int removelength;
		uint8_t remainlen;
		Part_Word remainword;
		Part_Word EndWord = {0,0};
		if (Metadata.cmd == 1)
		{
			do
			{
	#pragma HLS pipeline II =1
	#pragma HLS loop_tripcount min=8 max=130
				tempin = Data_in.read();
				pktcomplete = tempin.End;
				if (State == Consumption)
				{
					 State = Alignment;
					 removelength = 4;
					 remainlen = BYTES_PER_WORD - removelength;
					 remainword.Data = 0;
					 remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
				}
				else
				{
					if (tempin.len > removelength)
					{
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = false;
					}
					else if (tempin.len == removelength)
					{
						 tempout.len = BYTES_PER_WORD;
						 tempout.End = true;
					}
					else
					{
						 tempout.len = BYTES_PER_WORD -removelength + tempin.len;
						 tempout.End = true;
					}
					tempout.Data = remainword.Data;
					tempout.Data(63 - 8 * remainlen, 0) = tempin.Data.range(63, 64 - 8 * removelength);
					remainword.len = tempin.len - removelength;
					remainword.End = true;
					remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
					Data_out.write(tempout);
				}
			}while(!pktcomplete);
			if (State == Alignment && tempin.len > removelength)
				Data_out.write(remainword);
		}
		else
		{
			Data_in.read();
		}
	}
}
void Parse_Datalen(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
				   hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out,
				   hls::stream<Part_Word> & Lengthout1,hls::stream<Part_Word> & Lengthout2,
				   hls::stream<metadata> &metain, hls::stream<metadata> &metaout)
{
	MemcachedPkt mempkt = Mempkt.read();
	Mempkt_out.write(mempkt);
	if (mempkt)
	{	metadata Metadata;
		bool pktcomplete = false;
		Part_Word tempin, tempout;
		Part_Word Datalen;
		Metadata = metain.read();
		enum Parser_State State = Consumption;
		int removelength;
		uint8_t remainlen;
		Part_Word remainword;
		Part_Word EndWord = {0,0};
		uint16_t index = Metadata.index;
		uint8_t num;
		bool finish = false;
		metaout.write(Metadata);
		if (Metadata.cmd == 1)
		{
			tempin = Data_in.read();
			num = Find_delimiter(tempin.Data);
			Datalen.Data.range(63, 64 - num * 8) = tempin.Data.range(63, 64 - num * 8);
			Datalen.len = num;
			Lengthout1.write(Datalen);
			Datalen.len += 3;
			Datalen.Data >>= 3*8;
			Datalen.Data.range(63, 40) = 0x203020;
			Memory[index].DATA_LEN_WORD = Datalen;
			removelength = num + 2;
			remainlen = BYTES_PER_WORD - removelength;
			remainword.Data = 0;
			remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
			do
			{
	#pragma HLS pipeline II =1
	#pragma HLS loop_tripcount min=8 max=130
				tempin = Data_in.read();
				pktcomplete = tempin.End;
				if (tempin.len > removelength)
				{
					 tempout.len = BYTES_PER_WORD;
					 tempout.End = false;
				}
				else if (tempin.len == removelength)
				{
					 tempout.len = BYTES_PER_WORD;
					 tempout.End = true;
				}
				else
				{
					 tempout.len = BYTES_PER_WORD -removelength + tempin.len;
					 tempout.End = true;
				}
				tempout.Data = remainword.Data;
				tempout.Data(63 - 8 * remainlen, 0) = tempin.Data.range(63, 64 - 8 * removelength);
				remainword.len = tempin.len - removelength;
				remainword.End = true;
				remainword.Data(63, 64 - 8 * remainlen) = tempin.Data.range(8*remainlen - 1, 0);
				Data_out.write(tempout);

			}while(!pktcomplete);
			if (tempin.len > removelength)
				Data_out.write(remainword);
		}
		else if(Metadata.cmd == 0)
		{
			Datalen = Memory[index].DATA_LEN_WORD;
			Lengthout2.write(Datalen);
		}
	}
}
void ConvertDatalen(hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
					hls::stream<Part_Word> & Datalen,
					hls::stream<metadata> &metain, hls::stream<metadata> &metaout)
{
	MemcachedPkt mempkt = Mempkt.read();
	Mempkt_out.write(mempkt);
	if (mempkt)
	{	metadata Metadata = metain.read();
		uint16_t index = Metadata.index;
		if (Metadata.cmd == 1)
		{
			Part_Word temp = Datalen.read();
			uint16_t datalen = 0;
			for (int i = 0; i < temp.len; i++)
			{
	#pragma HLS pipeline II =1
	#pragma HLS loop_tripcount max=8
				datalen = datalen* 10 + temp.Data.range(63 - i * 8, 56 - i * 8) - 48;
			}
			datalen += 7;
			std::cout << datalen << std::endl;
			Memory[index].DATA_LEN = datalen;
			Metadata.Datalen = datalen;
			metaout.write(Metadata);
		}
		else
		{
			Metadata.Datalen = Memory[index].DATA_LEN;
			metaout.write(Metadata);
		}
	}

}
void Parse_Data( hls::stream<MemcachedPkt> &Mempkt, hls::stream<MemcachedPkt> &Mempkt_out,
				 hls::stream<Part_Word> &Data_in,
				 hls::stream<metadata> & metain, hls::stream<instr> &Instr_in,
				 hls::stream<instr> &Instr_out,
				 hls::stream<Part_Word> &Data_out)
{
	MemcachedPkt mempkt = Mempkt.read();
	Mempkt_out.write(mempkt);
	if (mempkt)
	{
		instr Instruction = Instr_in.read();
		metadata Metadata = metain.read();
		uint8_t count = 0;
		uint16_t index = Instruction.index;
		static Part_Word EndofPacket = {0x454e440d0a000000, 5, 0};
		if (Instruction.response == 0)
		{
			Part_Word tempin;
			bool pktcomplete = false;
			do
			{
	#pragma HLS pipeline II =1
	#pragma HLS loop_tripcount min=2 max=128

				tempin = Data_in.read();
				pktcomplete = tempin.End;
				Memory[index].DATA[count] = tempin.Data;
				count++;
			}while(!pktcomplete);

			if (tempin.len <= (8 - EndofPacket.len))
			{
				Memory[index].DATA[count - 1].range(63-tempin.len * 8, 24 - tempin.len*8) = EndofPacket.Data.range(63, 24);
			}
			else if (tempin.len == 8)
			{
				Memory[index].DATA[count] = EndofPacket.Data;
			}
			else
			{

				Memory[index].DATA[count - 1].range(63 - 8*tempin.len, 0) = EndofPacket.Data.range(63, 8*tempin.len);
				Memory[index].DATA[count] =EndofPacket.Data << (64 - 8 * tempin.len);
			}
			Memory[index].VALID = 1;
			//Print_Memory(index);

		}
		else if(Instruction.response == 1)
		{
			Part_Word dataoutput;
			int totnum = Metadata.Datalen / 8;
			int remainnum = Metadata.Datalen % 8;
			if (remainnum == 0)
				{
					totnum -=1;
					remainnum = 8;
				}
			for (int i = 0; i < totnum; i++)
			{
	#pragma HLS pipeline II =1
				dataoutput.Data = Memory[index].DATA[i];
				dataoutput.End = 0;
				dataoutput.len = 8;
				Data_out.write(dataoutput);
			}
			dataoutput.Data = Memory[index].DATA[totnum];
			dataoutput.End = 1;
			dataoutput.len = remainnum;
			Data_out.write(dataoutput);
		}
		else if (Instruction.response == 2)
		{
			Part_Word dataoutput;
			dataoutput.Data = 0;
			dataoutput.End = 1;
			dataoutput.len = 8;
			Data_out.write(dataoutput);
		}
		Instr_out.write(Instruction);
		//input_tuples tuple = tuple_in.read();
		//tuple_out.write(tuple);
	}
}
void Generate_output(hls::stream<MemcachedPkt> &Mempkt,
		 	 	 	//hls::stream<input_tuples> &tuple_in,
		 	 	 	//hls::stream<input_tuples> & tuple_out,
					hls::stream<packet_interface> &Packet_out,
					hls::stream<instr> &Instruction,
					hls::stream<instr> &Instr_out,
				   hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Key_in,
				   hls::stream<Part_Word> &Datalen_in)
{
	MemcachedPkt mempkt = Mempkt.read();
	if (mempkt)
	{
		Part_Word Input;
		packet_interface output;
		Part_Word remainword;
		uint16_t totlen = 15;
		instr Instr = Instruction.read();
			output.Start_of_frame = 1;
			output.End_of_frame = 0;
			output.Data = 0;
			output.Count = 8;
			output.Error = 0;
			Packet_out.write(output);
			output.Start_of_frame = 0;
			for (int i = 1; i < 5; i++)
			{
		#pragma HLS pipeline II = 1
				Packet_out.write(output);
			}
			output.Data.range(47,0) = Instr.MemHdr.range(63, 16);
			Packet_out.write(output);
			output.Data.range(63, 48) = Instr.MemHdr.range(15, 0);
			if (Instr.response == 0)
			{
				output.Data.range(47, 0) = 0x53544F524544;
				Packet_out.write(output);
				output.Count = 2;
				output.Data = 0;
				output.Data.range(63, 32) = 0x0d0a0000;
				output.End_of_frame =1;
				Packet_out.write(output);
			}
			else if (Instr.response == 1 || Instr.response == 2)
			{
				bool datacomplete;
				Part_Word tempin;
				Part_Word Datalen;
				if (Instr.response == 1) output.Data.range(47,0) = 0x56414c554520;
				else output.Data.range(47,0) = 0x434f4c4c4920;
				output.Count = 8;
				Packet_out.write(output);
				tempin = Key_in.read();
				do
				{
		#pragma HLS pipeline II=1
					output.Data= tempin.Data;
					output.Count = tempin.len;
					output.Start_of_frame = 0;
					output.End_of_frame = 0;
					output.Error = 0;
					Packet_out.write(output);
					tempin = Key_in.read();
					datacomplete = tempin.End;
				}while(!datacomplete);
				remainword.len = 0;
				remainword.Data = 0;
				Datalen = Datalen_in.read();
				if (tempin.len !=0)
				{
					if (tempin.len ==8)
					{
						output.Data = tempin.Data;
						Packet_out.write(output);
						remainword = Datalen;
					}
					else if (tempin.len + Datalen.len <= 8)
					{
						remainword.len = tempin.len + Datalen.len;
						remainword.Data.range(63, 64 - tempin.len * 8) = tempin.Data.range(63, 64 - tempin.len * 8);
						remainword.Data.range(63 - tempin.len * 8, 64 - remainword.len * 8) = Datalen.Data.range(63, 64 - Datalen.len * 8);
						if (remainword.len == 8)
						{
							output.Data = remainword.Data;
							output.Count = remainword.len;
							output.End_of_frame = 0;
							remainword.len = 0;
							remainword.Data = 0;
							Packet_out.write(output);
						}
					}
					else
					{
						remainword.len = tempin.len + Datalen.len - 8;
						remainword.Data.range(63, 64 -remainword.len * 8) = Datalen.Data(63 - Datalen.len*8 + remainword.len *8, 64 - Datalen.len*8);
						output.Data = tempin.Data;
						output.Data.range(63 - 8*tempin.len,0) = Datalen.Data.range(63, 8 * tempin.len);
						output.Count = 8;
						output.End_of_frame = 0;
						Packet_out.write(output);
					}
				}
				else
				{
					remainword = Datalen;
				}
				if(remainword.len ==7)
				{
					remainword.Data.range(7,0) = 0x0d;
					output.Data = remainword.Data;
					output.Count = 8;
					output.End_of_frame = 0;
					Packet_out.write(output);
					remainword.len = 1;
					remainword.Data.range(63,56) = 0x0a;
				}
				else if (remainword.len == 6)
				{
					remainword.Data.range(15,0) = 0x0d0a;
					output.Data = remainword.Data;
					output.Count = 8;
					output.End_of_frame = 0;
					Packet_out.write(output);
					remainword.len = 0;
					remainword.Data = 0;
				}
				else
				{
					remainword.len +=2;
					remainword.Data.range(79 - 8 * remainword.len ,64 - 8 * remainword.len) = 0x0d0a;
				}
				tempin = Data_in.read();
				datacomplete = tempin.End;
				while(!datacomplete)
				{
		#pragma HLS pipeline II=1
					if (remainword.len == 0)
					{
							output.Data= tempin.Data;
					}
					else
					{
						output.Data = remainword.Data;
						output.Data.range(63 - 8 * remainword.len,0) = tempin.Data.range(63, remainword.len * 8);
						remainword.Data.range(63, 64 - 8*remainword.len) = tempin.Data.range(8 *remainword.len - 1, 0);
					}
					output.Count = 8;
					output.End_of_frame = datacomplete;
					output.Start_of_frame = 0;
					output.Error = 0;
					Packet_out.write(output);
					tempin = Data_in.read();
					datacomplete = tempin.End;
				}
				if (tempin.len + remainword.len <=8)
				{
					output.Data = remainword.Data;
					output.Count = tempin.len + remainword.len;
					output.End_of_frame = true;
					output.Data.range(63 - 8*remainword.len, 64 - (tempin.len + remainword.len) * 8) = tempin.Data.range(63, 64 - tempin.len *8);
					Packet_out.write(output);
				}
				else
				{
					output.Data = remainword.Data;
					output.Data.range(63 - 8 * remainword.len,0) = tempin.Data.range(63, remainword.len * 8);
					output.Count = 8;
					output.End_of_frame = 0;
					Packet_out.write(output);
					output.Count = tempin.len + remainword.len - 8;
					output.Data = tempin.Data << (8 - remainword.len)*8;
					output.End_of_frame = 1;
					Packet_out.write(output);
				}
			}
		Instr_out.write(Instr);
	}

}

void Output_packets(//input_tuples Input_tuple,
					hls::stream<input_tuples> & Input_tuples,
					hls::stream<output_tuples> & Output_tuples,
					hls::stream<packet_interface> &Packet_in1,
					hls::stream<packet_interface> &Packet_in2,
					hls::stream<packet_interface> &Packet_out,
					hls::stream<instr> &Instr_in)
{
	packet_interface input, temp;
	input_tuples tuple_in;
	output_tuples tuple_out,tuple_forward;
	uint16_t len;
	len = 0;
	tuple_in = Input_tuples.read();
	tuple_out.Hdr = tuple_in.Hdr;
	tuple_out.Checkcache = tuple_in.Checkcache;
	tuple_out.Control = tuple_in.Control;
	tuple_out.Ioports = tuple_in.Ioports;
	tuple_out.Local_state = tuple_in.Local_state;
	tuple_out.Memcached_output = tuple_in.Memcached_input;
	tuple_out.Parser_extracts = tuple_in.Parser_extracts;
	tuple_forward = tuple_out;
	bool End = false;
	//if (tuple_in.Hdr.Eth.Type == 0x0800 && tuple_in.Hdr.Ipv4.protocol == 0x11 && tuple_in.Hdr.Udp.dport ==0x2bcb)
	if (tuple_in.Memcached_input.Stateful_valid == 1)
	{
		instr Instruction = Instr_in.read();
		if (Instruction.response == 1)
		{
			bool Forward_Pkt_End = false;
			do
			{
		#pragma HLS pipeline II=1
				input = Packet_in1.read();
				End = input.End_of_frame;
				len += input.Count;
				Packet_out.write(input);
				if (!Forward_Pkt_End)
					{
						temp = Packet_in2.read();
						Forward_Pkt_End = temp.End_of_frame;
					}
			}while(!End);
			tuple_out.Checkcache.forward = 0;
			tuple_out.Hdr.Ipv4.totallen = len - ETH_HDR_LEN;
			tuple_out.Hdr.Udp.len = len - ETH_HDR_LEN - IPV4_HDR_LEN;
			tuple_out.Hdr.Eth.Dst = tuple_in.Hdr.Eth.Src;
			tuple_out.Hdr.Eth.Src = tuple_in.Hdr.Eth.Dst;
			tuple_out.Hdr.Ipv4.srcAddr = tuple_in.Hdr.Ipv4.dstAddr;
			tuple_out.Hdr.Ipv4.dstAddr = tuple_in.Hdr.Ipv4.srcAddr;
			tuple_out.Hdr.Udp.dport = tuple_in.Hdr.Udp.sport;
			tuple_out.Hdr.Udp.sport = tuple_in.Hdr.Udp.dport;
			Output_tuples.write(tuple_out);
		}
		else if (Instruction.response == 2)
		{

			bool Forward_Pkt_End = false;
			do
			{
		#pragma HLS pipeline II=1
				input = Packet_in1.read();
				End = input.End_of_frame;
				if (!Forward_Pkt_End)
				{
					temp = Packet_in2.read();
					Forward_Pkt_End = temp.End_of_frame;
					Packet_out.write(temp);
				}
			}while(!End);
			Output_tuples.write(tuple_forward);
		}
		else if (Instruction.response == 0)
		{
			do
			{
		#pragma HLS pipeline II=1
				input = Packet_in1.read();
				End = input.End_of_frame;
				len += input.Count;
				if (End && len < 60) input.Count += 60 - len;
				Packet_out.write(input);
			}while(!End);
			tuple_out.Hdr.Ipv4.totallen = len - ETH_HDR_LEN;
			tuple_out.Hdr.Udp.len = len - ETH_HDR_LEN - IPV4_HDR_LEN;
			tuple_out.Hdr.Eth.Dst = tuple_in.Hdr.Eth.Src;
			tuple_out.Hdr.Eth.Src = tuple_in.Hdr.Eth.Dst;
			tuple_out.Hdr.Ipv4.srcAddr = tuple_in.Hdr.Ipv4.dstAddr;
			tuple_out.Hdr.Ipv4.dstAddr = tuple_in.Hdr.Ipv4.srcAddr;
			tuple_out.Hdr.Udp.dport = tuple_in.Hdr.Udp.sport;
			tuple_out.Hdr.Udp.sport = tuple_in.Hdr.Udp.dport;
			tuple_out.Checkcache.forward = 1;
			Output_tuples.write(tuple_out);
			do
			{
		#pragma HLS pipeline II=1
				input = Packet_in2.read();
				End = input.End_of_frame;
				Packet_out.write(input);
			}while(!End);
			Output_tuples.write(tuple_forward);
		}
	}
	else
	{
		do
		{
	#pragma HLS pipeline II=1
			input = Packet_in2.read();
			End = input.End_of_frame;
			Packet_out.write(input);
		}while(!End);
		Output_tuples.write(tuple_out);
	}


}



void Memcore(hls::stream<input_tuples> & Input_tuples, hls::stream<output_tuples> & Output_tuples,
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
	int DATA_FIFO_SIZE = 150;
	int INST_FIFO_SIZE = 100;
	static hls::stream<Part_Word> Extracted_Data;
#pragma HLS STREAM variable=Extracted_Data depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_after_EthHdr;
#pragma HLS STREAM variable=Data_after_EthHdr depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_after_MemHdr;
#pragma HLS STREAM variable=Data_after_MemHdr depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_after_cmd;
#pragma HLS STREAM variable=Data_after_cmd depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_after_Key;
#pragma HLS STREAM variable=Data_after_Key depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_after_Remove;
#pragma HLS STREAM variable=Data_after_Remove depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_after_len;
#pragma HLS STREAM variable=Data_after_len depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Data_Stream;
#pragma HLS STREAM variable=Data_Stream depth=DATA_FIFO_SIZE

	static hls::stream<Part_Word> Datalen2Convert;
#pragma HLS STREAM variable=Datalen2Convert depth=INST_FIFO_SIZE
	static hls::stream<Part_Word> Datalen2Output;
#pragma HLS STREAM variable=Datalen2Output depth=INST_FIFO_SIZE

	static hls::stream<Part_Word> Key_Stream;
#pragma HLS STREAM variable=Key_Stream depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Key2Output;
#pragma HLS STREAM variable=Key2Output depth=DATA_FIFO_SIZE

	static hls::stream<metadata> Metadata;
#pragma HLS STREAM variable=Metadata depth=INST_FIFO_SIZE
	static hls::stream<metadata> Metadata_with_CMD;
#pragma HLS STREAM variable=Metadata_with_CMD depth=INST_FIFO_SIZE
	static hls::stream<metadata> Metadata2ProcessKey;
#pragma HLS STREAM variable=Metadata2ProcessKey depth=INST_FIFO_SIZE
	static hls::stream<metadata> Metadata2Remove;
#pragma HLS STREAM variable=Metadata2Remove depth=INST_FIFO_SIZE
	static hls::stream<metadata> Metadata2ParseDatalen;
#pragma HLS STREAM variable=Metadata2ParseDatalen depth=INST_FIFO_SIZE
	static hls::stream<metadata> Metadata2ConvertDatalen;
#pragma HLS STREAM variable=Metadata2ConvertDatalen depth=INST_FIFO_SIZE
	static hls::stream<metadata> Metadata2ParseData;
#pragma HLS STREAM variable=Metadata2ParseData depth=INST_FIFO_SIZE

	static hls::stream<instr> Instr2ParseData;
#pragma HLS STREAM variable=Instr2ParseData depth=INST_FIFO_SIZE
	static hls::stream<instr> Instr2Output;
#pragma HLS STREAM variable=Instr2Output depth=INST_FIFO_SIZE
	static hls::stream<instr> Instr2GenOutput;
#pragma HLS STREAM variable=Instr2GenOutput depth=INST_FIFO_SIZE


	static hls::stream<packet_interface> Packet2OutputPacket;
#pragma HLS STREAM variable=Packet2OutputPacket depth=DATA_FIFO_SIZE

	static hls::stream<input_tuples> Tuple2output;
#pragma HLS STREAM variable=Tuple2output depth=100
#pragma HLS DATA_PACK variable=Tuple2output
	static hls::stream<input_tuples> Tuple2ETH;
#pragma HLS STREAM variable=Tuple2ETH depth=100
	static hls::stream<input_tuples> Tuple2PData;
#pragma HLS STREAM variable=Tuple2PData depth=100
	static hls::stream<input_tuples> Tuple2Goutput;
#pragma HLS STREAM variable=Tuple2Goutput depth=100
	static hls::stream<input_tuples> Tuple2ExtractData;
#pragma HLS STREAM variable=Tuple2ExtractData depth=100
	static hls::stream<input_tuples> Tuple2Forward;
#pragma HLS STREAM variable=Tuple2Forward depth=100

	static hls::stream<packet_interface> Pkt2ExtractData;
#pragma HLS STREAM variable=Pkt2ExtractData depth=DATA_FIFO_SIZE
	static hls::stream<packet_interface> Pkt2Forward;
#pragma HLS STREAM variable=Pkt2Forward depth=1000

	static hls::stream<MemcachedPkt> Mempkt2ExtractData;
#pragma HLS STREAM variable=Mempkt2ExtractData depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2ParseETH;
#pragma HLS STREAM variable=Mempkt2ParseETH depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2ParseMemHdr;
#pragma HLS STREAM variable=Mempkt2ParseMemHdr depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2ParseCMD;
#pragma HLS STREAM variable=Mempkt2ParseCMD depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2ParseKey;
#pragma HLS STREAM variable=Mempkt2ParseKey depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2Process;
#pragma HLS STREAM variable=Mempkt2Process depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2Remove;
#pragma HLS STREAM variable=Mempkt2Remove depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2ParseDatalen;
#pragma HLS STREAM variable=Mempkt2ParseDatalen depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2Conv;
#pragma HLS STREAM variable=Mempkt2Conv depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2ParseData;
#pragma HLS STREAM variable=Mempkt2ParseData depth=INST_FIFO_SIZE
	static hls::stream<MemcachedPkt> Mempkt2GenerateOutput;
#pragma HLS STREAM variable=Mempkt2GenerateOutput depth=INST_FIFO_SIZE

#pragma HLS DATA_PACK variable=Tuple2ETH
#pragma HLS DATA_PACK variable=Tuple2PData
#pragma HLS DATA_PACK variable=Tuple2Goutput
#pragma HLS DATA_PACK variable=Tuple2output

std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
std::cout << "The No. "<< Packet_num << "Packet"  << std::endl;
Packet_num ++;

#pragma HLS dependence variable=Memory inter
	 Pktclassifier(Input_tuples, Tuple2output,
	 		 	   Packet_input, Pkt2ExtractData, Pkt2Forward, Mempkt2ExtractData);
	 Extract_Data(Mempkt2ExtractData, Mempkt2ParseETH, Pkt2ExtractData, Extracted_Data);
	 Parse_Eth_Hdr(Mempkt2ParseETH, Mempkt2ParseMemHdr, Extracted_Data, Data_after_EthHdr);
	 Parse_Memcached_Hdr(Mempkt2ParseMemHdr, Mempkt2ParseCMD, Data_after_EthHdr, Data_after_MemHdr, Metadata);
	 Parse_CMD(Mempkt2ParseCMD, Mempkt2ParseKey, Data_after_MemHdr, Data_after_cmd, Metadata, Metadata_with_CMD);
	 Parse_Key(Mempkt2ParseKey, Mempkt2Process, Data_after_cmd, Data_after_Key, Metadata_with_CMD, Metadata2ProcessKey, Metadata2Remove, Key_Stream);
	 Process_Key(Mempkt2Process, Mempkt2Remove, Key_Stream, Key2Output, Metadata2ProcessKey, Instr2ParseData);
	 Remove(Mempkt2Remove, Mempkt2ParseDatalen, Data_after_Key, Data_after_Remove, Metadata2Remove, Metadata2ParseDatalen);
	 Parse_Datalen(Mempkt2ParseDatalen,Mempkt2Conv, Data_after_Remove, Data_after_len, Datalen2Convert, Datalen2Output, Metadata2ParseDatalen, Metadata2ConvertDatalen);
	 ConvertDatalen(Mempkt2Conv, Mempkt2ParseData, Datalen2Convert, Metadata2ConvertDatalen, Metadata2ParseData);
	 Parse_Data(Mempkt2ParseData,Mempkt2GenerateOutput, Data_after_len, Metadata2ParseData, Instr2ParseData, Instr2GenOutput, Data_Stream);
	 Generate_output(Mempkt2GenerateOutput, Packet2OutputPacket, Instr2GenOutput, Instr2Output, Data_Stream, Key2Output, Datalen2Output);
	 Output_packets(Tuple2output, Output_tuples, Packet2OutputPacket, Pkt2Forward, Packet_output, Instr2Output);
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;

}


