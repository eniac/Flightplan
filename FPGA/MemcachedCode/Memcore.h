#define Request_Line_Size 2000
#define Max_Key_Len 256
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
