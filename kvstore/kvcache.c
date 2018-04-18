#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <unistd.h>
#include <pcap.h>
#include <stdbool.h>

#include "memcache_forwarder.h"

pcap_t *client_handle = NULL;
pcap_t *server_handle = NULL;

pthread_t client_tid;
pthread_t server_tid;

void forward_client_frame(const void *packet, int len) {
	if (server_handle != NULL) {
		pcap_inject(server_handle, packet, len);
	}
}

void forward_server_frame(const void *packet, int len) {
	if (client_handle != NULL) {
		pcap_inject(server_handle, packet, len);
	}
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

	/* Spawn 2 threads : client thread and server thread */
	int ret_val;
	ret_val = pthread_create(&client_tid, NULL, client_thread, NULL);
	if (ret_val < 0) {
		perror("Client thread creation failed");
		exit(1);
	}

	ret_val = pthread_create(&server_tid, NULL, server_thread, NULL);
	if (ret_val < 0) {
		perror("Server thread creation failed");
		exit(1);
	}

	while (true);
	return 0;
}