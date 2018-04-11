#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"

void my_packet_handler(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
	u_char *new_packet = NULL;
	int tagged_size = wharf_tag_frame(packet, header->len, &new_packet);
	int new_size = wharf_strip_frame(new_packet, tagged_size);
	if ((unsigned)new_size != header->len) {
		fprintf(stderr, "Frame size changed\n");
		exit(1);
	}
	for (int i = 0; (unsigned)i < header->len; i++) {
		if (new_packet[i] != packet[i]) {
			fprintf(stderr, "Frame changed\n");
			exit(1);
		}
	}
	forward_frame(new_packet, new_size);
	free(new_packet);
}
