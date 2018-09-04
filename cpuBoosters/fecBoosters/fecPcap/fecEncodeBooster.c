#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <net/ethernet.h>
#include <signal.h>
#include <netinet/ether.h>

#include "fecPcap.h"
#include "fecBooster.h"
#include "fecBoosterApi.h"

// Packet ether header mac address is copied from last received packet
// Must be global to be accessible through SIGALRM handler
static struct ether_header last_eth_header[TCLASS_MAX + 1];
static int lastBlockId[TCLASS_MAX + 1];

/**
 * Timeout values for each traffic class.
 * Decremented once a second.
 * When it reaches 0, dummy packets are inserted and the block is forwarded.
 */
static int timeouts[TCLASS_MAX + 1];

/**
 * @brief Fills any absent packets with 0-length frames, encodes, and forwards parity packets
 *
 * @param   currBlockID     ID of block to be encoded and forwarded
 * @param   last_packet     Sample packet, used to obtain src and dst MAC address for parity
 */
static void encode_and_forward_block(tclass_type tclass, int currBlockID,
                              struct ether_header *packet_eth_header) {
    packet_eth_header->ether_type = 0;
	u_char *last_packet = (u_char *)packet_eth_header;

	fec_sym k, h;
	wharf_query_tclass(tclass, &k, &h, NULL);

	size_t empty_size = WHARF_TAG_SIZE;
	u_char empty_packet[empty_size];
	/* Loop over data packets, filling in missing packets with 0-length frames */
	for (int i=0; i < k; i++) {
		if (!pkt_already_inserted(tclass, DEFAULT_PORT, currBlockID, i)) {
			wharf_tag_data(tclass, currBlockID, i, last_packet,
                           sizeof(struct ether_header), empty_packet, &empty_size);
			LOG_INFO("Forwarding empty packet size %zu", empty_size);
			forward_frame(empty_packet, empty_size);
			insert_into_pkt_buffer(tclass, DEFAULT_PORT, currBlockID, i, 0, last_packet);
		}
		LOG_INFO("Packet %d already inserted", i);
	}

	/* Populate the global fec structure for rse encoder and call the encode */
	populate_fec_blk_data(tclass, DEFAULT_PORT, currBlockID);

	/* Encoder */
	encode_block();

	size_t parity_size;
	/* Inject all parity packets in the block to the network */
	for (int i = k; i < k + h; i++) {
		// We don't encapsulate ethernet header for parity packets
		u_char *parity_pkt = retrieve_encoded_packet(tclass, i, &parity_size);
		size_t tagged_size = parity_size + WHARF_TAG_SIZE;
		u_char tagged_pkt[tagged_size];

		wharf_tag_parity(tclass, currBlockID, i,
		                 parity_pkt, parity_size,
		                 tagged_pkt, &tagged_size);

		struct ether_header *parity_eth_header = (struct ether_header *)tagged_pkt;

		/* Copy over the src and dst mac from the last data packet in the block
		 * to the new packet's newly added ether header */
		memcpy(parity_eth_header->ether_dhost, packet_eth_header->ether_dhost, ETHER_ADDR_LEN);
		memcpy(parity_eth_header->ether_shost, packet_eth_header->ether_shost, ETHER_ADDR_LEN);

		LOG_INFO("Forwarding parity frame idx %d tagged size %zu", i, tagged_size);
		forward_frame(tagged_pkt, tagged_size);
	}
	timeouts[tclass] = 0;
}


void booster_timeout_handler() {
	for (int i=0; i < TCLASS_MAX; i++) {
		if (timeouts[i] > 0) {
			timeouts[i]--;
			// If the timeout counter transitioned to 0
			if (timeouts[i] == 0 ) {
				LOG_INFO("Encode and forward due to timeout %d=0", i);
				// Force the data to be encoded and forwarded
				encode_and_forward_block(i, lastBlockId[i], &last_eth_header[i]);
				lastBlockId[i] = advance_block_id(i, DEFAULT_PORT);
				mark_pkts_absent(i, DEFAULT_PORT, lastBlockId[i]);
			}
		}
	}
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

	size_t packet_len = header->len;
	tclass_type tclass = wharf_query_packet(packet, packet_len);
	LOG_INFO("Got packet of size %d", (int)packet_len);

	// If no rule mapping this packet to traffic class, simply forward
	if (tclass == TCLASS_NULL) {
		forward_frame(packet, packet_len);
		return;
	}

	// Create the new packet to be forwarded
	size_t new_size = packet_len + sizeof(struct fec_header);
	u_char new_packet[new_size];

	uint8_t block_id = get_fec_block_id(tclass, DEFAULT_PORT);
	uint8_t packet_idx = get_fec_frame_idx(tclass, DEFAULT_PORT);

	// Tagging the packet also advances the packet index
	wharf_tag_data(tclass, block_id, packet_idx, packet, packet_len, new_packet, &new_size);
	advance_packet_idx(tclass, DEFAULT_PORT);

	/* Forward the data packet nowm, then buffer it below for the encoder */
	forward_frame(new_packet, new_size);

	const struct fec_header *fec = (struct fec_header *) (new_packet + SIZE_ETHERNET);

	// If it's the start of a new block
	if (fec->index == 0) {
		mark_pkts_absent(tclass, DEFAULT_PORT, block_id);
		lastBlockId[tclass] = block_id;

		int t = wharf_get_t(tclass);
		if (t > 0) {
			timeouts[tclass] = t;
		}
	}


	if (!pkt_already_inserted(tclass, DEFAULT_PORT, block_id, packet_idx)) {
		insert_into_pkt_buffer(tclass, DEFAULT_PORT, block_id, packet_idx, packet_len, packet);
	} else {
		fprintf(stderr, "Tagging produced a duplicate index: %d/%d\n", fec->block_id, fec->index);
		exit(1);
	}

	/* If it's the last data packet in the block */
	if (fec->index == wharf_get_k(tclass) - 1) {
		encode_and_forward_block(tclass, fec->block_id, (struct ether_header*)packet);
	}
	return;
}
