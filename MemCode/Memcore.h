#define REQUEST_LINE_SIZE 2000
#define MAX_DATA_SIZE 1100
#define MAX_PACKET_SIZE REQUEST_LINE_SIZE+MAX_DATA_SIZE
#define MAX_KEY_LEN 256
#define UDP_OFFSET 42
#define _STORED 0
#define _NOTFOUND 1
#define STR_STORED "STORED"
#define STR_NOTFOUND "NOT FOUND"
#define MAGIC_NUM 31
#define MAX_MEMORY_SIZE 32767
#include<stdint.h>
enum ascii_cmd {
  GET_CMD,
  SET_CMD,
  DELETE_CMD,
  UNKNOWN_CMD
};
typedef struct field_pos{
  char * f_start;
  // Need change to long f_start when chang to HLS
  int f_len;
}FIELD;

typedef struct cmd_staus{
  enum ascii_cmd CMD;
  char KEY[MAX_KEY_LEN];
  int FLAG;
  int EXPERT;
  int BYTE;
  char DATA[MAX_DATA_SIZE]; 
}CMD_STAT;

typedef struct key_data{
  char KEY[MAX_KEY_LEN];
  int KEY_LEN;
  char DATA[MAX_DATA_SIZE];
  long DATA_LEN;
  char VALID;
}CACHE;

typedef struct mem_packet{
	char data[MAX_DATA_SIZE];
	long len;
}MEM;

extern MEM packet_block;
void mem_code();
