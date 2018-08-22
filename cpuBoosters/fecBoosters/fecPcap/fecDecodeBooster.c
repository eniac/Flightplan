#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecPcap.h"
#include "fecBooster.h"
#include "fecBoosterApi.h"

/**
 * Each class of traffic has some decoding state that needs to be maintained
 */
struct tclass_state {
	bool nothing_to_decode;
	int lastBlockId;
	int lastPacketIdx;
	/** After each second, this value is decremented. If it == 0, block is forwarded */
	int timeout;
};

static struct tclass_state tclasses[TCLASS_MAX + 1];

inline void reset_decoder (tclass_type tclass, const int block_id) {
	tclasses[tclass].nothing_to_decode = true;
	mark_pkts_absent(tclass, DEFAULT_PORT, block_id);
	tclasses[tclass].timeout = 0;
}

// Try to decode new packets, and forward them on.
void decode_and_forward(tclass_type tclass, const int block_id) {
	if (tclasses[tclass].nothing_to_decode ||
			is_all_data_pkts_recieved_for_block(tclass, DEFAULT_PORT, block_id)) {
		reset_decoder(tclass, block_id);
		LOG_INFO("Received all data packets for blockID :: %d Skipping calling decode", block_id);
		return;
	}

	populate_fec_blk_data_and_parity(tclass, DEFAULT_PORT, block_id);

	// Decode inserts the packets directly into the packet buffer
	decode_block(tclass, DEFAULT_PORT, block_id);

#if WHARF_DEBUGGING
	int num_recovered_packets = 0;
#endif // WHARF_DEBUGGING
	for (int i = 0; i < wharf_get_k(tclass); i++) {
		if (pkt_recovered(tclass, DEFAULT_PORT, block_id, i)) {
			num_recovered_packets += 1;

			FRAME_SIZE_TYPE size;
			u_char *pkt = retrieve_from_pkt_buffer(tclass, DEFAULT_PORT, block_id, i, &size);

			// Recovered packet may have a length of 0, if it was filler
			// In this case, no need to forward
			if (size > 0) {
				LOG_INFO("Forwarding packet of size %d", (int)size);
				forward_frame(pkt, size);
			}
		}
	}

#if WHARF_DEBUGGING
	LOG_INFO("num_recovered_packets=%d\n", num_recovered_packets);
#endif // WHARF_DEBUGGING

	reset_decoder(tclass, block_id);
}


void booster_timeout_handler() {
	for (int i=0; i < TCLASS_MAX; i++) {
		if (tclasses[i].timeout > 0) {
			tclasses[i].timeout--;
			// If the timeout counter transitioned to 0 on this iteration
			if (tclasses[i].timeout == 0) {
				LOG_INFO("Decode-and-forward due to timer %d expiry", i);
				decode_and_forward(i, tclasses[i].lastBlockId);
			}
		}
	}
}

/**
 * This definition causes the decoder to check that encoded packets
 * are tagged with the proper class (based on port and protocol) upon decoding.
 * Comment out to disable this feature
 */
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
			LOG_ERR("Untagged packet (ether-type %x) should have had class %d", ntohs(eth_header->ether_type), tclass);
		} else {
			LOG_INFO("Untagged packet properly untagged");
		}
#endif
		forward_frame(packet, header->len);
		return;
	}

	// Make a copy of the header so the packet can later be modified
	struct fec_header fecHeader = *(struct fec_header *)(packet + sizeof(struct ether_header));

#if WHARF_DEBUGGING
	LOG_INFO("class_id=%d block_id=%d index=%d size=%d",
             fecHeader.class_id, fecHeader.block_id, fecHeader.index, header->len);
#endif // WHARF_DEBUGGING

	tclass_type tclass = fecHeader.class_id;
	struct tclass_state *tclass_status = &tclasses[tclass];

	if (fecHeader.block_id != tclass_status->lastBlockId ||
			fecHeader.index < tclass_status->lastPacketIdx) {
		decode_and_forward(tclass, tclass_status->lastBlockId);
		tclass_status->lastBlockId = fecHeader.block_id;

		int t = wharf_get_t(tclass);
		if (t > 0) {
			// TODO: +1 to the decoder timeout to avoid decoding before encoding finished
			tclass_status->timeout = t + 1;
		}
	}
	tclass_status->lastPacketIdx = fecHeader.index;

	int size = header->len;
	const u_char *stripped = wharf_strip_frame(packet, &size);


	// Forward data packets immediately
	if (fecHeader.index < wharf_get_k(tclass)) {
		// If there is no data outside of the wharf frame, no need to forward (packet was filler)
		if (header->len > WHARF_ORIG_FRAME_OFFSET) {
#ifdef CHECK_TABLE_ON_DECODE
			tclass_type tclass = wharf_query_packet(stripped, size);
			if (tclass == (tclass_type) fecHeader.class_id) {
				LOG_INFO("Traffic classes match: %d", tclass);
			} else {
				LOG_ERR("Traffic classes do not match! %d and %d", tclass, fecHeader.class_id);
			}
#endif
			forward_frame(stripped, size);
		}
	}

	// Buffer data and parity packets in case need to decode.
	if (!pkt_already_inserted(tclass, DEFAULT_PORT, fecHeader.block_id, fecHeader.index)) {
		tclass_status->nothing_to_decode = false;
		LOG_INFO("Inserting packet %d.%d with size %d", (int)fecHeader.block_id, (int)fecHeader.index, size);
		insert_into_pkt_buffer(fecHeader.class_id, DEFAULT_PORT, fecHeader.block_id,
                               fecHeader.index, size, stripped);
	}
	else {
		LOG_ERR("Not buffering duplicate packet");
	}
}
