#include "MemHLS.h"
#include <iostream>



static Cache Memory[MAX_MEMORY_SIZE];
void alignment(hls::stream<Data_Word> &Data_in, hls::stream<Data_Word> &Data_out, Part_Word &End_word, Part_Word &Align_remained);
void Extract_Data(hls::stream<packet_interface> &Packet_in, hls::stream<Data_Word> &Data_out, Part_Word &End_word)
{

	bool End;
	packet_interface Input;
	do
	{
		Input = Packet_in.read();
		End = Input.End_of_frame;
		if (!End) Data_out.write(Input.Data);
	}while(!End);
	End_word.Data = Input.Data;
	End_word.len = Input.Count;

}

void Print_Data(hls::stream<Data_Word> &Data_in, Part_Word &End_word)
{
	int num = 0;
	Data_Word buffer;
	while (!Data_in.empty())
	{
		num++;
		std::cout << "Word "<< num <<": ";
		buffer = Data_in.read();
		for (int i = 0; i<BYTES_PER_WORD; i++)
		{
			Byte Raw_Byte;
			Raw_Byte = buffer.range(63,56);
			std::cout << (uint8_t) Raw_Byte;
			buffer <<= 8;
		}
		std::cout << std::endl;
	}
	buffer = End_word.Data;
	std::cout << "Word "<< num <<": ";
	for (int i = 0; i < End_word.len; i++)
	{
		Byte Raw_Byte;
		Raw_Byte = buffer.range(63,56);
		std::cout << (int) Raw_Byte;
		buffer <<= 8;
	}
}



void alignment(hls::stream<Data_Word> &Data_in, hls::stream<Data_Word> &Data_out, Part_Word &End_word, Part_Word &Align_remained)
{
#pragma HLS inline
	uint8_t num_remained = Align_remained.len;
	uint8_t num_aligned = BYTES_PER_WORD - num_remained;
	Data_Word buffer;
	Data_Word Word_remained = Align_remained.Data;

	if (num_aligned > 8)
	{
		std::cout << "ERROR" << std::endl;
		return;
	}

	if (num_aligned == 8 || num_aligned == 0)
	{
		buffer = Data_in.read();
		if (buffer.range(63,56)!=0x0a)
			while (!Data_in.empty())
				Data_out.write(Data_in.read());
		else
		{
			num_aligned = 1;
			num_remained = 7;
			Word_remained = buffer << 8;
		}
	}


	while (!Data_in.empty())
	{
		buffer = Data_in.read();
		Data_out.write((buffer>>8*num_remained)|Word_remained);
		Word_remained = buffer.range(num_remained*8-1,0);
		Word_remained <<= 8*num_aligned;
	}
	if (End_word.len > num_aligned)
	{
		End_word.len -= num_aligned;
		Data_out.write((End_word.Data>>8*num_remained)|Word_remained);
		End_word.Data <<= 8*num_aligned;
	}
	else
	{
		End_word.len += num_remained;
		End_word.Data = (End_word.Data>>8*num_remained) | Word_remained;
	}
	Align_remained.len = 0;
}

Part_Word Parse_Internet_Hdr(hls::stream<Data_Word> &Data_in, enum mem_protocl Protocl)
{
	uint8_t offset_len;
	uint8_t num_remove;
	Part_Word Need_aligned;
	if (Protocl == UDP_Protocl)
		offset_len = PAYLOAD_OFFSET_UDP;
	for (int i = 0; i < offset_len / BYTES_PER_WORD; i++)
		Data_in.read();
	num_remove =offset_len % BYTES_PER_WORD;
	Need_aligned.len = BYTES_PER_WORD - num_remove;
	if (num_remove !=0)
	{
		Need_aligned.Data = Data_in.read();
		Need_aligned.Data = Need_aligned.Data.range((BYTES_PER_WORD - num_remove) * 8 - 1, 0);
		Need_aligned.Data <<= 8 * num_remove;
	}

	return Need_aligned;
}


static enum ascii_cmd Parse_Command(hls::stream<Data_Word> &Data_in, Part_Word &Align_word)
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

	enum ascii_cmd result = UNKNOWN_CMD;
	uint8_t cmd = NUM_OF_CMD;
	Data_Word buffer;
	buffer = Data_in.read();
	for (int i = 0; i < NUM_OF_CMD; i++)
	{
#pragma HLS unroll
		for (int j = 0; j < commands[i].len; j++)
		{
			Byte raw_byte = buffer.range((BYTES_PER_WORD - j)*8 - 1,  (BYTES_PER_WORD - j - 1)*8);
			if (raw_byte != commands[i].cmd[j]) break;
			if (j == commands[i].len - 1) cmd = i;
		}

	}
	if (cmd != NUM_OF_CMD)
	{
		Align_word.len = BYTES_PER_WORD - commands[cmd].len;
		Align_word.Data = buffer << commands[cmd].len * 8;
		result = commands[cmd].cc;

	}
	return result;
}

int Find_Delimiter(Data_Word Data)
{
	int result = -1;
	for (int i = 0; i < BYTES_PER_WORD; i++)
	{
#pragma HLS unroll
		Byte temp;
		temp = Data.range((BYTES_PER_WORD - i)*8-1, (BYTES_PER_WORD - i - 1)*8);
		if (temp == 13 || temp == 32) { result = i; break; }
	}
	return result;
}

int Parse_Numerical_Field(hls::stream<Data_Word> &Data_in, Part_Word &Align_Word)
{
	int result = 0;
	Data_Word buffer = Data_in.read();
	int delimiter = Find_Delimiter(buffer);
	for (int i = 0; i < delimiter; i++)
	{
		Byte temp = buffer.range(63,56);
		buffer <<=8;
		result = result * 10 + (int) temp - (int) '0';
	}
	buffer <<=8;
	if (buffer.range(63,56) == 0x0a) {delimiter++; buffer <<=8;}
	Align_Word.len = BYTES_PER_WORD -delimiter - 1;
	Align_Word.Data = buffer;
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
uint16_t Parse_Key(hls::stream<Data_Word> &Data_in, Part_Word &End_Word, Part_Word &Align_Word, hls::stream<Data_Word> &Key_Stream, Part_Word &Key_Remain)
{
	int delimiter = -1;
	int num = 0;
	uint16_t hash_result = 0;
	Data_Word buffer;
	while (delimiter==-1)
	{
		if (!Data_in.empty()) buffer = Data_in.read();
		else { buffer = End_Word.Data; End_Word.len = 0;}
		delimiter = Find_Delimiter(buffer);
		if (delimiter != -1)
		{
			Align_Word.len = BYTES_PER_WORD - delimiter - 1;
			Align_Word.Data = buffer << (delimiter + 1)*8;
			if (Align_Word.Data.range(63,56) == 0x0a)
			{
				Align_Word.len--;
				Align_Word.Data <<=8;
			}
			if (delimiter != 0)
			{
				buffer = buffer.range(63,64-delimiter*8);
				Key_Remain.Data = buffer;
				hash_result ^= (hash(buffer) + num);
				hash_result %= MAX_MEMORY_SIZE;
			}
			Key_Remain.len = delimiter;
			num += delimiter;
		}
		else
		{
			Key_Stream.write(buffer);
			num += 8;
			hash_result ^= (hash(buffer) + num);
			hash_result %= MAX_MEMORY_SIZE;
		}
	}
	return hash_result;
}
void Save_key(Cache &Mem_Block, hls::stream<Data_Word> &Key_Stream, Part_Word &Key_Remain)
{
	int count = 0;
	while (!Key_Stream.empty())
	{
		Mem_Block.KEY[count] = Key_Stream.read();
		count++;
	}
	Mem_Block.KEY_LEN = count * 8 + Key_Remain.len;
	Mem_Block.KEY[count] = Key_Remain.Data;
}
void Parse_Data(Cache & Mem_Block, hls::stream<Data_Word> &Data_in, Part_Word &End_Word)
{
	int count = 0;
	for (int i = 0; i < Mem_Block.DATA_LEN / BYTES_PER_WORD; i++)
	{
		count++;
		if (Data_in.empty()) {std::cout << "ERROR NOT ENOUGH DATA" << std::endl;}
		Mem_Block.DATA[i] = Data_in.read();
	}
	if (End_Word.len - 2 == Mem_Block.DATA_LEN % BYTES_PER_WORD)
		Mem_Block.DATA[count + 1] = End_Word.Data;
	else if (End_Word.len -2 > Mem_Block.DATA_LEN % BYTES_PER_WORD)
	{
		std::cout << "ERROR EXTRA DATA CONTAINED" << std::endl;
	}
	else
	{
		std::cout << "ERROR NOT ENOUGH DATA" << std::endl;
	}
}

void Print_Memory(int index)
{
	Data_Word buffer;
	std::cout << "The No." << index << " Memory block has " << Memory[index].KEY_LEN << " Bytes key and " << Memory[index].DATA_LEN << " Bytes Data." << std::endl;
	std::cout << "The OKey is: "<< std::endl;
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
	buffer = Memory[index].KEY[Memory[index].KEY_LEN/BYTES_PER_WORD+1];
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
	buffer = Memory[index].DATA[Memory[index].DATA_LEN/BYTES_PER_WORD+1];
	for (int j = 0; j< Memory[index].DATA_LEN % BYTES_PER_WORD; j++)
	{
		uint8_t temp;
		temp = buffer.range(63,56);
		std::cout << temp;
		buffer <<= 8;
	}
	std::cout << std::endl;
}
void Mem_Parse_Set(hls::stream<Data_Word> &Data_after_CMD, Part_Word &End_word)
{
	Part_Word  Key_remained, Align_remained;
	static hls::stream<Data_Word> Key_Stream;
#pragma HLS STREAM variable=Key_Stream depth=Key_Stream_Size
	static hls::stream<Data_Word> Data_after_KEY;
#pragma HLS STREAM variable=Data_after_KEY depth=Data_Stream_Size
	static hls::stream<Data_Word> Data_after_FLAG;
#pragma HLS STREAM variable=Data_after_FLAG depth=Data_Stream_Size
	static hls::stream<Data_Word> Data_after_EXPERT;
#pragma HLS STREAM variable=Data_after_EXPERT depth=Data_Stream_Size
	static hls::stream<Data_Word> Data_after_BYTE;
#pragma HLS STREAM variable=Data_after_BYTE depth=Data_Stream_Size

	uint16_t index = Parse_Key(Data_after_CMD, End_word, Align_remained, Key_Stream, Key_remained);
	Memory[index].VALID = 1;
	alignment(Data_after_CMD, Data_after_KEY, End_word, Align_remained);
	Save_key(Memory[index],Key_Stream, Key_remained);
	int flag = Parse_Numerical_Field(Data_after_KEY, Align_remained);
	alignment(Data_after_KEY, Data_after_FLAG, End_word, Align_remained);
	int expert = Parse_Numerical_Field(Data_after_FLAG, Align_remained);
	alignment(Data_after_FLAG, Data_after_EXPERT, End_word, Align_remained);
	Memory[index].DATA_LEN = Parse_Numerical_Field(Data_after_EXPERT, Align_remained);
	alignment(Data_after_EXPERT, Data_after_BYTE, End_word, Align_remained);
	Parse_Data(Memory[index],Data_after_BYTE,End_word);

}

int Mem_Parse_Get(hls::stream<Data_Word> &Data_after_CMD, Part_Word &End_word)
{
	Part_Word  Key_remained, Align_remained;
	static hls::stream<Data_Word> Key_Stream;
#pragma HLS STREAM variable=Key_Stream depth=Key_Stream_Size
	uint16_t index = Parse_Key(Data_after_CMD, End_word, Align_remained, Key_Stream, Key_remained);
	Save_key(Memory[index],Key_Stream, Key_remained);
	return index;
}

void Add_Protocl(hls::stream<Data_Word> & Word_output, Part_Word & Left_word, enum mem_protocl Protocl)
{
	int hdr_len;
	if (Protocl == UDP_Protocl)
	{
		hdr_len = PAYLOAD_OFFSET_UDP;
	}
	for (int i = 0; i < hdr_len / BYTES_PER_WORD; i++)
	{
		Word_output.write(0);
	}
	Left_word.len = hdr_len % BYTES_PER_WORD;
	Left_word.Data = 0;

}
Data_Word Merge_Full_and_Part(Data_Word & Full_word, Part_Word & Left_word)
{
	Data_Word result;
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
		Word_output.write(Merge_Full_and_Part(Memory[index].DATA[i],Left_word));
	}
	if (remain != 0)
	{
		Part_Word DATA_word;
		DATA_word.len = remain;
		DATA_word.Data = Memory[index].DATA[count];
		Merge_Part_and_Part(Left_word, DATA_word, Word_output);
	}
}
Part_Word Generate_Word_for_Number(int number)
{
	Part_Word result;
	result.len = 0;
	do
	{
#pragma HLS pipeline
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
        Tuple_out.Hdr.Ipv4.totallen = len - ETH_HDR_LEN + 8;
        Tuple_out.Hdr.Udp.len = len - ETH_HDR_LEN - IPV4_HDR_LEN + 8;

}

uint16_t Output_packets(hls::stream<packet_interface> & Packet_output, hls::stream<Data_Word> &Word_output, Part_Word & Left_word)
{
	uint16_t count = 0;
	packet_interface Output;
	Output.Count = BYTES_PER_WORD;
	Output.Start_of_frame = 1;
	Output.Data = Word_output.read();
	Output.Error = 0;
	while(!Word_output.empty())
	{
		Output.End_of_frame = 0;
		Packet_output.write(Output);
		Output.Start_of_frame = 0;
		Output.Count = BYTES_PER_WORD;
		Output.Data = Word_output.read();
		Output.Error = 0;
		count++;
	}
	count *=8;
	if (Left_word.len == 0)
	{
		Output.End_of_frame = 1;
		Packet_output.write(Output);
	}
	else
	{
		Output.End_of_frame = 0;
		Packet_output.write(Output);
		Output.End_of_frame = 1;
		Output.Count = Left_word.len;
		Output.Data = Left_word.Data;
		Output.Error = 0;
		Output.Start_of_frame = 0;
		Packet_output.write(Output);
		count += Left_word.len;

	}
	return count;
}
void Mem_Action_Set(hls::stream<packet_interface> & Packet_output, enum mem_protocl Protocl, output_tuples & tuple_out)
{
	Part_Word Left_word;
	enum resp_index resp_word;
	static hls::stream<Data_Word> Word_output;
#pragma HLS STREAM variable=Word_output depth=Data_Stream_Size

	Add_Protocl(Word_output, Left_word, Protocl);

	resp_word = _STORED;
	Add_Resp_Word(Word_output, Left_word, resp_word);

	resp_word = _END_OF_LINE;
	Add_Resp_Word(Word_output, Left_word, resp_word);

	uint16_t packet_len = Output_packets(Packet_output, Word_output, Left_word);
	Modify_Hdr_Length(tuple_out, packet_len);
}

void Mem_Action_Get(hls::stream<packet_interface> & Packet_output, enum mem_protocl Protocl, int index, output_tuples & tuple_out)
{
	Part_Word Left_word;
	enum resp_index resp_word;
	static hls::stream<Data_Word> Word_output;
#pragma HLS STREAM variable=Word_output depth=Data_Stream_Size
	Add_Protocl(Word_output, Left_word, Protocl);
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

		Add_Numerical_Word(Word_output,Left_word, Memory[index].DATA_LEN);

		resp_word = _END_OF_LINE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		Add_Resp_Data(Word_output,Left_word, index);

		resp_word = _END_OF_LINE;
		Add_Resp_Word(Word_output, Left_word, resp_word);

		resp_word = _END;
		Add_Resp_Word(Word_output, Left_word, resp_word);

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
}

void Mem_Parser(hls::stream<packet_interface> & Packet_input, hls::stream<packet_interface> & Packet_output, output_tuples & tuple_out)
{
	Part_Word Align_remained, End_word;
	static hls::stream<Data_Word> Raw_Word;
#pragma HLS STREAM variable=Raw_Word depth=Data_Stream_Size
	static hls::stream<Data_Word> Data_after_HDR;
#pragma HLS STREAM variable=Data_after_HDR depth=Data_Stream_Size
	static hls::stream<Data_Word> Data_after_CMD;
#pragma HLS STREAM variable=Data_after_CMD depth=Data_Stream_Size
	Extract_Data(Packet_input,Raw_Word,End_word);
	enum mem_protocl Protocl;
	enum ascii_cmd Command;
	Protocl = UDP_Protocl;
	Align_remained = Parse_Internet_Hdr(Raw_Word, Protocl);
	alignment(Raw_Word,Data_after_HDR,End_word, Align_remained);
	Command = Parse_Command(Data_after_HDR, Align_remained);
	alignment(Data_after_HDR, Data_after_CMD, End_word, Align_remained);

	switch (Command)
	{
		case SET_CMD:
			Mem_Parse_Set(Data_after_CMD, End_word);
			Mem_Action_Set(Packet_output, Protocl, tuple_out);
			break;
		case GET_CMD:
			int index =	Mem_Parse_Get(Data_after_CMD, End_word);
			Mem_Action_Get(Packet_output, Protocl, index, tuple_out);
			break;
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
	Mem_Parser(Packet_input, Packet_output, tuple_out);
	Output_tuples.write(tuple_out);

	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;

}


