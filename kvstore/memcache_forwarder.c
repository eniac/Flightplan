#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <pcap.h>
#include <stdbool.h>

#include "kvcache.h"
#include "memcache_forwarder.h"
#include "memcache_parser.h"

void forward_to_server(const void *packet, int len) {
	printf("Forwarding packet to server..\n");
	if (server_handle != NULL) {
		pcap_inject(server_handle, packet, len);
	}	
}

void forward_to_client(const void *packet, int len) {
	if (client_handle != NULL) {
		pcap_inject(client_handle, packet, len);
	}
}

void client_cache_lookup(u_char *args, const struct pcap_pkthdr *header,
		const u_char *packet) {

	if (!parse_memcache_request((char *)packet, header->len)) {
		forward_to_server(packet, header->len);
	} else {
		// Inject response to client
	}
}

void server_response_forward(u_char *args, const struct pcap_pkthdr *header,
		const u_char *packet) {

	// TODO: Parse response and add to local cache before forwarding
	forward_to_client(packet, header->len);
}

void *client_thread(void *args) {
	printf("Starting client thread..\n");
	while (true) {
		pcap_loop(client_handle, 0, client_cache_lookup, NULL);
	}
}

void *server_thread(void *args) {
	printf("Starting server thread..\n");
	while (true) {
		pcap_loop(server_handle, 0, server_response_forward, NULL);
	}
}
