#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include "fecBooster.h"

#define WHARF_DROP_AFTER 8
#define WHARF_DROP_NOTAFTER 0

// Setting this to 0 drops the first packet, which ensures that a packet is dropped
// in every set of packets, regardless of whether the set is complete
int drop = 0;
int packets_so_far = 0;

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
	packets_so_far += 1;
#if WHARF_DROP_AFTER == 0
	forward_frame(packet, header->len);
#else
	if (0 == drop) {
		drop = WHARF_DROP_AFTER + WHARF_DROP_NOTAFTER;
#if WHARF_DEBUGGING
		printf("dropped packet %d\n", packets_so_far);
#endif // WHARF_DEBUGGING
	} else {
		forward_frame(packet, header->len);
		drop -= 1;
	}
#endif // WHARF_DROP_AFTER > 0
}

void booster_timeout_handler() {
}
