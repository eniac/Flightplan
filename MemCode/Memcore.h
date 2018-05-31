//Assumptions
#define REQUEST_LINE_SIZE 2000
#define MAX_DATA_SIZE 2000 
#define MAX_PACKET_SIZE REQUEST_LINE_SIZE+MAX_DATA_SIZE
#define MAX_KEY_LEN 256
#define PAYLOAD_OFFSET_UDP 42 //Payload location under UDP 
#define ETH_OFFSET 14
#define IPV4_OFFSET 20
#define MAX_MEMORY_SIZE 32767

//Standard Response String 
#define _STORED 0
#define _VALUE 1 
#define _END 2
#define _DELETED 3
#define _NOTFOUND 4
#define STR_STORED "STORED\r\n"
#define STR_VALUE "VALUE "
#define STR_END "END\r\n"
#define STR_DELETED "DELETED\r\n"
#define STR_NOTFOUND "NOT FOUND\r\n"

// For Hash Function
#define MAGIC_NUM 31
#include<stdint.h>
enum ascii_cmd {
  GET_CMD,
  SET_CMD,
  DELETE_CMD,
  //Standard Response from the Server
  VALUE_RESP,
  DELETED_RESP,
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
	uint16_t len;
	// indicator for packet direction: 0 -> back to user; 1 -> to Memcached Server
	// -1 -> unprocessed
	int dir; 
}MEM;

extern MEM packet_block;
void mem_code();
