#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include "fecBooster.h"

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
	forward_frame(packet, header->len);
}
