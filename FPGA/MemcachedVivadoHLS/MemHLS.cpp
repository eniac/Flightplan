#include "MemHLS.h"
#include <iostream>



static Cache Memory[MAX_MEMORY_SIZE];
void Extract_Data(hls::stream<packet_interface> &Packet_in, hls::stream<Data_Word> &Data_out, Part_Word &End_word)
{

	bool End;
	packet_interface Input;
	do
	{
		Input = Packet_in.read();
		End = Input.End_of_frame;
		Data_out.write(Input.Data);
	}while(!End);
	End_word.Data = Input.Data;
	End_word.len = Input.Count;

}
void Print_Single_word(Data_Word Data)
{
	std::cout << "Word " <<": ";
	for (int i = 0; i<BYTES_PER_WORD; i++)
	{
		Byte Raw_Byte;
		Raw_Byte = Data.range(63,56);
		std::cout << (uint8_t) Raw_Byte;
		Data <<= 8;
	}
	std::cout << std::endl;
}
void Print_Data(hls::stream<Data_Word> &Data_in, hls::stream<Data_Word> &Data_out)
{
	int num = 0;
	Data_Word buffer;
	while (!Data_in.empty())
	{
		buffer = Data_in.read();
		Print_Single_word(buffer);
		Data_out.write(buffer);
	}

}


void Read_and_Align(hls::stream<packet_interface> &Data_in, Part_Word &Align_word, Data_Word &Full_word)
{
#pragma HLS inline
	packet_interface Input;
	Data_Word buffer = 0;
	if (!Data_in.empty()) { Input= Data_in.read(); 	buffer = Input.Data;}
	else buffer = 0;
	//buffer.range(63, 64 - Input.Count *8) = Input.Data.range(63, 64 - Input.Count *8);
	uint8_t len_left = Align_word.len;
	uint8_t len_required = 0;
	len_required =BYTES_PER_WORD - len_left;
	Full_word = (buffer >> len_left*8) | Align_word.Data;
	//Align_word.Data = (buffer << len_required * 8);
	if (len_left !=0) Align_word.Data.range(63, 64 - len_left * 8) = buffer.range(63 - len_required*8, 0);
	if (Input.End_of_frame) Input.Data.range(31, 0) = 0x1122334455;


}
void Remove_and_Realign(hls::stream<Data_Word> & Buffer_Stream, Part_Word & Align_word, Data_Word &Full_word, int num_remove)
{
#pragma HLS inline
	Data_Word buffer =0;
	Full_word <<= 8*num_remove;
	buffer = Full_word | (Align_word.Data >>8*(BYTES_PER_WORD - num_remove));
	if (Align_word.len < num_remove)
	{
		Align_word.len = BYTES_PER_WORD - num_remove + Align_word.len;;
		Align_word.Data.range(63, 64 - Align_word.len * 8) = buffer.range(63, 64 - Align_word.len * 8);
	}
	else
	{
		Buffer_Stream.write(buffer);
		Align_word.len -= num_remove;
		Align_word.Data = Align_word.Data << num_remove * 8;
	}


}
void Parse_Internet_Hdr(hls::stream<packet_interface> &Data_in, enum mem_protocl Protocl, Part_Word &Align_word, Data_Word &Memcached_Hdr)
{
	uint8_t offset_len;
	uint8_t num_remove;
	packet_interface Input;
	if (Protocl == UDP_Protocl)
		offset_len = PAYLOAD_OFFSET_UDP;
	for (int i = 0; i < offset_len / BYTES_PER_WORD; i++)
		Data_in.read();
	num_remove =offset_len % BYTES_PER_WORD;
	Align_word.len = BYTES_PER_WORD - num_remove;
	if (num_remove !=0)
	{
		Input = Data_in.read();
		Align_word.Data = Input.Data;
		//Align_word.Data.range(63, 64 - Align_word.len * 8) = Align_word.Data.range((BYTES_PER_WORD - num_remove) * 8 - 1, 0);
		Align_word.Data <<= 8 * num_remove;
	}
	else
	{
		Align_word.len = 0;
		Align_word.Data = 0;
	}
	Read_and_Align(Data_in, Align_word, Memcached_Hdr);


}

void Parse_Command(hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> &Buffer_Stream, Part_Word &Align_word, enum ascii_cmd &result)
{
	Cmd_Word commands[NUM_OF_CMD];
	commands[0].cmd[0] ='g';
	commands[0].cmd[1] ='e';
	commands[0].cmd[2] ='t';
	commands[0].cmd[3] =' ';
	commands[0].cc = GET_CMD;
	commands[0].len = 4;

	commands[1].cmd[0] ='s';
	commands[1].cmd[1] ='e';
	commands[1].cmd[2] ='t';
	commands[1].cmd[3] =' ';
	commands[1].cc = SET_CMD;
	commands[1].len = 4;

	commands[2].cmd[0] ='d';
	commands[2].cmd[1] ='e';
	commands[2].cmd[2] ='l';
	commands[2].cmd[3] ='e';
	commands[2].cmd[4] ='t';
	commands[2].cmd[5] ='e';
	commands[2].cmd[6] =' ';
	commands[2].cc = DELETE_CMD;
	commands[2].len = 7;

	commands[3].cmd[0] ='V';
	commands[3].cmd[1] ='A';
	commands[3].cmd[2] ='L';
	commands[3].cmd[3] ='U';
	commands[3].cmd[4] ='E';
	commands[3].cmd[5] =' ';
	commands[3].cc = VALUE_RESP;
	commands[3].len = 6;

	commands[4].cmd[0] ='D';
	commands[4].cmd[1] ='E';
	commands[4].cmd[2] ='L';
	commands[4].cmd[3] ='E';
	commands[4].cmd[4] ='T';
	commands[4].cmd[5] ='E';
	commands[4].cmd[6] ='D';
	commands[4].cmd[7] =' ';
	commands[4].cc = DELETED_RESP;
	commands[4].len = 8;

	result = UNKNOWN_CMD;
	uint8_t cmd = NUM_OF_CMD;
	Data_Word buffer = 0;
	Read_and_Align(Data_in, Align_word, buffer);
	for (int i = 0; i < NUM_OF_CMD - 1; i++)
	{
#pragma HLS unroll
		Byte byte_1 = buffer.range(63,56);
		Byte byte_end = buffer.range((BYTES_PER_WORD - commands[i].len + 1)*8, (BYTES_PER_WORD - commands[i].len)*8);
		if (byte_1 == commands[i].cmd[0] && byte_end == 0x20) cmd = i;
	}
	if (cmd != NUM_OF_CMD)
	{
		Remove_and_Realign(Buffer_Stream, Align_word, buffer, commands[cmd].len);
		result = commands[cmd].cc;
	}
}

int Find_Delimiter(Data_Word Data)
{
#pragma HLS inline
	int result = -1;
	for (int i = 7; i >= 0; i--)
	{
#pragma HLS unroll
		Byte temp;
		temp = Data.range((BYTES_PER_WORD - i)*8-1, (BYTES_PER_WORD - i - 1)*8);
		if (temp == 13 || temp == 32) { result = i;  }
	}
	return result;
}

int Parse_Numerical_Field(hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> & Buffer_Stream, Part_Word &Align_Word)
{
	int result = 0;
	Data_Word buffer, Ori;
	buffer =0;
	Ori = 0;
	if (Buffer_Stream.empty())
		Read_and_Align(Data_in, Align_Word, buffer);
	else
		buffer = Buffer_Stream.read();
	int delimiter = Find_Delimiter(buffer);
	Ori = buffer;
	for (int i = 0; i < delimiter; i++)
	{
#pragma HLS pipeline II=1
		Byte temp = buffer.range(63,56);
		result = result * 10 + (int) temp - (int) '0';
		buffer <<= 8;
	}
	if (buffer.range(63,56) == 0x0d) delimiter++;
	Remove_and_Realign(Buffer_Stream, Align_Word, Ori, delimiter + 1);
	return result;

}

uint16_t hash(Data_Word Data)
{
	uint16_t result = 0;
	Data = (~Data) + (Data << 21);
	Data = Data ^ (Data >> 24);
	Data = (Data + (Data << 3)) + (Data << 8);
	Data = Data ^ (Data >> 14);
	Data = (Data + (Data << 2)) + (Data << 4);
	Data = Data ^ (Data >> 28);
	Data = Data + (Data << 31);
	result = (uint16_t) (Data % MAX_MEMORY_SIZE);
	return result;
}
uint16_t Parse_Set_Key(hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> &Buffer_Stream, Part_Word &Align_Word, hls::stream<Data_Word> &Key_Stream, Part_Word &Key_Remain)
{
	int delimiter = -1;
	int num = 0;
	uint16_t hash_result = 0;
	Data_Word buffer = 0;

	if (Buffer_Stream.empty())
		Read_and_Align(Data_in, Align_Word, buffer);
	else
		buffer = Buffer_Stream.read();
	delimiter = Find_Delimiter(buffer);
	while (delimiter==-1)
	{
#pragma HLS pipeline II=1
#pragma HLS loop_tripcount min=1 max=33 avg=8
		Key_Stream.write(buffer);
		num += 8;
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;
		Read_and_Align(Data_in, Align_Word, buffer);
		delimiter = Find_Delimiter(buffer);
	}
	num += delimiter;
	if (delimiter != 0)
	{
		Data_Word temp_key;
		temp_key.range(63,64-delimiter*8) = buffer.range(63,64-delimiter*8);
		Key_Remain.Data = temp_key;
		hash_result ^= (hash(temp_key) + num);
		hash_result ^= temp_key.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;
	}
	Key_Remain.len = delimiter;
	Remove_and_Realign(Buffer_Stream, Align_Word, buffer, delimiter + 1);


	return hash_result;
}

uint16_t Parse_Get_Key(hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> &Buffer_Stream, Part_Word &Align_Word, hls::stream<Data_Word> &Key_Stream, Part_Word &Key_Remain)
{
	int delimiter = -1;
	int num = 0;
	uint8_t tempnum;
	uint16_t hash_result = 0;
	Data_Word buffer = 0;
	packet_interface Input;

	if (Buffer_Stream.empty())
		Read_and_Align(Data_in, Align_Word, buffer);
	else
		buffer = Buffer_Stream.read();
	bool pktcomplete;
	pktcomplete = false;
	num = 0;
	while (!pktcomplete)
	{
#pragma HLS pipeline II = 1
#pragma HLS loop_tripcount min=1 max=33 avg=8
		num += 8;
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;
		Data_in.read(Input);
		pktcomplete = Input.End_of_frame;
		buffer = (Input.Data >> Align_Word.len * 8) | Align_Word.Data;
		Align_Word.Data.range(63, 64 - 8 * Align_Word.len) = Input.Data.range(8*Align_Word.len-1,0);

	}
	tempnum = Input.Count + Align_Word.len;
	if (tempnum == 9)
	{
		num += 7;
		buffer.range(7,0) = 0;
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;
	}
	else if (tempnum  == 10)
	{
		num +=8;
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;

	}
	else if (tempnum  > 10)
	{
		num +=8;
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;
		tempnum -=8;
		num += tempnum  - 2;
		//Align_Word.Data.range(79- 8*tempnum, 64 - 8*tempnum) = 0;
		//buffer = Align_Word.Data;
		buffer = 0;
		buffer.range(63, 64 - (tempnum-2) * 8) = Align_Word.Data.range(63, 64 - (tempnum-2) * 8);
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;

	}
	else if (tempnum > 2)
	{
		num += (tempnum - 2);
		//buffer.range(79- 8*tempnum, 64 - 8*tempnum) = 0;
		Data_Word temp = buffer;
		buffer = 0;
		buffer.range(63, 64 - (tempnum-2) * 8) = temp.range(63, 64 - (tempnum-2) * 8);
		hash_result ^= (hash(buffer) + num);
		hash_result ^= buffer.range(16,0);
		hash_result %= MAX_MEMORY_SIZE;
	}
//	while (delimiter==-1)
//	{
//#pragma HLS pipeline II=1
//#pragma HLS loop_tripcount min=1 max=33 avg=8
//		num += 8;
//		hash_result ^= (hash(buffer) + num);
//		hash_result ^= buffer.range(16,0);
//		hash_result %= MAX_MEMORY_SIZE;
//		Read_and_Align(Data_in, Align_Word, buffer);
//		delimiter = Find_Delimiter(buffer);
//	}
//	if (delimiter != 0)
//	{
//		Data_Word temp_key;
//		temp_key.range(63,64-delimiter*8) = buffer.range(63,64-delimiter*8);
//		Key_Remain.Data = temp_key;
//		hash_result ^= (hash(temp_key) + num);
//		hash_result ^= temp_key.range(16,0);
//		hash_result %= MAX_MEMORY_SIZE;
//	}
//	Key_Remain.len = delimiter;
//	num += delimiter;
//	if (delimiter == 7 && Align_Word.len == 0) Read_and_Align(Data_in, Align_Word, buffer);


	return hash_result;
}

void Save_key(Cache &Mem_Block, hls::stream<Data_Word> &Key_Stream, Part_Word &Key_Remain)
{
	int count = 0;
	while (!Key_Stream.empty())
	{
#pragma HLS loop_tripcount min=1 max=33 avg=8
		Mem_Block.KEY[count] = Key_Stream.read();
		count++;
	}
	Mem_Block.KEY_LEN = count * 8 + Key_Remain.len;
	Mem_Block.KEY[count] = Key_Remain.Data;
}
void Parse_Data(Cache & Mem_Block, hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> &Buffer_Stream, Part_Word &Align_Word)
{
	int count = 1;
	if (Buffer_Stream.empty())
		Read_and_Align(Data_in, Align_Word, Mem_Block.DATA[0]);
	else
		Mem_Block.DATA[0] = Buffer_Stream.read();
	count = Mem_Block.DATA_LEN / BYTES_PER_WORD;
	for (int i = 1; i < count; i++)
	{
#pragma HLS loop_tripcount min=8 max=256 avg=128
		Read_and_Align(Data_in, Align_Word, Mem_Block.DATA[i]);
	}
	int remain = Mem_Block.DATA_LEN % BYTES_PER_WORD;
	if (Align_Word.len < remain)
	{
		Read_and_Align(Data_in,Align_Word, Mem_Block.DATA[count]);
	}
	else
		Mem_Block.DATA[count] = Align_Word.Data;
}

void Print_Memory(int index)
{
	Data_Word buffer;
	std::cout << "The No." << index << " Memory block has " << Memory[index].KEY_LEN << " Bytes key and " << Memory[index].DATA_LEN << " Bytes Data." << std::endl;
	std::cout << "The Key is: "<< std::endl;
	for (int i = 0; i < Memory[index].KEY_LEN/BYTES_PER_WORD; i++)
	{
		buffer = Memory[index].KEY[i];
		for (int j = 0; j< BYTES_PER_WORD; j++)
		{
			uint8_t temp;
			temp = buffer.range(63,56);
			std::cout << temp;
			buffer <<= 8;
		}
	}
	buffer = Memory[index].KEY[Memory[index].KEY_LEN/BYTES_PER_WORD];
	for (int j = 0; j< Memory[index].KEY_LEN % BYTES_PER_WORD; j++)
	{
		uint8_t temp;
		temp = buffer.range(63,56);
		std::cout << temp;
		buffer <<= 8;
	}
	std::cout << std::endl;
	std::cout << "The Data is: "<< std::endl;
	for (int i = 0; i < Memory[index].DATA_LEN/BYTES_PER_WORD; i++)
	{
		buffer = Memory[index].DATA[i];
		for (int j = 0; j< BYTES_PER_WORD; j++)
		{
			uint8_t temp;
			temp = buffer.range(63,56);
			std::cout << temp;
			buffer <<= 8;
		}
	}
	buffer = Memory[index].DATA[Memory[index].DATA_LEN/BYTES_PER_WORD];
	for (int j = 0; j< Memory[index].DATA_LEN % BYTES_PER_WORD; j++)
	{
		uint8_t temp;
		temp = buffer.range(63,56);
		std::cout << temp;
		buffer <<= 8;
	}
	std::cout << std::endl;
}
void Mem_Parse_Set(hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> &Buffer_Stream, Part_Word &Align_word)
{
	Part_Word  Key_remained;
	Key_remained.Data = 0;
	Key_remained.len = 0;
	Data_Word buffer = 0;
	static hls::stream<Data_Word> Key_Stream;
#pragma HLS STREAM variable=Key_Stream depth=Key_Stream_Size

	uint16_t index = Parse_Set_Key(Data_in, Buffer_Stream, Align_word, Key_Stream, Key_remained);
	Memory[index].VALID = 1;
	Save_key(Memory[index],Key_Stream, Key_remained);
	int flag = Parse_Numerical_Field(Data_in,Buffer_Stream, Align_word);
	int expert = Parse_Numerical_Field(Data_in,Buffer_Stream, Align_word);
	std::cout<< "Finish expert Parse" << std::endl;
	std::cout << "The expert is " << expert << std::endl;
	Memory[index].DATA_LEN = Parse_Numerical_Field(Data_in,Buffer_Stream, Align_word) + 2;
	std::cout<< "Finish LEN Parse" << std::endl;
	std::cout << "The LEN is " << Memory[index].DATA_LEN << std::endl;
	Parse_Data(Memory[index],Data_in, Buffer_Stream, Align_word);
	std::cout<< "Finish Data Parse" << std::endl;
	Print_Memory(index);

}

int Mem_Parse_Get(hls::stream<packet_interface> &Data_in, hls::stream<Data_Word> &Buffer_Stream, Part_Word &Align_word)
{
	Part_Word  Key_remained;
	Key_remained.Data = 0;
	Key_remained.len = 0;
	static hls::stream<Data_Word> Key_Stream;
#pragma HLS STREAM variable=Key_Stream depth=Key_Stream_Size
	uint16_t index = Parse_Get_Key(Data_in, Buffer_Stream, Align_word, Key_Stream, Key_remained);
	return index;
}

void Add_Protocl(hls::stream<Data_Word> & Word_output, Part_Word & Left_word, enum mem_protocl Protocl, Data_Word &Memcached_hdr)
{
	int hdr_len = 0;
	if (Protocl == UDP_Protocl)
	{
		hdr_len = PAYLOAD_OFFSET_UDP;
	}
	for (int i = 0; i < hdr_len / BYTES_PER_WORD; i++)
	{
		Word_output.write(0);
	}
	Data_Word buffer = 0;
	Left_word.len = hdr_len % BYTES_PER_WORD;
	buffer.range(47, 0) =  Memcached_hdr.range(63, 16);
	Word_output.write(buffer);
	Left_word.Data = 0;

}

Data_Word Merge_Full_and_Part(Data_Word & Full_word, Part_Word & Left_word)
{
	Data_Word result = 0;
	int tot_len = Left_word.len + BYTES_PER_WORD;
	if (tot_len == BYTES_PER_WORD)
	{
		result = Full_word;
	}
	else
	{
		result = Left_word.Data | (Full_word >> 8*Left_word.len);
		Left_word.Data = Full_word << 8*(BYTES_PER_WORD - Left_word.len);
	}
	return result;
}
void Merge_Part_and_Part(Part_Word &Left_word, Part_Word &New_word, hls::stream<Data_Word> &Output_stream)
{
	int tot_len = Left_word.len + New_word.len;
	Data_Word buffer = Left_word.Data | (New_word.Data >> 8*Left_word.len);
	if (tot_len < BYTES_PER_WORD)
	{
		Left_word.Data = buffer;
		Left_word.len = tot_len;
	}
	else if (tot_len == BYTES_PER_WORD)
	{
		Left_word.Data = 0;
		Left_word.len = 0;
		Output_stream.write(buffer);
	}
	else
	{
		Left_word.Data = New_word.Data << ((BYTES_PER_WORD - Left_word.len)*8);
		Left_word.len = tot_len - 8;
		Output_stream.write(buffer);
	}
}
void Add_Resp_Word(hls::stream<Data_Word> & Word_output, Part_Word & Left_word, enum resp_index Resp_index)
{
	Part_Word Resp_Word = Standard_Response[Resp_index];
	Merge_Part_and_Part(Left_word, Resp_Word, Word_output);
}
void Add_Resp_Key(hls::stream<Data_Word> & Word_output, Part_Word & Left_word, int index)
{
	int count = Memory[index].KEY_LEN / BYTES_PER_WORD;
	int remain = Memory[index].KEY_LEN % BYTES_PER_WORD;
	for (int i = 0; i < count; i++)
	{
#pragma HLS loop_tripcount min=8 max=32 avg=16
		Word_output.write(Merge_Full_and_Part(Memory[index].KEY[i],Left_word));
	}
	if (remain != 0)
	{
		Part_Word Key_word;
		Key_word.len = remain;
		Key_word.Data = Memory[index].KEY[count];
		Merge_Part_and_Part(Left_word, Key_word, Word_output);
	}
}
void Add_Resp_Data(hls::stream<Data_Word> & Word_output, Part_Word & Left_word, int index)
{
	int count = Memory[index].DATA_LEN / BYTES_PER_WORD;
	int remain = Memory[index].DATA_LEN % BYTES_PER_WORD;
	for (int i = 0; i < count; i++)
	{
#pragma HLS pipeline II=1
#pragma HLS loop_tripcount min=8 max=256 avg=64
		Word_output.write(Merge_Full_and_Part(Memory[index].DATA[i],Left_word));
	}
	if (remain != 0)
	{
		Part_Word DATA_word;
		DATA_word.len = remain;
		Memory[index].DATA[count].range(63 - 8*remain, 0) = 0;
		DATA_word.Data = Memory[index].DATA[count];
		Merge_Part_and_Part(Left_word, DATA_word, Word_output);
	}
}
Part_Word Generate_Word_for_Number(int number)
{
#pragma HLS inline
	Part_Word result;
	result.len = 0;
	result.Data = 0;
	do
	{
//#pragma HLS pipeline
#pragma HLS loop_tripcount min = 1 max = 8
		result.Data >>= 8;
		ap_uint<8> temp = (number % 10) + 48;
		result.len++;
		result.Data.range(63,56) = temp;
		number /= 10;
	}while(number > 0);
	return result;
}
void Add_Numerical_Word(hls::stream<Data_Word> & Word_output, Part_Word & Left_word, int num)
{
	Part_Word Num_Word = Generate_Word_for_Number(num);
	Merge_Part_and_Part(Left_word, Num_Word, Word_output);

}
void Modify_Hdr_Length(output_tuples & Tuple_out, uint16_t len)
{
        Tuple_out.Hdr.Ipv4.totallen = len - ETH_HDR_LEN;
        Tuple_out.Hdr.Udp.len = len - ETH_HDR_LEN - IPV4_HDR_LEN;

}

uint16_t Output_packets(hls::stream<packet_interface> & Packet_output, hls::stream<Data_Word> &Word_output, Part_Word & Left_word)
{
	uint16_t count = 0;
	packet_interface Output;
	Output.Count = BYTES_PER_WORD;
	Output.Start_of_frame = 1;
	Output.Data = Word_output.read();
	Output.Error = 0;
	Output.End_of_frame = 0;
	while(!Word_output.empty())
	{
#pragma HLS loop_tripcount min=8 max=256 avg=64

		Output.End_of_frame = 0;
		Packet_output.write(Output);
		count +=8;
		Output.Start_of_frame = 0;
		Output.Count = BYTES_PER_WORD;
		Output.Data = Word_output.read();
		Output.Error = 0;
	}
	if (Left_word.len == 0)
	{
		count +=8;
		if (count >= MINIMUM_ETH_LEN)
		{
			Output.End_of_frame = 1;
			Packet_output.write(Output);
		}
		else
		{
			uint16_t temp = count;
			while (MINIMUM_ETH_LEN > count + BYTES_PER_WORD)
			{
#pragma HLS loop_tripcount min=1 max=2
				Output.End_of_frame = 0;
				Output.Start_of_frame = 0;
				Output.Data = 0;
				Output.Error = 0;
				Output.Count = BYTES_PER_WORD;
				Packet_output.write(Output);
				count += 8;
			}
			Output.Count = MINIMUM_ETH_LEN - count;
			Output.Data = 0;
			Output.Error = 0;
			Output.End_of_frame = 1;
			Output.Start_of_frame = 0;
			Packet_output.write(Output);
			count = temp;
		}

	}
	else
	{
		Output.End_of_frame = 0;
		Packet_output.write(Output);
		count +=8;
		Output.End_of_frame = 1;
		Output.Count = Left_word.len;
		count += Left_word.len;
		if (count < MINIMUM_ETH_LEN) Output.Count+= (MINIMUM_ETH_LEN - count);
		Output.Data = Left_word.Data;
		Output.Error = 0;
		Output.Start_of_frame = 0;
		Packet_output.write(Output);

	}
	return count;
}
void Swap_Hdr_address(output_tuples &tuple_out)
{
	ap_uint<48> eth_temp;
	eth_temp = tuple_out.Hdr.Eth.Dst;
	tuple_out.Hdr.Eth.Dst =tuple_out.Hdr.Eth.Src;
	tuple_out.Hdr.Eth.Src = eth_temp;
	ap_uint<32> ipv4_temp;
	ipv4_temp = tuple_out.Hdr.Ipv4.dstAddr;
	tuple_out.Hdr.Ipv4.dstAddr = tuple_out.Hdr.Ipv4.srcAddr;
	tuple_out.Hdr.Ipv4.srcAddr = ipv4_temp;
	ap_uint<16> udp_temp;
	udp_temp = tuple_out.Hdr.Udp.sport;
	tuple_out.Hdr.Udp.sport = tuple_out.Hdr.Udp.dport;
	tuple_out.Hdr.Udp.dport = udp_temp;
}
void Mem_Action_Set(hls::stream<packet_interface> & Packet_output, enum mem_protocl Protocl, output_tuples & tuple_out, Data_Word &Memcached_hdr)
{
	Part_Word Left_word;
	enum resp_index resp_word;
	static hls::stream<Data_Word> Word_output;
#pragma HLS STREAM variable=Word_output depth=Data_Stream_Size

	Add_Protocl(Word_output, Left_word, Protocl, Memcached_hdr);

	resp_word = _STORED;
	Add_Resp_Word(Word_output, Left_word, resp_word);

	resp_word = _END_OF_LINE;
	Add_Resp_Word(Word_output, Left_word, resp_word);

	uint16_t packet_len = Output_packets(Packet_output, Word_output, Left_word);
	Modify_Hdr_Length(tuple_out, packet_len);
	Swap_Hdr_address(tuple_out);
}

void Mem_Action_Get(hls::stream<packet_interface> & Packet_output, enum mem_protocl Protocl, int index, output_tuples & tuple_out , Data_Word &Memcached_hdr)
{
	Part_Word Left_word;
	enum resp_index resp_word;
	static hls::stream<Data_Word> Word_output;
#pragma HLS STREAM variable=Word_output depth=Data_Stream_Size
	Add_Protocl(Word_output, Left_word, Protocl, Memcached_hdr);
	std::cout << index << std::endl;
	std::cout << "VALID " << Memory[index].VALID << std::endl;
	if (Memory[index].VALID)
	{
		resp_word = _VALUE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		Add_Resp_Key(Word_output, Left_word, index);

		resp_word = _SPACE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		Add_Numerical_Word(Word_output,Left_word, 0);

		resp_word = _SPACE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		Add_Numerical_Word(Word_output,Left_word, Memory[index].DATA_LEN - 2);

		resp_word = _END_OF_LINE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		Add_Resp_Data(Word_output,Left_word, index);

		//resp_word = _END;
		//Add_Resp_Word(Word_output, Left_word, resp_word);
		Part_Word Resp_Word ={0x454E440000000000, 3};
		Merge_Part_and_Part(Left_word, Resp_Word, Word_output);



		resp_word = _END_OF_LINE;
		Add_Resp_Word(Word_output, Left_word, resp_word);
	}
	else
	{
		resp_word = _NOT_SPACE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		resp_word = _FOUND;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		resp_word = _END;
		Add_Resp_Word(Word_output, Left_word, resp_word);
	}

	uint16_t packet_len = Output_packets(Packet_output, Word_output, Left_word);
	Modify_Hdr_Length(tuple_out, packet_len);
	Swap_Hdr_address(tuple_out);
}

void Mem_Parser(hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output, output_tuples & tuple_out)
{
	Part_Word Align_word, End_word;
	Align_word.Data = 0;
	Align_word.len = 0;
	End_word.Data = 0;
	End_word.len = 0;
	Data_Word Memcached_hdr;
//	static hls::stream<Data_Word> Data_in;
//#pragma HLS STREAM variable=Data_in depth=Data_Stream_Size
	static hls::stream<Data_Word> Buffer_Stream;
#pragma HLS STREAM variable=Buffer_Stream depth=5
//	Extract_Data(Packet_input,Data_in,End_word);
	std::cout << "Finish Extraction" << std::endl;
	enum mem_protocl Protocl;
	enum ascii_cmd Command;
	Protocl = UDP_Protocl;
	Parse_Internet_Hdr(Packet_input, Protocl, Align_word, Memcached_hdr);
	Parse_Command(Packet_input, Buffer_Stream, Align_word, Command);
	std::cout<< "Finish CMD Parse" << std::endl;
	std::cout << "The Command is " << Command << std::endl;
	std::cout << std::endl;
	switch (Command)
	{
		case SET_CMD:
			{
				Mem_Parse_Set(Packet_input, Buffer_Stream, Align_word);
				Mem_Action_Set(Packet_output, Protocl, tuple_out, Memcached_hdr);
				break;
			}

		case GET_CMD:
			{
				int index =	Mem_Parse_Get(Packet_input, Buffer_Stream, Align_word);
				Mem_Action_Get(Packet_output, Protocl, index, tuple_out, Memcached_hdr);
				break;
			}

		case DELETE_CMD:
			{
				int index_delete =	Mem_Parse_Get(Packet_input, Buffer_Stream, Align_word);
				Memory[index_delete].VALID = 0;
				break;
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
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
	input_tuples tuple_in = Input_tuples.read();
	output_tuples tuple_out;
	tuple_out.Hdr = tuple_in.Hdr;
	if (tuple_in.Hdr.Ipv4.protocol != 0x11 || tuple_in.Hdr.Eth.Type != 0x0800 || tuple_in.Hdr.Udp.dport !=11211)
	{
		while(!Packet_input.empty())
		{
#pragma HLS loop_tripcount min=8 max=512 avg=64
			packet_interface Input;
			Input = Packet_input.read();
			Packet_output.write(Input);
		}

	}
	else
	{
		Mem_Parser(Packet_input, Packet_output, tuple_out);
	}
	Output_tuples.write(tuple_out);

	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;

}


