#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include "fecBooster.h"

#define WHARF_DROP_RATE (NUM_DATA_PACKETS + NUM_PARITY_PACKETS - 1)
int drop = WHARF_DROP_RATE;

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
#if WHARF_DROP_RATE == 0
	forward_frame(packet, header->len);
#else
	if (0 == drop) {
		drop = WHARF_DROP_RATE;
#if WHARF_DEBUGGING
		printf("dropped packet after forwarding %d\n", WHARF_DROP_RATE);
#endif // WHARF_DEBUGGING
	} else {
		forward_frame(packet, header->len);
		drop -= 1;
	}
#endif // WHARF_DROP_RATE > 0
}
