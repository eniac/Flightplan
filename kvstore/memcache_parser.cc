#include <stdio.h>
#include <string.h>

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

void parse_memcache_request(char *request_string, int length) {

	bool mute = true;
	int error = 0;
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
			error = process_get_commmand(client, tokens, ntokens);
			break;

		case SET_CMD:
			error = process_set_command(client, tokens, ntokens);
			break;

		case DELETE_CMD:
			error = process_delete_command(client, tokens, ntokens);
			break;

		case CAS_CMD:
			error = process_cas_command(client, tokens, ntokens);
			break;

		default:
			abort();
	}
}
