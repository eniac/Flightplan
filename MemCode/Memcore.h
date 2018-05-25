#define Request_LINE_SIZE 2000
#define MAX_DATA_SIZE 10000
#define MAX_PACKET_SIZE Request_LINE_SIZE+MAX_DATA_SIZE
#define MAX_KEY_LEN 256
#include<stdint.h>
enum ascii_cmd {
  GET_CMD,
  GETS_CMD,
  SET_CMD,
  ADD_CMD,
  REPLACE_CMD,
  CAS_CMD,
  APPEND_CMD,
  PREPEND_CMD,
  DELETE_CMD,
  INCR_CMD,
  DECR_CMD,
  STATS_CMD,
  FLUSH_ALL_CMD,
  VERSION_CMD,
  QUIT_CMD,
  VERBOSITY_CMD,
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
extern unsigned char packet_block[MAX_DATA_SIZE];
void mem_code(unsigned char input[MAX_DATA_SIZE]);
