#include <stdio.h>
#include <stdlib.h>


void memcache_forwarder(u_char *args, const struct pcap_pkthdr *header,
		const u_char *packet) {

	forward_client_frame(packet, len);

}
