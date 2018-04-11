#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include "fecBooster.h"

#define WHARF_DROP_RATE 10
int drop = WHARF_DROP_RATE;

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
#if WHARF_DROP_RATE == 0
	forward_frame(packet, header->len);
#else
	if (0 == drop) {
		drop = WHARF_DROP_RATE;
	} else {
		forward_frame(packet, header->len);
		drop -= 1;
	}
#endif // WHARF_DROP_RATE > 0
}
