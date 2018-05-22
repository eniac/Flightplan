#ifndef MEMCACHE_PARSER_H
#define MEMCACHE_PARSER_H

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

bool parse_memcache_request(char *, int);

#endif
