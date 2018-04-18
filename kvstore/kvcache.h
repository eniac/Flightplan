#include <pcap.h>

#ifndef KVCACHE_H
#define KVCACHE_H

extern pcap_t *client_handle;
extern pcap_t *server_handle;
void forward_client_frame(const void *, int);
void forward_server_frame(const void *, int);

#endif
