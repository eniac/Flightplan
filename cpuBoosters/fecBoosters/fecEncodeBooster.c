#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <net/ethernet.h>
#include <signal.h>

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
void encode_and_forward_block(tclass_type tclass, int currBlockID,
                              struct ether_header *packet_eth_header) {
	u_char *last_packet = (u_char *)packet_eth_header;

	u_char *new_packet = NULL;

	fec_sym k, h;
	wharf_query_tclass(tclass, &k, &h, NULL);

	/* Loop over data packets, filling in missing packets with 0-length frames */
	for (int i=0; i < k; i++) {
		if (!pkt_already_inserted(tclass, currBlockID, i)) {

			/* Have to provide an ether header to be copied to the wharf tag */
			int tagged_size = wharf_tag_frame(tclass, last_packet, 0, &new_packet);

			/* 0-length frames must also be forwarded to the decoder */
			forward_frame(new_packet, tagged_size);

			/* Insert the 0-length dummy packet into the pkt buffer */
			insert_into_pkt_buffer(tclass, currBlockID, i, 0, last_packet);
		}
	}

	/* Populate the global fec structure for rse encoder and call the encode */
	populate_fec_blk_data(tclass, currBlockID);

	/* Encoder */
	encode_block();


	int parity_payload_size = copy_parity_packets_to_pkt_buffer(tclass, currBlockID);

	/* Inject all parity packets in the block to the network */
	for (int i = k; i < k + h; i++) {
		// We don't encapsulate ethernet header for parity packets
		u_char *parity_pkt = retrieve_from_pkt_buffer(tclass, currBlockID, i, NULL);
		int tagged_size = wharf_tag_frame(tclass, parity_pkt, parity_payload_size, &new_packet);
		struct ether_header *parity_eth_header = (struct ether_header *)new_packet;

		/* Copy over the src and dst mac from the last data packet in the block
		 * to the new packet's newly added ether header */
		memcpy(parity_eth_header->ether_dhost, packet_eth_header->ether_dhost, ETHER_ADDR_LEN);
		memcpy(parity_eth_header->ether_shost, packet_eth_header->ether_shost, ETHER_ADDR_LEN);

		forward_frame(new_packet, tagged_size);
		free(new_packet);
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
				lastBlockId[i] = advance_block_id(i);
				mark_pkts_absent(i, lastBlockId[i]);
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
	u_char *new_packet = NULL;

	tclass_type tclass = wharf_query_packet(packet, header->len);

	// If no rule mapping this packet to traffic class, simply forward
	if (tclass == TCLASS_NULL) {
		forward_frame(packet, header->len);
		return;
	}

	int tagged_size = wharf_tag_frame(tclass, packet, header->len, &new_packet);

	const struct fec_header *fecHeader = (struct fec_header *) (new_packet + SIZE_ETHERNET);

	/*storing these values, since new_packet is freed later.*/
	int currBlockID = fecHeader->block_id;
	int currPktIdx = fecHeader->index;


	/* If this packet belongs to a new block */
	if (fecHeader->index == 0) {
		mark_pkts_absent(tclass, fecHeader->block_id);
			lastBlockId[tclass] = currBlockID;

			int t = wharf_get_t(tclass);
			if (t > 0) {
				timeouts[tclass] = t;
			}
#if WHARF_ENCODE_TIMEOUT != 0
		// If no new block before timeout, force the block to be forwarded
		signal(SIGALRM, sigalrm_handler);
		alarm(WHARF_ENCODE_TIMEOUT);
#endif // WHARF_ENCODE_TIMEOUT

	}

	/* Forward data packet now, then buffer it below (Needed for encoder) */
	if (fecHeader->index < wharf_get_k(tclass)) {
		last_eth_header[tclass] = *(struct ether_header *)packet;
		forward_frame(new_packet, tagged_size);
	}

	free(new_packet);

	if (!pkt_already_inserted(tclass, currBlockID, currPktIdx)) {
		insert_into_pkt_buffer(tclass, currBlockID, currPktIdx, header->len, packet);
	} else {
		fprintf(stderr, "Tagging produced a duplicate index: %d/%d\n", currBlockID, currPktIdx);
		exit(1);
	}

	/* Check if the block is ready for processing, i.e., all data packets in the block are populated */
	if (is_all_data_pkts_recieved_for_block(tclass, currBlockID)) {
#if WHARF_ENCODE_TIMEOUT != 0
		alarm(0);
#endif
		encode_and_forward_block(tclass, currBlockID, &last_eth_header[tclass]);
	}
	return;
}
