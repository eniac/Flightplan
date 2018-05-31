#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include"Memcore.h"

struct response{
	char* line;
	int len;
}RESPONSE[]={
	{.line = STR_STORED, .len = strlen(STR_STORED)},
	{.line = STR_VALUE, .len = strlen(STR_VALUE)},
	{.line = STR_END, .len = strlen(STR_END)},
	{.line = STR_DELETED, .len = strlen(STR_DELETED)},
	{.line = STR_NOTFOUND, .len = strlen(STR_NOTFOUND)}
};
MEM packet_block;

static CACHE Memory[MAX_MEMORY_SIZE];
void print_command(CMD_STAT command); 
void print_memory(long index);
int rm_space(char in[MAX_PACKET_SIZE]);
int lookup(char KEY[MAX_KEY_LEN], int KEY_LEN);
void ADD_RESP_WORD(int PACKET_OFFSET, int RESP_INDEX);
void ADD_NUM_FIELD(int PACKET_OFFSET, int NUM);

static enum ascii_cmd ascii_to_command(char in[MAX_PACKET_SIZE], size_t length, FIELD* CMD)
{
    struct {
      const char *cmd;
      size_t len;
      enum ascii_cmd cc;
    } commands[]= {
      { .cmd= "get", .len= 3, .cc= GET_CMD },
      { .cmd= "set", .len= 3, .cc= SET_CMD },
      { .cmd= "delete", .len= 6, .cc= DELETE_CMD },
      { .cmd = "VALUE", .len= 5, .cc= VALUE_RESP },
      { .cmd = "DELETED", .len = 7, .cc = DELETED_RESP},
      { .cmd= NULL, .len= 0, .cc= UNKNOWN_CMD }};  
  int x= 0;
  while (commands[x].len > 0) {
    if (length >= commands[x].len)
    {
      if (strncmp(in, commands[x].cmd, commands[x].len) == 0)
      {
        /* Potential hit */
        if (length == commands[x].len || isspace(*(in + commands[x].len)))
        {
          CMD->f_start = in;
	  CMD->f_len = commands[x].len;
	  return commands[x].cc;

        }
      }
    }
    ++x;
  }

  return UNKNOWN_CMD;
}

static int parse_next(char in[MAX_PACKET_SIZE], FIELD* NEXT)
{
	int len= 0;
	/* Strip leading whitespaces */
	if ((*(in))!= ' ')  printf("No Space Found"); 
	in++;
	while (*(in + len) != '\0' && !isspace(*(in + len)) && (*(in+len)!='\r'))
		++len;
	NEXT->f_start = in;
	NEXT->f_len = len; 
	if (!len) return 0;
	return 1;
}

static int parse_data(char in[MAX_PACKET_SIZE], int len, FIELD* NEXT)
{
  // Check /r/n
  if ((*(in)) != '\r' || (*(in+1)) != '\n')
   printf("Request Line should end with \\r\\n");
  in +=2;
  NEXT->f_start = in;
  NEXT->f_len = len;  
  
  return 1;
}
void Mem_Parser(char s[MAX_DATA_SIZE])
{
  size_t length = strlen(s);
  FIELD CMD,KEY,FLAG,EXPERT,BYTE,DATA;
  CMD_STAT commands;
  char temp[8];
  int mem_index = -1; 
  commands.CMD = ascii_to_command(s, length, &CMD);
  switch (commands.CMD){
    case(SET_CMD):

      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);
      commands.KEY[KEY.f_len] = 0;
      parse_next(KEY.f_start+KEY.f_len, &FLAG);
      mem_index = lookup(commands.KEY, KEY.f_len); 
      commands.FLAG = atoi(strncpy(temp,FLAG.f_start,FLAG.f_len));
  
      parse_next(FLAG.f_start+FLAG.f_len, &EXPERT);
      memset(temp,0,8);	
      commands.EXPERT = atoi(strncpy(temp, EXPERT.f_start, EXPERT.f_len));

      parse_next(EXPERT.f_start+EXPERT.f_len, &BYTE);
      memset(temp,0,8);
      commands.BYTE = atoi(strncpy(temp,BYTE.f_start,BYTE.f_len));

      parse_data(BYTE.f_start+BYTE.f_len,commands.BYTE, &DATA);
      strncpy(commands.DATA,DATA.f_start,commands.BYTE);

      Memory[mem_index].KEY_LEN = KEY.f_len;
      strncpy(Memory[mem_index].KEY,commands.KEY, Memory[mem_index].KEY_LEN);
      Memory[mem_index].DATA_LEN = commands.BYTE;
      strncpy(Memory[mem_index].DATA, commands.DATA, Memory[mem_index].DATA_LEN); 
      Memory[mem_index].VALID = 1;
      // backward packet 
      packet_block.dir = 0;
      packet_block.len = PAYLOAD_OFFSET_UDP;
      ADD_RESP_WORD(packet_block.len, _STORED);
      // forward packet
      // packet_block.dir = 1;
      break;

    case(GET_CMD):      
      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);
      mem_index = lookup(commands.KEY,KEY.f_len);
      if (Memory[mem_index].VALID == 1)
      { 
	packet_block.dir = 0;
	packet_block.len = PAYLOAD_OFFSET_UDP;
	print_memory(mem_index);	
	//ADD VALUE WORD
	ADD_RESP_WORD(packet_block.len, _VALUE);
	//ADD KEY
	for (int i = 0; i < Memory[mem_index].KEY_LEN; i++)
		packet_block.data[packet_block.len+i] = Memory[mem_index].KEY[i];
	packet_block.len += Memory[mem_index].KEY_LEN;
	packet_block.data[packet_block.len] = 32;
	packet_block.len++;
	
	//ADD FLAG and BYTES
	ADD_NUM_FIELD(packet_block.len, 0);
	ADD_NUM_FIELD(packet_block.len, Memory[mem_index].DATA_LEN);
	
	// ADD DATA
        for (int i = 0; i < Memory[mem_index].DATA_LEN; i++)
	{
		packet_block.data[packet_block.len+i] = Memory[mem_index].DATA[i];
		printf("%c",Memory[mem_index].DATA[i]);
	}
	packet_block.len += Memory[mem_index].DATA_LEN;
	packet_block.data[packet_block.len] = 13;
	packet_block.len++;
	packet_block.data[packet_block.len] = 10;
	packet_block.len++;
	
	//ADD END WORD
	ADD_RESP_WORD(packet_block.len, _END);
      }
      else {
	//packet_block.dir = 1;
      } 	
      break;
    case(DELETE_CMD):      
      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);	
      mem_index = lookup(commands.KEY, KEY.f_len);
      if (Memory[mem_index].VALID == 1)
      {
	Memory[mem_index].VALID = 0;
      }
      //Send to Server
    case(VALUE_RESP):
	//If the packet from server: ignored 
	//else RESPONSE ERROR
      break;
    case(DELETED_RESP):
	//If the packet from server: ignored 
	//else RESPONSE ERROR
	break;
   }
}
void mem_code(){
	printf("<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside the mem_core<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
	//printf("The Original Input is:\n");
	//for (int i = 0;  i< 1155; i++)
	//	printf("%c", packet_block.data[i]);		
  	int count = rm_space(packet_block.data+PAYLOAD_OFFSET_UDP); 
	Mem_Parser(packet_block.data+PAYLOAD_OFFSET_UDP+count);
	uint16_t IPV4_LEN = packet_block.len - ETH_OFFSET;
	packet_block.data[16] =	0xff;
	packet_block.data[17] = 0xaf;
	printf("<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside the mem_core<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
}
void print_command(CMD_STAT command){
  switch (command.CMD){
    case(SET_CMD):
      printf("SET:\n");
      printf("The KEY is: %s\n",command.KEY); 
      printf("The DATA is:\n%s\n",command.DATA);
      printf("The length is:%d\n",command.BYTE);
      break;
    case(GET_CMD):
      printf("GET:\n");
      printf("The KEY is: %s\n",command.KEY); 
      break;
    case(DELETE_CMD):
      printf("DELETE:\n");
      printf("The KEY is: %s\n",command.KEY); 
      break;     
 }
}

void print_memory(long index)
{
  printf("The %ld Memory slot:\n",index);
  printf("The KEY with length %d is\n%s\n",Memory[index].KEY_LEN, Memory[index].KEY);
  printf("The DATA with length %ld is\n%s\n", Memory[index].DATA_LEN, Memory[index].DATA);
}

int rm_space(char in[MAX_PACKET_SIZE])
{       
	//There are some meaningless bytes before the real commands. 
        int counter = 0;
	while ((unsigned int) (*in) != 103 && (unsigned int) (*in) != 115 && (*in) !='V') 
  	{
    		in++;
		counter++;
  	}
        return counter;
}
/*int main(){
  // Should change data format to packet_interfarce
  FILE *fp = fopen("input.txt","rt");
  char s[MAX_DATA_SIZE];
  fseek(fp,0L,SEEK_END);
  size_t filesize = ftell(fp);
  fseek(fp,0L,SEEK_SET);
  fread(s, 1, filesize,fp);
  Mem_Parser(s);
   
  return 0;
}*/
int lookup(char KEY[MAX_KEY_LEN], int KEY_LEN)
{
	unsigned long hash = 0;
	for (int i =0; i<KEY_LEN; i++)
		hash = MAGIC_NUM * hash + (int) KEY[i];
	hash %= MAX_MEMORY_SIZE;
	if (hash < 0) 
	{
		printf("ERROR IN HASH FUNCTION");
		exit(0);
 	}
	  return (int) hash; 
}

void ADD_RESP_WORD(int PACKET_OFFSET, int RESP_INDEX)
{       
	int offset = PACKET_OFFSET;
	int index = RESP_INDEX;
	packet_block.len = offset + RESPONSE[index].len;
	for (int i = 0; i < RESPONSE[index].len; i++)
		packet_block.data[offset+i] = (RESPONSE[index].line)[i]; 
	  
}

void ADD_NUM_FIELD(int PACKET_OFFSET, int NUM)
{	
	int offset = PACKET_OFFSET;
	char temp[10];
	int len = 0;
	temp[len] = 32; // ADD Space
	len++;
	do
	{
		temp[len] =(char) (NUM % 10 + (int) '0');
		NUM /= 10;
		len++;
	}while(NUM>0); 
	packet_block.len = offset + len;
	for (int i = 0; i < len; i++)
		packet_block.data[packet_block.len-i-1] = temp[i];
	
}

