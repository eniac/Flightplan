#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include"Memcore.h"

struct response{
	char* line;
	int len;
}RESPONSE[]={
	{.line = "STORED", .len = 6},
	{.line = "NOT FOUND", .len = 9}
};
MEM packet_block;

static CACHE Memory[MAX_MEMORY_SIZE];
void print_command(CMD_STAT command); 
void print_memory(long index);
int rm_space(char in[MAX_PACKET_SIZE]);
int lookup(char KEY[MAX_KEY_LEN], int KEY_LEN);

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
  if ((*(in))!= ' ')  printf("No Spcae Found"); 
  in++;
  while (*(in + len) != '\0' && !isspace(*(in + len)) && (*(in+len)!='\r'))
  {
    ++len;
  }

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
  printf("PASS1\n");
  switch (commands.CMD){
    case(SET_CMD):

      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);
      commands.KEY[KEY.f_len] = 0;
      parse_next(KEY.f_start+KEY.f_len, &FLAG);
      commands.FLAG = atoi(strncpy(temp,FLAG.f_start,FLAG.f_len));
  
      parse_next(FLAG.f_start+FLAG.f_len, &EXPERT);
      memset(temp,0,8);	
      commands.EXPERT = atoi(strncpy(temp, EXPERT.f_start, EXPERT.f_len));

      parse_next(EXPERT.f_start+EXPERT.f_len, &BYTE);
      memset(temp,0,8);
      commands.BYTE = atoi(strncpy(temp,BYTE.f_start,BYTE.f_len));

      parse_data(BYTE.f_start+BYTE.f_len,commands.BYTE, &DATA);
      strncpy(commands.DATA,DATA.f_start,commands.BYTE);
      commands.DATA[commands.BYTE] = 0;

      mem_index = lookup(commands.KEY, KEY.f_len);  
      mem_index = 1;    
      printf("mem_index is %d\n", mem_index);
      Memory[mem_index].KEY_LEN = KEY.f_len;
      strncpy(Memory[mem_index].KEY,commands.KEY, Memory[mem_index].KEY_LEN);
      Memory[mem_index].DATA_LEN = commands.BYTE;
      strncpy(Memory[mem_index].DATA, commands.DATA, Memory[mem_index].DATA_LEN); 
      Memory[mem_index].VALID = 1;
      // backward packet 
      packet_block.len = UDP_OFFSET + RESPONSE[_STORED].len;
      for (int i = 0; i < RESPONSE[_STORED].len; i++)
	packet_block.data[UDP_OFFSET+i] = (RESPONSE[_STORED].line)[i];      
      
      // forward packet
      break;

    case(GET_CMD):      
      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);
      printf("The mem_index\n");
      mem_index = lookup(commands.KEY,KEY.f_len);
      printf("%d\n", mem_index);
      if (Memory[mem_index].VALID == 1)
      { 
	printf("FOUND!\n");
	packet_block.len = UDP_OFFSET + Memory[mem_index].DATA_LEN;
        for (int i = 0; i < packet_block.len; i++)
	  packet_block.data[UDP_OFFSET+i] = Memory[mem_index].DATA[i];
      }
      else {
	packet_block.len = UDP_OFFSET + RESPONSE[_NOTFOUND].len;
        for (int i = 0; i < RESPONSE[_NOTFOUND].len; i++)
          packet_block.data[UDP_OFFSET+i] = (RESPONSE[_NOTFOUND].line)[i];      
      
      } 	
      break;
    case(DELETE_CMD):      
      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);	
      mem_index = lookup(commands.KEY, KEY.f_len);
      if (Memory[mem_index].VALID == 1)
      {
	
      }
      else 
      {
	Memory[mem_index].VALID == 0;
      }
      break;
   }
   print_command(commands);
   print_memory(mem_index);
}
void mem_code(){
	printf("<<<<<<<<<<<<<<<<<<<<<<<<<<<Inside the mem_core<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
	printf("The Original input is:\n");
	for (int i = UDP_OFFSET; i< 1155; i++) 
		printf("%c",packet_block.data[i]);
  	int count = rm_space(packet_block.data+UDP_OFFSET); 
	Mem_Parser(packet_block.data+UDP_OFFSET+count);
	
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
        int counter = 0;
	while ((unsigned int) (*in) != 103 && (unsigned int) (*in) != 115) 
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
  return (int) hash; 
}

