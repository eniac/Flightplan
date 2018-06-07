#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"
#include "fecBoosterApi.h"

// This is true when the buffer doesn't contain any packets for decoding.
static bool nothing_to_decode = true;
static int lastBlockId[TCLASS_MAX + 1];
static int lastPacketIdx[TCLASS_MAX + 1];

inline void reset_decoder (tclass_type tclass, const int block_id) {
	nothing_to_decode = true;
	mark_pkts_absent(tclass, block_id);
}

// Try to decode new packets, and forward them on.
// FIXME possible race condition if simultaneous timer expiry and packet arrival that triggers decode.
void decode_and_forward(tclass_type tclass, const int block_id) {
	if (nothing_to_decode || is_all_data_pkts_recieved_for_block(tclass, block_id)) {
		reset_decoder(tclass, block_id);
		printf("Received all data packets for blockID :: %d Skipping calling decode\n", block_id);
		return;
	}

	populate_fec_blk_data_and_parity(tclass, block_id);

	// Decode inserts the packets directly into the packet buffer
	decode_block(tclass, block_id);

#if WHARF_DEBUGGING
	int num_recovered_packets = 0;
#endif // WHARF_DEBUGGING
	for (int i = 0; i < wharf_get_k(tclass); i++) {
		if (pkt_recovered(tclass, block_id, i)) {
			num_recovered_packets += 1;

			FRAME_SIZE_TYPE size;
			u_char *pkt = retrieve_from_pkt_buffer(tclass, block_id, i, &size);

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

	reset_decoder(tclass, block_id);
}

/**
 * Holds a timeout value for each traffic class.
 * After each second, this value is decremented.
 * If it reaches 0, the block is forwarded
 */
static int timeouts[TCLASS_MAX + 1];

void booster_timeout_handler() {
	for (int i=0; i < TCLASS_MAX; i++) {
		if (timeouts[i] > 0) {
			timeouts[i]--;
			// If the timeout counter transitioned to 0 on this iteration
			if (timeouts[i] == 0) {
				decode_and_forward(i, lastBlockId[i]);
			}
		}
	}
}

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

	tclass_type tclass = fecHeader.class_id;

	if (fecHeader.block_id != lastBlockId[tclass] || fecHeader.index < lastPacketIdx[tclass]) {
		decode_and_forward(tclass, lastBlockId[tclass]);
		lastBlockId[tclass] = fecHeader.block_id;

		int t = wharf_get_t(tclass);
		if (t > 0) {
            // TODO: +1 to the decoder timeout to avoid decoding before encoding finished
			timeouts[tclass] = t + 1;
		}
	}
	lastPacketIdx[tclass] = fecHeader.index;

	int size = header->len;
	const u_char *stripped = wharf_strip_frame(packet, &size);


	// Forward data packets immediately
	if (fecHeader.index < wharf_get_k(tclass)) {
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
	if (!pkt_already_inserted(tclass, fecHeader.block_id, fecHeader.index)) {
		nothing_to_decode = false;

	    insert_into_pkt_buffer(fecHeader.class_id, fecHeader.block_id, fecHeader.index, size, stripped);
	}
	else {
		fprintf(stderr, "Not buffering duplicate packet\n");
	}
}
