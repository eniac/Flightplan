#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"

bool nothing_to_decode = true; // This is true when the buffer doesn't contain any packets for decoding.
int lastBlockId = 0;

// Try to decode new packets, and forward them on.
// FIXME possible race condition if have simultaneous timer expiry and a packet arrival that also triggers the decode.
void decode_and_forward(const int block_id) {
	if (nothing_to_decode || is_all_data_pkts_recieved_for_block(block_id)) {
		return;
	}

	call_fec_blk_get(block_id); // FIXME check this

	decode_block();

	copy_data_packets_to_pkt_buffer(block_id);

	for (int i = 0; i < NUM_DATA_PACKETS; i++) {
		if (pkt_buffer_filled[block_id][i] == PACKET_RECOVERED) {
			char* packetToInject = pkt_buffer[block_id][i];
			size_t outPktLen = get_total_packet_size(packetToInject);
			forward_frame(packetToInject, outPktLen);
		}
	}

	signal(SIGALRM, SIG_IGN);
	nothing_to_decode = true;
	zeroout_block_in_pkt_buffer(block_id);
}

void sigalrm_handler(int signal) {
	if (signal != SIGALRM) {
		fprintf(stderr, "Unexpected signal: %d\n", signal);
		exit(1);
	}

	decode_and_forward(lastBlockId);
}

/**
 * @brief      packet handler function for pcap
 *
 * @param      args    The arguments
 * @param[in]  header  The header
 * @param[in]  packet  The packet
 */
void my_packet_handler(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
	struct ether_header *eth_header = (struct ether_header *)packet;
	if (WHARF_ETHERTYPE != ntohs(eth_header->ether_type)) {
		fprintf(stderr, "Received untagged frame -- ignoring\n");
		return;
	}
	const struct fec_header *fecHeader = (struct fec_header *)(packet + sizeof(struct ether_header));

#if 0
	printf("class_id=%d block_id=%d index=%d size=%d\n", fecHeader->class_id, fecHeader->block_id,
		fecHeader->index, fecHeader->size);
#endif

	if (fecHeader->block_id != lastBlockId) {
		decode_and_forward(fecHeader->block_id);
		lastBlockId = fecHeader->block_id;
		alarm(WHARF_DECODE_TIMEOUT);
		signal(SIGALRM, sigalrm_handler);
	}

	// Forward data packets immediately
	if (fecHeader->index < NUM_DATA_PACKETS){
		forward_frame(packet + WHARF_ORIG_FRAME_OFFSET,
		 header->len - WHARF_ORIG_FRAME_OFFSET); // This also strips the Wharf tag.
	}

	// Buffer data and parity packets in case need to decode.
	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == PACKET_ABSENT) {
		nothing_to_decode = false;
		memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
		pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = PACKET_PRESENT;
	}
	else {
		fprintf(stderr, "Not buffering duplicate packet\n");
	}
}
