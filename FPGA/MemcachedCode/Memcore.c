#include<stdio.h>
#include<stdint.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include"Memcore.h"

static enum ascii_cmd ascii_to_command(char in[Request_Line_Size], size_t length, char out[Request_Line_Size])
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
  char temp[Request_Line_Size];
  while (commands[x].len > 0) {
    if (length >= commands[x].len)
    {
      if (strncmp(in, commands[x].cmd, commands[x].len) == 0)
      {
        /* Potential hit */
        if (length == commands[x].len || isspace(*(in + commands[x].len)))
        {
          strncpy(out, in + commands[x].len, length-commands[x].len);
          return commands[x].cc;

        }
      }
    }
    ++x;
  }

  return UNKNOWN_CMD;
}

static int parse_ascii_key(char in[Request_Line_Size], char out[Request_Line_Size], char key[Max_Key_Len])
{
  int key_len= 0;
  /* Strip leading whitespaces */
  while (isspace(*in) || iscntrl(*in) || *in > (char)127) 
  {
    in++;
  }
  while (*(in + key_len) != '\0' && !isspace(*(in + key_len)) && !iscntrl(*(in+ key_len)))
  {
    ++key_len;
  }
  strncpy(key, in, key_len); 
  in += key_len;

  if (key_len == 0 || key_len > 240 || (*in != '\0' && *in != '\r' && iscntrl(*in)))
  {
    return 0;
  }
  strncpy(out,in,strlen(in));
  return key_len;
}
uint16_t parse_integer(char in[Request_Line_Size], char out[Request_Line_Size])
{
  char int_s[8];
  char temp_s[Request_Line_Size];
  int int_len = 0;
  while (isspace(*in) || iscntrl(*in) || *in > (char)127) 
  {
    in++;
  }
  while (*(in + int_len) != '\0' && !isspace(*(in + int_len)) && !iscntrl(*(in + int_len)))
  {
    int_len++;
  }
  strncpy(int_s, in, int_len);
  strncpy(out, in + int_len, strlen(in) - int_len);
  return atoi(int_s);
} 
void Parse_Request_Line(char *packet char s[Request_Line_Size])
{
  
}
void Mem_Parser(char *packet)
{
  /* Remove leading useless characters */
  char s[Request_Line_Size], s1[Request_Line_Size];
  Parse_Request_Line(packet, s[Request_Line_Size]);
   while (isspace(*packet) || iscntrl(*packet) || *packet > (char)127) 
  {
    packet++;
  } 
  size_t length = strlen(s);
  uint8_t command_code = ascii_to_command(s, length, s1);
  switch (command_code){
    case SET_CMD:
      memset(s,0,Request_Line_Size);
      char key[Max_Key_Len]={0};
      uint8_t key_len = parse_ascii_key(s1, s, key);
      memset(s1,0,Request_Line_Size);
      uint16_t flag = parse_integer(s,s1);
      memset(s,0,Request_Line_Size);
      uint16_t exprt = parse_integer(s1,s);
      memset(s1,0,Request_Line_Size);
      uint16_t bytes = parse_integer(s,s1);
      char data[2048];
      fgets(data, bytes+1, fp);
      //printf("Set key = %s with Data as:\n%s\n", key, data);
    case GET_CMD:
      memset(s,0,Request_Line_Size);
      char key[Max_Key_Len]={0};
      uint8_t key_len = parse_ascii_key(s1, s, key);
    case DELETE_CMD:
      memset(s,0,Request_Line_Size);
      char key[Max_Key_Len]={0};
      uint8_t key_len = parse_ascii_key(s1, s, key);
  }  
}

int main (){
  FILE *fp = fopen("input.txt","rt");

}


/* Testing
int main(){
  // Should change data format to packet_interfarce
  FILE *fp = fopen("input.txt","rt");
  char s[Request_Line_Size], s1[Request_Line_Size];
  fgets(s, Request_Line_Size, fp);
  size_t length = strlen(s);
  uint8_t command_code = ascii_to_command(s, length, s1);
  switch (command_code){

    case SET_CMD:
      memset(s,0,Request_Line_Size);
      char key[Max_Key_Len]={0};
      uint8_t key_len = parse_ascii_key(s1, s, key);
      memset(s1,0,Request_Line_Size);
      uint16_t flag = parse_integer(s,s1);
      memset(s,0,Request_Line_Size);
      uint16_t exprt = parse_integer(s1,s);
      memset(s1,0,Request_Line_Size);
      uint16_t bytes = parse_integer(s,s1);
      char data[2048];
      fgets(data, bytes+1, fp);
      //printf("Set key = %s with Data as:\n%s\n", key, data);
    case GET_CMD:
      memset(s,0,Request_Line_Size);
      char key[Max_Key_Len]={0};
      uint8_t key_len = parse_ascii_key(s1, s, key);
    case DELETE_CMD:
      memset(s,0,Request_Line_Size);
      char key[Max_Key_Len]={0};
      uint8_t key_len = parse_ascii_key(s1, s, key);
  }
  //uint32_t packet_length = atoi(s3);

  return 0;
}
*/


/* cannot use in the HLS (need test)
const char* d = " ";
char *p;
p = strtok(s,d);
printf("%s\n",p);
*/