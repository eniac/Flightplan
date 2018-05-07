#include <pcap.h>
#include "uthash.h"

#ifndef KVCACHE_H
#define KVCACHE_H

typedef struct cache_entry {

	char key[256];
	char value[256];
	UT_hash_handle hh;

} cache_entry;

void set_cache_entry(char *, char *);
bool cas_cache_entry(char *, char *, char *);
cache_entry *get_cache_entry(char *);
bool delete_cache_entry(char *);

extern pcap_t *client_handle;
extern pcap_t *server_handle;

#endif
