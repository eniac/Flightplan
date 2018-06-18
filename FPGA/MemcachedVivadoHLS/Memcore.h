
//Assumptions
#define REQUEST_LINE_SIZE 2000
#define MAX_DATA_SIZE 2000 
#define MAX_PACKET_SIZE REQUEST_LINE_SIZE+MAX_DATA_SIZE
#define MAX_KEY_LEN 256
#define MAX_MEMORY_SIZE 1500
#define MAX_CMD_LEN 10
#define NUM_OF_CMD 5
#define MAX_RESPONSE_LEN 20
#define NUM_OF_RESPONSE 5
//Some consts in the hdr
#define IPV4_LEN_FIELD 16
#define UDP_LEN_FIELD 38
#define PAYLOAD_OFFSET_UDP 50 //Payload location under UDP include 8 bytes memcached header
#define MEMCACHED_UDP_HEADER 8 
#define ETH_HDR_LEN 14
#define IPV4_HDR_LEN 20
#define UDP_HDR_LEN 8;

#define UDP_IDENTIFIER (23)
//Standard Response String 
#define _STORED 0
#define _VALUE 1 
#define _END 2
#define _DELETED 3
#define _NOTFOUND 4
#define STR_STORED "STORED"
#define STR_VALUE "VALUE"
#define STR_END "END"
#define STR_DELETED "DELETED"
#define STR_NOTFOUND "NOT FOUND"

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

struct Standard_Cmd{
	uint8_t cmd[MAX_CMD_LEN];
	int len;
	enum ascii_cmd cc;
};



typedef struct cmd_staus{
  enum ascii_cmd CMD;
  uint8_t KEY[MAX_KEY_LEN];
  int KEY_LEN;
  int FLAG;
  int EXPERT;
  int BYTE;
  uint8_t DATA[MAX_DATA_SIZE];
}CMD_STAT;

typedef struct key_data{
  uint8_t KEY[MAX_KEY_LEN];
  int KEY_LEN;
  uint8_t DATA[MAX_DATA_SIZE];
  long DATA_LEN;
  bool VALID;
}CACHE;

typedef struct mem_packet{
	uint8_t data[MAX_DATA_SIZE];
	uint16_t len;
	/*There are three states: 
		0 : unprocessed packet;
		1 : finished packet;
		2 : need one more process;
	  The packet fed into Memcore is either in state 0 or state 2. Assume that if one packet requires to
	  send packets to both server and user. It will send to user first. That is to say, when the income packet
	  is in state 2, the Memcore will generate the packet for the server.
	*/
	int STATE;
	// swap the src and dst: 0 -> no need for swap; 1 -> swap.
	int SWAP; 
}Mem_sym;

struct Standard_Response{
        uint8_t line[MAX_RESPONSE_LEN];
        int len;
};



