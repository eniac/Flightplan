#include "MemHLS.h"
#include "Memcore.h"
#include <iostream>



static CACHE Memory[MAX_MEMORY_SIZE];
static CMD_STAT Command;
void Print_Command(CMD_STAT Command);
void Action_Set(int &Current_Pos, CMD_STAT & Command, Mem_sym &Packet_out, Mem_sym &Raw_Packet);
static void Collect_packets(hls::stream<packet_interface> &Packet_input, Mem_sym &Raw_Packet)
{

	bool End = false;
	Raw_Packet.len = 0;
	packet_interface Input;
	do
	{
#pragma HLS pipeline II=4
		Data_Word buffer;
		Input = Packet_input.read();
		End = Input.End_of_frame;
		buffer = Input.Data;
		for (int i = 7; i>=0; i--)
		{
			Raw_Packet.data[Raw_Packet.len + i] = buffer & 0x00000000000000ff;
			buffer >>= 8;
		}
		Raw_Packet.len += Input.Count;
	}while(!End);
	
	
}

void Forward_packet(hls::stream<packet_interface> &Packet_input, hls::stream<packet_interface> &Packet_output)
{
	packet_interface Input;
	do
	{
#pragma HLS pipeline
		Input = Packet_input.read();
		Packet_output.write(Input);
	}while(!Input.End_of_frame);
}

static enum ascii_cmd Parse_Command(int &pointer, Mem_sym & Raw_Packet)
{

	Standard_Cmd commands[NUM_OF_CMD];
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

	enum ascii_cmd result = GET_CMD;
	int offset = pointer;
	for (int i = 0; i < NUM_OF_CMD; i++)
	{
#pragma HLS unroll
		if (pointer + commands[i].len  < Raw_Packet.len)
		{
			for (int j = 0; j < 10; j++)
			{
				uint8_t testchar = Raw_Packet.data[offset + j];
				if (testchar != commands[i].cmd[j]) break;
				if (j == commands[i].len - 1)
				{
					pointer += commands[i].len;
					result = commands[i].cc;
					break;
				}
			}
		}

	}
	return result;
}

int Parse_Number(int &pointer, Mem_sym & Raw_Packet)
{
	int start = pointer;
	int number = 0;
	int factor = 1;
	if (Raw_Packet.data[pointer] !=' ')
	{
		for (int i = 0; i < 5; i++)
				{
					if(!(Raw_Packet.data[pointer] != ' ' && (Raw_Packet.data[pointer] != '\r' ||  Raw_Packet.data[pointer+1] != '\n'))) break;
					pointer++;
				}
		int len = pointer -start;
		for (int i = pointer-1; i>=	 start; i--)
		{
			number += ((((int) Raw_Packet.data[i]) - ((int) '0')) * factor);
			factor *=10;
		}
		if (Raw_Packet.data[pointer] == ' ') pointer++; else pointer+=2;
		return number;
	}
	return -1;


}
void Parse_Key(int &pointer, Mem_sym & Raw_Packet, CMD_STAT & Command)
{
	if(Raw_Packet.data[pointer]!=' ')
	{
		Command.KEY_LEN = 0;
		for (int i =0; i < MAX_KEY_LEN; i++)
		{
#pragma HLS pipeline
			if(!(Raw_Packet.data[pointer] != ' ' && (Raw_Packet.data[pointer] != '\r' ||  Raw_Packet.data[pointer+1] != '\n'))) break;
			Command.KEY[Command.KEY_LEN] = Raw_Packet.data[pointer];
			pointer++;
			Command.KEY_LEN++;
		}
		if (Raw_Packet.data[pointer] == ' ') pointer++; else pointer+=2;
		return;
	}
	Command.KEY_LEN = -1;
	return;
}

void Parse_Data(int &pointer, Mem_sym & Raw_Packet, uint8_t Data[MAX_DATA_SIZE], int Bytes)
{
	for (int i = pointer; i < pointer + Bytes; i++)
#pragma HLS pipeline
		Data[i-pointer] = Raw_Packet.data[i];

}
void Parse_Set(int &Current_Pos, Mem_sym & Raw_Packet, CMD_STAT & Command)
{
	Command.KEY_LEN = 0;
	Parse_Key(Current_Pos, Raw_Packet, Command);
	Command.EXPERT = Parse_Number(Current_Pos, Raw_Packet);
	Command.FLAG = Parse_Number(Current_Pos, Raw_Packet);
	Command.BYTE = Parse_Number(Current_Pos, Raw_Packet);
	//Parse_Data(Current_Pos, Raw_Packet, Command.DATA, Command.BYTE);
	//Need to check end of the packet
}

void Parse_Get_or_Delete(int &Current_Pos, Mem_sym & Raw_Packet, CMD_STAT & Command)
{
#pragma HLS inline
	Command.KEY_LEN = 0;
	Parse_Key(Current_Pos, Raw_Packet, Command);
	//Need to check end of the packet
}


void Mem_Parser(Mem_sym & Raw_Packet, Mem_sym & Packet_out, CMD_STAT & Command)
{
	//check UDP
	if (Raw_Packet.data[UDP_IDENTIFIER] == 0x11)
	{
		//Memcached header under UDP
		int Current_Pos = PAYLOAD_OFFSET_UDP;
		Command.CMD = Parse_Command(Current_Pos, Raw_Packet);
		if (Command.CMD == SET_CMD)
		{
			Parse_Set(Current_Pos, Raw_Packet, Command);
			Action_Set(Current_Pos, Command, Packet_out, Raw_Packet);
		}
		if (Command.CMD == GET_CMD)
		{
			Parse_Get_or_Delete(Current_Pos, Raw_Packet, Command);
		}
		if (Command.CMD == DELETE_CMD)
		{
			Parse_Get_or_Delete(Current_Pos, Raw_Packet, Command);
		}
	}
}

int lookup(CMD_STAT & Command)
{
#pragma HLS inline
        unsigned long hash = 0;
        for (int i =0; i<Command.KEY_LEN; i++)
#pragma HLS pipeline
                hash = MAGIC_NUM * hash + (int) Command.KEY[i];
        hash %= MAX_MEMORY_SIZE;

          return (int) hash;
}

void ADD_RESP_WORD(Mem_sym & Packet_out, int RESP_INDEX)
{
		Standard_Response Resp[NUM_OF_RESPONSE]={
					{STR_STORED, 6},
					{STR_VALUE, 5},
					{STR_END, 3},
					{STR_DELETED, 7},
					{STR_NOTFOUND, 8}
			};
		int offset = Packet_out.len;
        int index = RESP_INDEX;
        Packet_out.len += Resp[index].len;
        for (int i = 0; i < Resp[index].len; i++)
#pragma HLS unroll
                Packet_out.data[offset+i] = (Resp[index].line)[i];
}

void Add_Udp_MemHdr(uint8_t hdr[MEMCACHED_UDP_HEADER], Mem_sym & Packet_out)
{
#pragma HLS inline
	for (int i = 0; i < MEMCACHED_UDP_HEADER; i++)
#pragma HLS unroll
		Packet_out.data[i + Packet_out.len] = hdr[i];
	Packet_out.len += MEMCACHED_UDP_HEADER;

}
void Add_Space(Mem_sym &Packet_out)
{
	Packet_out.data[Packet_out.len++] = 32;
}
void Add_End(Mem_sym &Packet_out)
{
	Packet_out.data[Packet_out.len ++] = '\r';
	Packet_out.data[Packet_out.len ++] = '\n';
}
void Add_Numerical_Field(Mem_sym &Packet_out, int num)
{
    int offset = Packet_out.len;
    uint8_t temp[10];
    int len = 0;
    do
    {
            temp[len] =(uint8_t) (num % 10 + (int) '0');
            num /= 10;
            len++;
    }while(num>0);
    Packet_out.len = offset + len;
    for (int i = 0; i < len; i++)
#pragma HLS unroll
            Packet_out.data[Packet_out.len-i-1] = temp[i];

}

void Add_Key_Field(Mem_sym & Packet_out, int key_len, uint8_t key[MAX_KEY_LEN])
{
	for (int i = 0; i < key_len; i++)
#pragma HLS unroll
		Packet_out.data[Packet_out.len + i] = key[i];
	Packet_out.len += key_len;
}

void Add_Data_Field(Mem_sym & Packet_out, long data_len, uint8_t data[MAX_DATA_SIZE])
{
	for (int i = 0; i < data_len; i++)
#pragma HLS pipeline
		Packet_out.data[Packet_out.len + i] = data[i];
	Packet_out.len += data_len;
}
void Switch_Address(input_tuples & Tuple_in, output_tuples & Tuple_out)
{
	Tuple_out.Hdr.Eth.Src = Tuple_in.Hdr.Eth.Dst;
	Tuple_out.Hdr.Eth.Dst = Tuple_in.Hdr.Eth.Src;
	Tuple_out.Hdr.Ipv4.dstAddr = Tuple_in.Hdr.Ipv4.srcAddr;
	Tuple_out.Hdr.Ipv4.srcAddr = Tuple_in.Hdr.Ipv4.dstAddr;
	Tuple_out.Hdr.Udp.dport = Tuple_in.Hdr.Udp.sport;
	Tuple_out.Hdr.Udp.sport = Tuple_in.Hdr.Udp.dport;
}
void Modify_Hdr_Length(output_tuples & Tuple_out, uint16_t len)
{
	Tuple_out.Hdr.Ipv4.totallen = len - ETH_HDR_LEN;
	Tuple_out.Hdr.Udp.len = len - ETH_HDR_LEN - IPV4_HDR_LEN;

}
void Action_Set(int &Current_Pos, CMD_STAT & Command, Mem_sym &Packet_out, Mem_sym &Raw_Packet)
{
#pragma HLS inline
	uint8_t hdr[8];
	hdr[0]= 0;
	hdr[1]= 1;
	hdr[2]= 2;
	hdr[3]= 3;
	hdr[4]= 4;
	hdr[5]= 5;
	hdr[6]= 6;
	hdr[7]= 7;
	int mem_index = lookup(Command);
	Memory[mem_index].VALID = 1;
	Parse_Data(Current_Pos, Raw_Packet, Memory[mem_index].DATA, Command.BYTE);
	for (int i = 0; i < Command.KEY_LEN; i++)
#pragma HLS pipeline
		Memory[mem_index].KEY[i] = Command.KEY[i];
	Memory[mem_index].DATA_LEN = Command.BYTE;
	Memory[mem_index].KEY_LEN = Command.KEY_LEN;
	Packet_out.len = PAYLOAD_OFFSET_UDP - MEMCACHED_UDP_HEADER;
	Add_Udp_MemHdr(hdr, Packet_out);
	ADD_RESP_WORD(Packet_out, _STORED);
	Add_End(Packet_out);

}

void Action_Get(CMD_STAT & Command, Mem_sym &Packet_out)
{
	int mem_index = lookup(Command);
	if (Memory[mem_index].VALID)
	{
		Packet_out.len = PAYLOAD_OFFSET_UDP - MEMCACHED_UDP_HEADER;
		uint8_t hdr[8] = {1};
		//Add_Udp_MemHdr(hdr, Packet_out);
		//ADD_RESP_WORD(Packet_out, _VALUE);
		Add_Space(Packet_out);
		Add_Key_Field(Packet_out, Memory[mem_index].KEY_LEN, Memory[mem_index].KEY);
		Add_Space(Packet_out);
		Add_Numerical_Field(Packet_out, 0);
		Add_Space(Packet_out);
		Add_Numerical_Field(Packet_out, Memory[mem_index].DATA_LEN);
		Add_End(Packet_out);
		Add_Data_Field(Packet_out, Memory[mem_index].DATA_LEN, Memory[mem_index].DATA);
		Add_End(Packet_out);
		//ADD_RESP_WORD(Packet_out, _END);
		Add_End(Packet_out);
	}
}
void Action_Delete(CMD_STAT & Command, Mem_sym &Packet_out)
{
	int mem_index = lookup(Command);
	if (Memory[mem_index].VALID)
	{
		Packet_out.len = 0;
		uint8_t hdr[8] = {1};
		Add_Udp_MemHdr(hdr, Packet_out);
		//ADD_RESP_WORD(Packet_out, _DELETED);
	}
}
void Mem_Action(CMD_STAT & Command, Mem_sym &Packet_out)
{
	if (Command.CMD == SET_CMD)
	{
		//Action_Set(Command, Packet_out);
	}
	if (Command.CMD == GET_CMD)
	{
		Action_Get(Command, Packet_out);

	}
	if (Command.CMD == DELETE_CMD)
	{
		Action_Delete(Command, Packet_out);
	}
}
void Output_Packets(hls::stream<packet_interface> & Packet_output, Mem_sym & Packet_out)
{
#pragma HLS inline
	unsigned Words_per_packet = DIVIDE_AND_ROUNDUP(Packet_out.len, BYTES_PER_WORD);
    for (int i = 0; i < Words_per_packet; i++)
    {
#pragma HLS pipeline II=1
            ap_uint<MEM_AXI_BUS_WIDTH> WORD = 0;
            for (int j = 0; j < BYTES_PER_WORD; j++)
            {
                    WORD <<= 8;
                    unsigned Offset = BYTES_PER_WORD * i + j;
                    if (Offset < Packet_out.len)
                            WORD |= Packet_out.data[Offset];
            }

            bool End = i == Words_per_packet - 1;
            packet_interface Input;
            Input.Data = WORD;
            Input.Start_of_frame = i == 0;
            Input.End_of_frame = End;
            Input.Count = Packet_out.len % BYTES_PER_WORD;
            if (Input.Count == 0 || !End)
                    Input.Count = 8;
            Input.Error = 0;
            Packet_output.write(Input);
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
	uint8_t Raw_Data[MAX_DATA_SIZE];
	Mem_sym Raw_Packet, Packet_out;
	Collect_packets(Packet_input, Raw_Packet);
	input_tuples Tuple_in;
	output_tuples Tuple_out;
	Tuple_in = Input_tuples.read();
	Tuple_out.Hdr = Tuple_in.Hdr;
	//CMD_STAT Command;
	Mem_Parser(Raw_Packet, Packet_out, Command);
	//for (int i =0; i< Raw_Packet.len; i++)
	//	std::cout << Raw_Packet.data[i];
	//Print_Command(Command);
	if (Command.CMD == UNKNOWN_CMD)
	//Output Interface test Only write one byte
	{
		//Output_Packets(Packet_output, Raw_Packet);
	}

	else
	{
		//Output_Packets(Packet_output,Raw_Packet);
		Mem_Action(Command,Packet_out);
		Switch_Address(Tuple_in, Tuple_out);
		Modify_Hdr_Length(Tuple_out, Packet_out.len);
		Output_Packets(Packet_output, Packet_out);
		Output_tuples.write(Tuple_out);
	}
	//Print_Command(Command);
	std::cout << std::endl;
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
	/*Forward_packet(Packet_input,Packet_output);
	input_tuples Tuple_in;
	output_tuples Tuple_out;
	Tuple_in = Input_tuples.read();
	Tuple_out.Hdr = Tuple_in.Hdr;
	Output_tuples.write(Tuple_out);
	*/
}

void Print_Command(CMD_STAT Command)
{
	std::cout << "The Command is:" << Command.CMD << std::endl;
	std::cout << "The KEY is " << Command.KEY << " with length: " << Command.KEY_LEN << std::endl;
	std::cout << "The "<< Command.BYTE << " Bytes Data are: "<< std::endl << Command.DATA;
}
