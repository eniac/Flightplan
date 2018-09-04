#include <stdlib.h>
#include <signal.h>
#include "wharf_pcap.h"
#include "fecPcap.h"
#include "fecBooster.h"
#include "fecBoosterApi.h"

static pcap_t *input_handle = NULL;
static pcap_t *output_handle = NULL;

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


static void sigalrm_handler(int signal) {
	pcap_breakloop(input_handle);
}

int main (int argc, char** argv) {
	char* inputInterface = NULL;
	char* outputInterface = NULL;
	int opt = 0;
	int rc;

	// initialize fec codewords
	if ((rc = rse_init()) != 0 ) exit(rc);

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
		case 'w':
			fprintf(stderr, "Warning: worker ID is unused\n");
			break;
		case 't':
			fprintf(stderr, "Warning: Worker Count is unused\n");
			break;
		case 'r':
			printf("Loading rules from file: %s\n", optarg);
			if (wharf_load_from_file(optarg) != 0) {
				abort();
			}
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
		output_handle = pcap_open_live(outputInterface, BUFSIZ, 0, 0, output_error_buffer);
		if (output_handle == NULL) {
			LOG_ERR("Could not open device %s: %s", outputInterface, output_error_buffer);
			exit(1);
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
		return -1;
	}


	// Alarm handler will signal the pcap loop to break
	signal(SIGALRM, sigalrm_handler);

	while (1) {
		alarm(1);
		// Execute the pcap loop for 1 second, then break and call the timeout handler
		pcap_loop(input_handle, 0, my_packet_handler, NULL);
		LOG_INFO("Handled alarm...");
		booster_timeout_handler();
	}
}

