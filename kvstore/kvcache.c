#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <unistd.h>
#include <pcap.h>
#include <stdbool.h>

#include "kvcache.h"
#include "memcache_forwarder.h"

pcap_t *client_handle = NULL;
pcap_t *server_handle = NULL;
pthread_t client_tid;
cache_entry *key_value_cache = NULL;

void set_cache_entry(char *key, char *value) {

	cache_entry *entry;

	HASH_FIND_STR(key_value_cache, key, entry);
 	if (entry == NULL) {
		entry = (cache_entry *)calloc(1, sizeof(cache_entry));
		strncpy(entry->key, key, strlen(key));
		HASH_ADD_STR(key_value_cache, key, entry);
	}	
	strncpy(entry->value, value, strlen(value));
}

bool cas_cache_entry(char *key, char *old_value, char *new_value) {

	cache_entry *entry;

	HASH_FIND_STR(key_value_cache, key, entry);
	if (entry == NULL) {
		entry = (cache_entry *)calloc(1, sizeof (cache_entry));
		strncpy(entry->key, key, strlen(key));
		strncpy(entry->value, new_value, strlen(new_value));
		return true;
	} else if (strcmp(entry->value, old_value) == 0) {
		strncpy(entry->value, new_value, strlen(new_value));		
		return true;
	}

	return false;
}

cache_entry *get_cache_entry(char *key) {

	cache_entry *entry;
	HASH_FIND_STR(key_value_cache, key, entry);
	return entry;
}

bool delete_cache_entry(char *key) {

	cache_entry *entry;

	HASH_FIND_STR(key_value_cache, key, entry);
	if (entry == NULL) {
		return false;
	}

	HASH_DEL(key_value_cache, entry);
	free(entry);
	return true;
}

int main (int argc, char **argv) {
	char *client_interface = NULL;
	char *server_interface = NULL;
	int opt = 0;

	while ((opt = getopt(argc, argv, "c:s:")) != -1) {

		switch (opt) {

			case 'c':
				printf("Client facing interface: %s\n", optarg);
				client_interface = optarg;
				break;
				
			case 's':
				printf("Server facing interface: %s\n", optarg);
				server_interface = optarg;
				break;

			default:
				printf("\nUndefined opt	= %d\n", opt);
				exit(1);
		}
	}

	if (client_interface != NULL) {
		char client_error_buffer[PCAP_ERRBUF_SIZE];
		client_handle = pcap_open_live(client_interface, BUFSIZ, 
				1, 0, client_error_buffer);
		if (client_handle == NULL) {
			fprintf(stderr, "Could not open device %s: %s\n", client_interface,
					client_error_buffer);
			exit(1);
		}
	}

	if (server_interface != NULL) {
		char server_error_buffer[PCAP_ERRBUF_SIZE];
		server_handle = pcap_open_live(server_interface, BUFSIZ,
				1, 0, server_error_buffer);
		if (server_handle == NULL) {
			fprintf(stderr, "Could not open device %s: %s\n", server_interface,
					server_error_buffer);
			exit(1);
		}
	}

	int ret_val;
	ret_val = pthread_create(&client_tid, NULL, client_thread, NULL);
	if (ret_val < 0) {
		perror("Client thread creation failed");
		exit(1);
	}

	server_thread((void *)NULL);
	return 0;
}
