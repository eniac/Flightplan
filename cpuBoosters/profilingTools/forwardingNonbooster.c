#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include "fecBooster.h"

#ifndef WHARF_DROP_AFTER
// As h packets may be recovered for every k + h packets sent, this value should
// be no larger than (k + h) / h
// Values smaller than that will result in test failures
#define WHARF_DROP_AFTER 0
#endif

// Setting this to 0 drops the first packet, which ensures that a packet is dropped
// in every set of packets, regardless of whether the set is complete
int drop = 0;
int packets_so_far = 0;
int rolloverCtr = 0;
int k = 10;
int h = 4;
int dropUpTo = 4;

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {
	if (rolloverCtr< dropUpTo){
#if WHARF_DEBUGGING
		LOG_INFO("dropped packet %d", packets_so_far);
#endif // WHARF_DEBUGGING
	}
	else {
		forward_frame(packet, header->len);
	}
	rolloverCtr += 1;
	if (rolloverCtr == (k + h)){
		rolloverCtr = 0;
	}
	packets_so_far += 1;
}

void booster_timeout_handler() {
}
