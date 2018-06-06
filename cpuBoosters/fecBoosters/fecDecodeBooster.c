#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"
#include "fecBoosterApi.h"

// This is true when the buffer doesn't contain any packets for decoding.
static bool nothing_to_decode = true;
static int lastBlockId = 0;
static int lastPacketIdx = -1;

inline void reset_decoder (const int block_id) {
	nothing_to_decode = true;
	mark_pkts_absent(block_id);
}

// Try to decode new packets, and forward them on.
// FIXME possible race condition if simultaneous timer expiry and packet arrival that triggers decode.
void decode_and_forward(const int block_id) {
	if (nothing_to_decode || is_all_data_pkts_recieved_for_block(block_id)) {
		reset_decoder (block_id);
		printf("Received all data packets for blockID :: %d Skipping calling decode\n", block_id);
		return;
	}

	populate_fec_blk_data_and_parity(block_id);

	// Decode inserts the packets directly into the packet buffer
	decode_block(block_id);

#if WHARF_DEBUGGING
	int num_recovered_packets = 0;
#endif // WHARF_DEBUGGING
	for (int i = 0; i < NUM_DATA_PACKETS; i++) {
		if (pkt_recovered(block_id, i)) {
			num_recovered_packets += 1;

			FRAME_SIZE_TYPE size;
			u_char *pkt = retrieve_from_pkt_buffer(block_id, i, &size);

			// Recovered packet may have a length of 0, if it was filler
			// In this case, no need to forward
			if (size > 0) {
				forward_frame(pkt, size);
			}
		}
	}

#if WHARF_DEBUGGING
	printf("num_recovered_packets=%d\n", num_recovered_packets);
#endif // WHARF_DEBUGGING

	reset_decoder (block_id);
}


#if WHARF_DECODE_TIMEOUT != 0
void sigalrm_handler(int signal) {
	if (signal != SIGALRM) {
		fprintf(stderr, "Unexpected signal: %d\n", signal);
		exit(1);
	}

	decode_and_forward(lastBlockId); // FIXME ensure the function is reentrant
}
#endif // WHARF_DECODE_TIMEOUT != 0

#define CHECK_TABLE_ON_DECODE

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
	// If not a wharf packet, just forward
	if (WHARF_ETHERTYPE != ntohs(eth_header->ether_type)) {
#ifdef CHECK_TABLE_ON_DECODE
		tclass_type tclass = wharf_query_packet(packet, header->len);
		if (tclass != TCLASS_NULL) {
			fprintf(stderr, "Untagged packet should have had class %d\n", tclass);
		} else {
			fprintf(stderr, "Untagged packet properly untagged\n");
		}
#endif
		forward_frame(packet, header->len);
		return;
	}

	// Make a copy of the header so the packet can later be modified
	struct fec_header fecHeader = *(struct fec_header *)(packet + sizeof(struct ether_header));

#if WHARF_DEBUGGING
	printf("class_id=%d block_id=%d index=%d size=%d\n", fecHeader.class_id, fecHeader.block_id,
	       fecHeader.index, header->len);
#endif // WHARF_DEBUGGING

	if (fecHeader.block_id != lastBlockId || fecHeader.index <= lastPacketIdx) {
		decode_and_forward(lastBlockId);
		lastBlockId = fecHeader.block_id;
#if WHARF_DECODE_TIMEOUT != 0
		alarm(WHARF_DECODE_TIMEOUT);
		signal(SIGALRM, sigalrm_handler);
#endif // WHARF_DECODE_TIMEOUT != 0
	}
	lastPacketIdx = fecHeader.index;

	int size = header->len;
	const u_char *stripped = wharf_strip_frame(packet, &size);


	// Forward data packets immediately
	if (fecHeader.index < NUM_DATA_PACKETS) {
		// If there is no data outside of the wharf frame, no need to forward (packet was filler)
		if (header->len > WHARF_ORIG_FRAME_OFFSET) {
#ifdef CHECK_TABLE_ON_DECODE
			tclass_type tclass = wharf_query_packet(stripped, size);
			if (tclass == (tclass_type) fecHeader.class_id) {
				fprintf(stderr, "Traffic classes match: %d\n", tclass);
			} else {
				fprintf(stderr, "Traffic classes do not match! %d and %d\n", tclass, fecHeader.class_id);
			}
#endif
			forward_frame(stripped, size);
		}
	}

	// Buffer data and parity packets in case need to decode.
	if (!pkt_already_inserted(fecHeader.block_id, fecHeader.index)) {
		nothing_to_decode = false;

	    insert_into_pkt_buffer(fecHeader.block_id, fecHeader.index, size, stripped);
	}
	else {
		fprintf(stderr, "Not buffering duplicate packet\n");
	}
}
