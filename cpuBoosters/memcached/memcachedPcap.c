#include <stdlib.h>
#include <signal.h>
#include <pcap.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <net/ethernet.h>
#include "memcached.h"

static pcap_t *input_handle = NULL;
static pcap_t *output_handle = NULL;

#define LOG_ERR(s, ...) fprintf(stderr, "[%s:%s()::%d] ERROR: " s "\n", __FILE__, __func__, __LINE__, ##__VA_ARGS__)

/**
 * @brief Forwards the provided frame to the configured output pcap handle.
 *
 * @param[in] packet Packet data to be send on the output interface
 * @param[in] len Size of the provided packet
 */
void forward_frame(const void * packet, int len) {
	if (NULL != output_handle) {
		pcap_inject(output_handle, packet, len);
	} else {
		pcap_inject(input_handle, packet, len);
	}
}

/** In both TCP and UDP, port starts 2 bytes into header.
 * This assumes that the IP header is 20 bytes long (which may not always be the case)
 */
#define PORT_OFFSET sizeof(struct ether_header) + 22

/** Returns a tcp or udp packet's port */
static uint16_t get_port(const u_char *packet, uint32_t pkt_len) {
    if (pkt_len < PORT_OFFSET) {
        return 0;
    }
    uint16_t *port = (uint16_t*)(packet + PORT_OFFSET);
    return ntohs(*port);
}


static void packet_handler(u_char *args, const struct pcap_pkthdr *hdr,
                           const u_char *packet) {
    printf("Got packet!\n");

    uint16_t port = get_port(packet, hdr->len);
    if (port != 11211) {
        printf("Not a memcached packet (port: %d)\n", (int)port);
        forward_frame(packet, hdr->len);
    } else {
        printf("calling memcachedn");
        call_memcached((const char*)packet, hdr->len, forward_frame);
    }
}

int main (int argc, char** argv) {
	char* inputInterface = NULL;
	char* outputInterface = NULL;
	int opt = 0;

	while ((opt = getopt(argc, argv, "i:o:w:t:r:")) != -1)
	{
		switch (opt)
		{
		case 'i':
			printf("inputInterface: %s\n",optarg);
			inputInterface = optarg;
			break;
		case 'o':
			printf("outputInterface: %s\n",optarg);
			outputInterface = optarg;
			break;
		default:
			printf("\nNot yet defined opt = %d\n", opt);
			abort();
		}
	}

	if (NULL == inputInterface) {
		LOG_ERR("Need -i at least -i parameter");
		fprintf(stderr, "Usage: %s -i input [-o output] [-w workerId] [-t workerCt]\n", argv[0]);
		exit(1);
	}

	if (NULL != outputInterface) {
		char output_error_buffer[PCAP_ERRBUF_SIZE];

        output_handle = pcap_create(outputInterface, output_error_buffer);

        if (output_handle == NULL) {
            LOG_ERR("Could not create pcap handle");
            exit(1);
        }
        if (pcap_set_promisc(output_handle, 1) != 0) {
            LOG_ERR("Could not set promisc");
            return -1;
        }
        if (pcap_set_immediate_mode(output_handle, 1) != 0) {
            LOG_ERR("Could not set immediate");
            return -1;
        }

        if (pcap_activate(output_handle) != 0) {
            LOG_ERR("Could not activate output handle!");
            return -1;
        }

	}

	char input_error_buffer[PCAP_ERRBUF_SIZE];


	input_handle = pcap_create(inputInterface, input_error_buffer);

	if (input_handle == NULL) {
		LOG_ERR("Could not create pcap handle");
		exit(1);
	}
	if (pcap_set_promisc(input_handle, 1) != 0) {
		LOG_ERR("Could not set promisc");
		return -1;
	}
	if (pcap_set_immediate_mode(input_handle, 1) != 0) {
		LOG_ERR("Could not set immediate");
		return -1;
	}

	if (pcap_activate(input_handle) != 0) {
        LOG_ERR("Could not activate input handle");
		return -1;
	}

    printf("Starting pcap loop!\n");

	while (1) {
		// Execute the pcap loop for 1 second, then break and call the timeout handler
		pcap_loop(input_handle, 0, packet_handler, NULL);
	}
}

