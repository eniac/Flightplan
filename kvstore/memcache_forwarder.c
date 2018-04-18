#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <pcap.h>
#include <stdbool.h>

#include "kvcache.h"
#include "memcache_forwarder.h"

void forward_to_server() {

}

void forward_to_client() {

}

void client_cache_lookup(u_char *args, const struct pcap_pkthdr *header,
		const u_char *packet) {


}

void server_packet_forward(u_char *args, const struct pcap_pkthdr *header,
		const u_char *packet) {


}

void *client_thread(void *args) {
	printf("Starting client thread..\n");
	while (true) {
		pcap_loop(client_handle, 0, client_cache_lookup, NULL);
		forward_to_client();
	}
}

void *server_thread(void *args) {
	printf("Starting server thread..\n");
	while (true) {
		pcap_loop(server_handle, 0, server_packet_forward, NULL);
		forward_to_server();
	}
}
