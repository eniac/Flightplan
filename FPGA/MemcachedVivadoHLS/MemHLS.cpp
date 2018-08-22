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

void Print_Data(hls::stream<Part_Word> & Data_in)
{
	Part_Word Input;
	do
	{
#pragma HLS pipeline II=1
		Input = Data_in.read();
		uint64_t Data = 0;
		std::cout << std::hex << Data << std::endl;
	}while (!Input.End);
}

void Extract_Data(hls::stream<packet_interface> &Packet_input, hls::stream<Part_Word> &Data_out)
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

}
void Parse_Eth_Hdr(hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out)
{
	 bool pktcomplete;
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
void Parse_Memcached_Hdr(hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out, hls::stream<metadata> &Metadata)
{
	bool pktcomplete;
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
void Parse_CMD(hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out, hls::stream<metadata> &Metain, hls::stream<metadata> &Metaout)
{
	 bool pktcomplete;
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
void Parse_Key(hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out,
		       hls::stream<metadata> &Metain, hls::stream<metadata> &Metaout,
			   hls::stream<metadata> &Metaout2, hls::stream<Part_Word> &Key_out)
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
				 key.Data.range(63,64 - key.len * 8) = tempin.Data.range(63, 64 - key.len *8);
				 key.End = true;
				 Key_out.write(key);
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
					 key.Data.range(63,64 - key.len * 8) = tempin.Data.range(63, 64 - key.len *8);
					 Key_out.write(key);
				 }
				 else
				 {
					 key.len = 0;
					 key.Data = 0;
					 key.End = true;
					 Key_out.write(key);
				 }
				 index ^= hash(key.Data);
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

void Process_Key(hls::stream<Part_Word> &Key_in, hls::stream<Part_Word> &Key_out,
				 hls::stream<metadata> &Metain, hls::stream<instr> &instrout1, hls::stream<instr> &instrout2)
{
	bool keycomplete;
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
	if (Metadata.cmd == 1)
		{
			State = 0;
			Instruction.response = 0; //Stored
			instrout1.write(Instruction);
			instrout2.write(Instruction);

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
			Memory[index].KEY[count] = key.Data;
			count++;
			Memory[index].KEY_LEN = keylen;
		}
		else
		{
			if (key.len != 0 && Memory[index].KEY[count] != key.Data) Instruction.response = 1; //Key not match
			count ++;
			Key_out.write(key);
		}
	}while(!keycomplete);
	if (State != 0) {
		instrout1.write(Instruction);
		instrout2.write(Instruction);
	}
}
void Remove(hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out,
		    hls::stream<metadata> &metain, hls::stream<metadata> &metaout)
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
void Parse_Datalen(hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Data_out,
				  hls::stream<Part_Word> & Lengthout1,hls::stream<Part_Word> & Lengthout2,
				  hls::stream<metadata> &metain, hls::stream<metadata> &metaout)
{
	metadata Metadata;
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
void ConvertDatalen(hls::stream<Part_Word> & Datalen, hls::stream<metadata> &metain, hls::stream<metadata> &metaout)
{
	metadata Metadata = metain.read();
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
void Parse_Data(hls::stream<Part_Word> &Data_in,
				hls::stream<metadata> & metain, hls::stream<instr> &Instr_in,
				hls::stream<Part_Word> &Data_out)
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
}
void Output_Packet(hls::stream<packet_interface> &Packet_out, hls::stream<instr> &Instruction,
				   hls::stream<Part_Word> &Data_in, hls::stream<Part_Word> &Key_in,
				   hls::stream<Part_Word> &Datalen_in)
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
		output.Data.range(63, 48) = 0x0d0a;
		output.End_of_frame =1;
		Packet_out.write(output);
	}
	else if (Instr.response == 1)
	{
		bool datacomplete;
		Part_Word tempin;
		Part_Word Datalen;
		output.Data.range(47,0) = 0x56414c554520;
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
				remainword.Data.range(63, 64 - tempin.len * 8) = tempin.Data.range(tempin.len * 8 -1, 0);
				remainword.Data.range(63 - tempin.len * 8, 64 - remainword.len * 8) = Datalen.Data.range(63, 64 - Datalen.len * 8);
				if (remainword.len == 8)
				{
					output.Data = remainword.Data;
					output.Count = remainword.len;
					output.End_of_frame = 0;
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
		datacomplete = false;
		do
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
		}while(!datacomplete);
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
	uint16_t DATA_FIFO_SIZE = (MAX_PACKET_SIZE/BYTES_PER_WORD);
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
#pragma HLS STREAM variable=Datalen2Convert depth=5
	static hls::stream<Part_Word> Datalen2Output;
#pragma HLS STREAM variable=Datalen2Output depth=5

	static hls::stream<Part_Word> Key_Stream;
#pragma HLS STREAM variable=Key_Stream depth=DATA_FIFO_SIZE
	static hls::stream<Part_Word> Key2Output;
#pragma HLS STREAM variable=Key2Output depth=DATA_FIFO_SIZE

	static hls::stream<metadata> Metadata;
#pragma HLS STREAM variable=Metadata depth=5
	static hls::stream<metadata> Metadata_with_CMD;
#pragma HLS STREAM variable=Metadata_with_CMD depth=5
	static hls::stream<metadata> Metadata2ProcessKey;
#pragma HLS STREAM variable=Metadata2ProcessKey depth=5
	static hls::stream<metadata> Metadata2Remove;
#pragma HLS STREAM variable=Metadata2Remove depth=5
	static hls::stream<metadata> Metadata2ParseDatalen;
#pragma HLS STREAM variable=Metadata2ParseDatalen depth=5
	static hls::stream<metadata> Metadata2ConvertDatalen;
#pragma HLS STREAM variable=Metadata2ConvertDatalen depth=5
	static hls::stream<metadata> Metadata2ParseData;
#pragma HLS STREAM variable=Metadata2ParseData depth=5

	static hls::stream<instr> Instr2ParseData;
#pragma HLS STREAM variable=Instr2ParseData depth=5
	static hls::stream<instr> Instr2Output;
#pragma HLS STREAM variable=Instr2Output depth=5

std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
std::cout << "The No. "<< Packet_num << "Packet"  << std::endl;
Packet_num ++;

#pragma HLS dependence variable=Memory inter
	 input_tuples tuple_in = Input_tuples.read();
	 output_tuples tuple_out;
	 tuple_out.Hdr = tuple_in.Hdr;
	 Output_tuples.write(tuple_out);
	 Extract_Data(Packet_input, Extracted_Data);
	 Parse_Eth_Hdr(Extracted_Data, Data_after_EthHdr);
	 Parse_Memcached_Hdr(Data_after_EthHdr, Data_after_MemHdr, Metadata);
	 Parse_CMD(Data_after_MemHdr, Data_after_cmd, Metadata, Metadata_with_CMD);

	 Parse_Key(Data_after_cmd, Data_after_Key, Metadata_with_CMD, Metadata2ProcessKey, Metadata2Remove, Key_Stream);
	 Process_Key(Key_Stream, Key2Output, Metadata2ProcessKey, Instr2Output, Instr2ParseData);
	 Remove(Data_after_Key, Data_after_Remove, Metadata2Remove, Metadata2ParseDatalen);
	 Parse_Datalen(Data_after_Remove, Data_after_len, Datalen2Convert, Datalen2Output, Metadata2ParseDatalen, Metadata2ConvertDatalen);
	 ConvertDatalen(Datalen2Convert, Metadata2ConvertDatalen, Metadata2ParseData);
	 Parse_Data(Data_after_len, Metadata2ParseData, Instr2ParseData, Data_Stream);
	 Output_Packet(Packet_output,Instr2Output, Data_Stream, Key2Output, Datalen2Output);

	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;

}


