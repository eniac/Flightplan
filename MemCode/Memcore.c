#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include"Memcore.h"

void test(CMD_STAT command);
static enum ascii_cmd ascii_to_command(char in[MAX_PACKET_SIZE], size_t length, FIELD* CMD)
{
  struct {
      const char *cmd;
      size_t len;
      enum ascii_cmd cc;
    } commands[]= {
      { .cmd= "get", .len= 3, .cc= GET_CMD },
      { .cmd= "gets", .len= 4, .cc= GETS_CMD },
      { .cmd= "set", .len= 3, .cc= SET_CMD },
      { .cmd= "add", .len= 3, .cc= ADD_CMD },
      { .cmd= "replace", .len= 7, .cc= REPLACE_CMD },
      { .cmd= "cas", .len= 3, .cc= CAS_CMD },
      { .cmd= "append", .len= 6, .cc= APPEND_CMD },
      { .cmd= "prepend", .len= 7, .cc= PREPEND_CMD },
      { .cmd= "delete_object", .len= 6, .cc= DELETE_CMD },
      { .cmd= "incr", .len= 4, .cc= INCR_CMD },
      { .cmd= "decr", .len= 4, .cc= DECR_CMD },
      { .cmd= "stats", .len= 5, .cc= STATS_CMD },
      { .cmd= "flush_all", .len= 9, .cc= FLUSH_ALL_CMD },
      { .cmd= "version", .len= 7, .cc= VERSION_CMD },
      { .cmd= "quit", .len= 4, .cc= QUIT_CMD },
      { .cmd= "verbosity", .len= 9, .cc= VERBOSITY_CMD },
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
  while (isspace(*in) || iscntrl(*in) || *in > (char)127) 
  {
    in++;
  }
  while (*(in + len) != '\0' && !isspace(*(in + len)) && !iscntrl(*(in+ len)))
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

  /* Strip leading whitespaces */
  while (isspace(*in) || iscntrl(*in) || *in > (char)127) 
  {
    in++;
  }
  // Should check whether the data are lost
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
  commands.CMD = ascii_to_command(s, length, &CMD);
  switch (commands.CMD){
    case(SET_CMD):

      parse_next(CMD.f_start+CMD.f_len,&KEY);
      strncpy(commands.KEY,KEY.f_start, KEY.f_len);

      parse_next(KEY.f_start+KEY.f_len, &FLAG);
      commands.FLAG = atoi(strncpy(temp,FLAG.f_start,FLAG.f_len));
  
      parse_next(FLAG.f_start+FLAG.f_len, &EXPERT);
      memset(temp,0,8);	
      commands.EXPERT = atoi(strncpy(temp, EXPERT.f_start, EXPERT.f_len));

      parse_next(EXPERT.f_start+EXPERT.f_len, &BYTE);
      memset(temp,0,8);
      commands.BYTE = atoi(strncpy(temp,BYTE.f_start,BYTE.f_len));

      parse_data(BYTE.f_start+BYTE.f_len,commands.BYTE, &DATA);
      strncpy(commands.DATA,DATA.f_start,DATA.f_len);	
  }
  test(commands);
}

int main(){
  // Should change data format to packet_interfarce
  FILE *fp = fopen("input.txt","rt");
  char s[MAX_DATA_SIZE];
  fseek(fp,0L,SEEK_END);
  size_t filesize = ftell(fp);
  fseek(fp,0L,SEEK_SET);
  fread(s, 1, filesize,fp);
  printf("%s\n",s);  
  Mem_Parser(s); 
  return 0;
}
void test(CMD_STAT command){
  switch (command.CMD){
    case(SET_CMD):
      printf("SET:\n");
      printf("The KEY is: %s\n",command.KEY); 
      printf("The DATA is:\n%s\n",command.DATA);
 }
}



