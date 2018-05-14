#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include "kvcache.h"
#include "memcache_parser.h"

static enum ascii_cmd ascii_to_command(char *start, size_t length)
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
      if (strncmp(start, commands[x].cmd, commands[x].len) == 0)
      {
        /* Potential hit */
        if (length == commands[x].len || isspace(*(start + commands[x].len)))
        {
          return commands[x].cc;
        }
      }
    }
    ++x;
  }

  return UNKNOWN_CMD;
}

static uint16_t parse_ascii_key(char **start)
{
  uint16_t len= 0;
  char *c= *start;
  /* Strip leading whitespaces */
  while (isspace(*c))
  {
    ++c;
  }

  *start= c;

  while (*c != '\0' && !isspace(*c) && !iscntrl(*c))
  {
    ++c;
    ++len;
  }


  if (len == 0 || len > 240 || (*c != '\0' && *c != '\r' && iscntrl(*c)))
  {
    return 0;
  }

  return len;
}

int ascii_tokenize_command(char *str, char *end, char **vec, int size) {

	int num_elem = 0;

	while (str < end) {

		while (str < end && isspace(*str)) {
			str++;
		}

		if (str == end) {
			return num_elem;
		}

		vec[num_elem++] = str;

		while (str < end && !isspace(*str)) {
			str++;
		}

		*str = '\0';
		++str;

		if (num_elem == size) {
			break;
		}
	}

	return num_elem;
}

void process_get_command(char **tokens, int ntokens) {

	char *key = tokens[1];
	cache_entry *kv_entry = get_cache_entry(key);
	if (kv_entry == NULL) {
		// Forward request to memcached
	} else {
		char *value = kv_entry->value;
		// Send value back to client
		// Send END\r\n back to client
	}
}

void process_set_command(char **tokens, int ntokens) {


}

void process_delete_command(char **tokens, int ntokens) {

	char *key = tokens[1];
	if (!delete_cache_entry(key)) {
		// Forward request to memcached
	} else {
		// Send DELETED to client
	}
}

void parse_memcache_request(char *request_string, int length) {

	bool mute = true;
	int command_code = ascii_to_command(request_string, length);

	char *tokens[10];
	int ntokens = ascii_tokenize_command(request_string, request_string+length,
			tokens, 10);

	if (ntokens < 10) {
		mute = strcmp(tokens[ntokens-1], "noreply") == 0;
		if (mute) {
			ntokens--;
		}
	}

	switch(command_code) {

		case GET_CMD:
			process_get_command(tokens, ntokens);
			break;

		case SET_CMD:
			process_set_command(tokens, ntokens);
			break;

		case DELETE_CMD:
			process_delete_command(tokens, ntokens);
			break;

		default:
			abort();
	}
}
