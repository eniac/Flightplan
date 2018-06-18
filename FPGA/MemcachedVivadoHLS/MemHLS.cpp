#include "MemHLS.h"
#include "Memcore.h"
#include <iostream>



static CACHE Memory[MAX_MEMORY_SIZE];

void Print_Command(CMD_STAT Command);
static void Collect_packets(hls::stream<packet_interface> &Packet_input, Mem_sym &Raw_Packet)
{
	#pragma HLS inline
	bool End = false;
	Raw_Packet.len = 0;
	packet_interface Input;
	do 
	{	
		Data_Word buffer;
		Input = Packet_input.read();
		End = Input.End_of_frame;
		buffer = Input.Data;
		for (int i = 0; i< Input.Count; i++)
		{
			Raw_Packet.data[Raw_Packet.len + i] = (buffer >> 56) & 0xff;
			buffer <<= 8;
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
	Standard_Cmd commands[NUM_OF_CMD + 1]={{"get ", 4, GET_CMD},
							   {"set ", 4, SET_CMD},
							   {"delete ", 7, DELETE_CMD},
							   {"VALUE ", 6, VALUE_RESP},
							   {"DELETED ", 8, DELETED_RESP},
						       {"", 0, UNKNOWN_CMD}};
	for (int i = 0; i < NUM_OF_CMD; i++)
	{
		if (pointer + commands[i].len  < Raw_Packet.len)
		{
			for (int j = 0; j < commands[i].len; j++)
			{
				if (Raw_Packet.data[pointer + j] != commands[i].cmd[j]) break;
				if (j == commands[i].len - 1)
				{
					pointer += commands[i].len;
					return commands[i].cc;
				}
			}
		}

	}
	return UNKNOWN_CMD;
}

int Parse_Number(int &pointer, Mem_sym & Raw_Packet)
{
	int start = pointer;
	int number = 0;
	int factor = 1;
	if (Raw_Packet.data[pointer] !=' ')
	{
		while (Raw_Packet.data[pointer] != ' ' && (Raw_Packet.data[pointer] != '\r' ||  Raw_Packet.data[pointer+1] != '\n'))
				{
					pointer++;
				}
		int len = pointer -start;
		for (int i = pointer-1; i>=	 start; i--)
		{
#pragma HLS pipeline
			number += ((((int) Raw_Packet.data[i]) - ((int) '0')) * factor);
			factor *=10;
		}
		if (Raw_Packet.data[pointer] == ' ') pointer++; else pointer+=2;
		return number;
	}
	return -1;


}
void Parse_Key(int &pointer, Mem_sym & Raw_Packet, uint8_t Key[MAX_KEY_LEN], int & key_len)
{
	if(Raw_Packet.data[pointer]!=' ')
	{
		key_len = 0;
		while (Raw_Packet.data[pointer] != ' ' && (Raw_Packet.data[pointer] != '\r' ||  Raw_Packet.data[pointer+1] != '\n'))
		{
			Key[key_len] = Raw_Packet.data[pointer];
			pointer++;
			key_len++;
		}
		if (Raw_Packet.data[pointer] == ' ') pointer++; else pointer+=2;
		return;
	}
	key_len = -1;
	return;
}

void Parse_Data(int &pointer, Mem_sym & Raw_Packet, uint8_t Data[MAX_KEY_LEN], int Bytes)
{
	for (int i = pointer; i < pointer + Bytes; i++)
		Data[i-pointer] = Raw_Packet.data[i];

}
void Parse_Set(int &Current_Pos, Mem_sym & Raw_Packet, CMD_STAT & Command)
{
#pragma HLS inline
	Command.KEY_LEN = 0;
	Parse_Key(Current_Pos, Raw_Packet, Command.KEY, Command.KEY_LEN);
	Command.EXPERT = Parse_Number(Current_Pos, Raw_Packet);
	Command.FLAG = Parse_Number(Current_Pos, Raw_Packet);
	Command.BYTE = Parse_Number(Current_Pos, Raw_Packet);
	Parse_Data(Current_Pos, Raw_Packet, Command.DATA, Command.BYTE);
	//Need to check end of the packet
}

void Parse_Get_or_Delete(int &Current_Pos, Mem_sym & Raw_Packet, CMD_STAT & Command)
{
#pragma HLS inline
	Command.KEY_LEN = 0;
	Parse_Key(Current_Pos, Raw_Packet, Command.KEY, Command.KEY_LEN);
	//Need to check end of the packet
}


void Mem_Parser(Mem_sym & Raw_Packet, CMD_STAT & Command)
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

int lookup(uint8_t KEY[MAX_KEY_LEN], int KEY_LEN)
{
        unsigned long hash = 0;
        for (int i =0; i<KEY_LEN; i++)
#pragma HLS unroll
                hash = MAGIC_NUM * hash + (int) KEY[i];
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
                Packet_out.data[offset+i] = (Resp[index].line)[i];
}

void Add_Udp_MemHdr(uint8_t hdr[MEMCACHED_UDP_HEADER], Mem_sym & Packet_out)
{
	for (int i = 0; i < MEMCACHED_UDP_HEADER; i++)
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
            Packet_out.data[Packet_out.len-i-1] = temp[i];

}

void Add_Key_Field(Mem_sym & Packet_out, int key_len, uint8_t key[MAX_KEY_LEN])
{
	for (int i = 0; i < key_len; i++)
		Packet_out.data[Packet_out.len + i] = key[i];
	Packet_out.len += key_len;
}

void Add_Data_Field(Mem_sym & Packet_out, long data_len, uint8_t data[MAX_DATA_SIZE])
{
	for (int i = 0; i < data_len; i++)
		Packet_out.data[Packet_out.len + i] = data[i];
	Packet_out.len += data_len;
	for (int i = 0; i < data_len; i++)
		std::cout << data[i];
	std::cout << std::endl;
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
void Action_Set(CMD_STAT Command, Mem_sym &Packet_out)
{
	int mem_index = lookup(Command.KEY, Command.KEY_LEN);
	Memory[mem_index].VALID = 1;
	for (int i = 0; i < Command.BYTE; i++)
#pragma HLS unroll
		Memory[mem_index].DATA[i] = Command.DATA[i];
#pragma HLS unroll
	for (int i = 0; i < Command.KEY_LEN; i++)
		Memory[mem_index].KEY[i] = Command.KEY[i];
	Memory[mem_index].DATA_LEN = Command.BYTE;
	Memory[mem_index].KEY_LEN = Command.KEY_LEN;
	Packet_out.len = PAYLOAD_OFFSET_UDP - MEMCACHED_UDP_HEADER;
	uint8_t hdr[8] = {1};
	Add_Udp_MemHdr(hdr, Packet_out);
	ADD_RESP_WORD(Packet_out, _STORED);
	Add_End(Packet_out);

}

void Action_Get(CMD_STAT & Command, Mem_sym &Packet_out)
{
	int mem_index = lookup(Command.KEY, Command.KEY_LEN);
	if (Memory[mem_index].VALID)
	{
		Packet_out.len = PAYLOAD_OFFSET_UDP - MEMCACHED_UDP_HEADER;
		uint8_t hdr[8] = {1};
		Add_Udp_MemHdr(hdr, Packet_out);
		ADD_RESP_WORD(Packet_out, _VALUE);
		Add_Space(Packet_out);
		Add_Key_Field(Packet_out, Memory[mem_index].KEY_LEN, Memory[mem_index].KEY);
		Add_Space(Packet_out);
		Add_Numerical_Field(Packet_out, 0);
		Add_Space(Packet_out);
		Add_Numerical_Field(Packet_out, Memory[mem_index].DATA_LEN);
		Add_End(Packet_out);
		Add_Data_Field(Packet_out, Memory[mem_index].DATA_LEN, Memory[mem_index].DATA);
		Add_End(Packet_out);
		ADD_RESP_WORD(Packet_out, _END);
		Add_End(Packet_out);
	}
}
void Action_Delete(CMD_STAT & Command, Mem_sym &Packet_out)
{
	int mem_index = lookup(Command.KEY, Command.KEY_LEN);
	if (Memory[mem_index].VALID)
	{
		Packet_out.len = 0;
		uint8_t hdr[8] = {1};
		Add_Udp_MemHdr(hdr, Packet_out);
		ADD_RESP_WORD(Packet_out, _DELETED);
	}
}
void Mem_Action(CMD_STAT Command, Mem_sym &Packet_out)
{
	if (Command.CMD == SET_CMD)
	{
		Action_Set(Command, Packet_out);
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

    unsigned Words_per_packet = DIVIDE_AND_ROUNDUP(Packet_out.len, BYTES_PER_WORD);
    for (int i = 0; i < Words_per_packet; i++)
    {
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

	CMD_STAT Command;
	Mem_Parser(Raw_Packet, Command);
	if (Command.CMD == UNKNOWN_CMD)
	//Output Interface test Only write one byte
	{
		packet_interface Temp_output;
		Temp_output.Count = 8;
		Temp_output.Data = 0x12345;
		Temp_output.End_of_frame = 1;
		Temp_output.Start_of_frame = 1;
		Temp_output.Error = 0;
		Packet_output.write(Temp_output);
	}

	else
	{	
		Mem_Action(Command,Packet_out);
		Switch_Address(Tuple_in, Tuple_out);
		Modify_Hdr_Length(Tuple_out, Packet_out.len);
		Output_Packets(Packet_output, Packet_out);
		Output_tuples.write(Tuple_out);
	}
	//Print_Command(Command);
	std::cout << std::endl;
	std::cout << "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside MemCore<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " << std::endl;
}

void Print_Command(CMD_STAT Command)
{
	std::cout << "The Command is:" << Command.CMD << std::endl;
	std::cout << "The KEY is " << Command.KEY << " with length: " << Command.KEY_LEN << std::endl;
	std::cout << "The "<< Command.BYTE << " Bytes Data are: "<< std::endl << Command.DATA;
}
