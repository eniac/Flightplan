#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <net/ethernet.h>
#include <signal.h>

#include "fecBooster.h"

static int lastBlockId = 0;

// Packet ether header mac address is copied from last received packet
// Must be global to be accessible through SIGALRM handler
static const u_char *last_unencoded_packet = NULL;

/**
 * @brief Fills any absent packets with 0-length frames, encodes, and forwards parity packets
 *
 * @param   currBlockID     ID of block to be encoded and forwarded
 * @param   last_packet     Sample packet, used to obtain src and dst MAC address for parity
 */
void encode_and_forward_block(int currBlockID, const u_char *last_packet) {
	enum traffic_class tclass = TCLASS_ONE; // FIXME const -- use traffic classification

	u_char *new_packet = NULL;

	/* Loop over data packets, filling in missing packets with 0-length frames */
	for (int i=0; i < NUM_DATA_PACKETS; i++) {
		if (pkt_buffer_filled[currBlockID][i] == PACKET_ABSENT) {

			int tagged_size = wharf_tag_frame(tclass, (u_char*)pkt_buffer[currBlockID][i], 0, &new_packet);

			/** 0-length frames must also be forwarded to the decoder */
			forward_frame(new_packet, tagged_size);

			FRAME_SIZE_TYPE *original_frame_size = (FRAME_SIZE_TYPE *)(pkt_buffer[currBlockID][i]);
			*original_frame_size = 0;

			pkt_buffer_filled[currBlockID][i] = PACKET_PRESENT;
		}
	}

	/* Populate the global fec structure for rse encoder and call the encode */
	populate_fec_blk_data(currBlockID);

	/* Encoder */
	encode_block();


	int parity_payload_size = copy_parity_packets_to_pkt_buffer(currBlockID);

	/* Inject all parity packets in the block to the network */
	for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS + NUM_PARITY_PACKETS; i++) {
		// We don't encapsulate ethernet header for parity packets
		int tagged_size = wharf_tag_frame(tclass, (u_char*)pkt_buffer[currBlockID][i], parity_payload_size, &new_packet);
		struct ether_header *packet_eth_header = (struct ether_header *)last_packet;
		struct ether_header *parity_eth_header = (struct ether_header *)new_packet;

		/* Copy over the src and dst mac from the last data packet in the block
		 * to the new packet's newly added ether header */
		memcpy(parity_eth_header->ether_dhost, packet_eth_header->ether_dhost, ETHER_ADDR_LEN);
		memcpy(parity_eth_header->ether_shost, packet_eth_header->ether_shost, ETHER_ADDR_LEN);

		forward_frame(new_packet, tagged_size);
		free(new_packet);
	}
	last_unencoded_packet = NULL;
}

void sigalrm_handler(int signal) {
	if (signal != SIGALRM) {
		fprintf(stderr, "Unexpected signal: %d\n", signal);
		exit(1);
	}
	if (last_unencoded_packet == NULL) {
		return;
	}
	if (is_all_data_pkts_recieved_for_block(lastBlockId)) {
		return;
	}
	encode_and_forward_block(lastBlockId, last_unencoded_packet);
	lastBlockId = advance_block_id();
	mark_pkts_absent(lastBlockId);
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
	enum traffic_class tclass = TCLASS_ONE; // FIXME const -- use traffic classification

	int tagged_size = wharf_tag_frame(tclass, packet, header->len, &new_packet);

	const struct fec_header *fecHeader = (struct fec_header *) (new_packet + SIZE_ETHERNET);

	/*storing these values, since new_packet is freed later.*/
	int currBlockID = fecHeader->block_id;
	int currPktIdx = fecHeader->index;
	int currOriginalSize = fecHeader->size;

	/* If this packet belongs to a new block */
	if (fecHeader->block_id != lastBlockId) {
		lastBlockId = fecHeader->block_id;
		mark_pkts_absent(lastBlockId);

#if WHARF_ENCODE_TIMEOUT != 0
		// If no new block before timeout, force the block to be forwarded
		signal(SIGALRM, sigalrm_handler);
		alarm(WHARF_ENCODE_TIMEOUT);
#endif // WHARF_ENCODE_TIMEOUT

	}

	/* Forward data packet now, then buffer it below (Needed for encoder) */
	if (fecHeader->index < NUM_DATA_PACKETS) {
		last_unencoded_packet = packet;
		forward_frame(new_packet, tagged_size);
	}

	free(new_packet);

	/* Update the received pkt in the pkt buffer */
	if (pkt_buffer_filled[currBlockID][currPktIdx] == PACKET_ABSENT) {
		FRAME_SIZE_TYPE *original_frame_size = (FRAME_SIZE_TYPE *)(pkt_buffer[currBlockID][currPktIdx]);
		*original_frame_size = currOriginalSize;

		/* Store the original packet to the packet buffer */
		memcpy(pkt_buffer[currBlockID][currPktIdx] + sizeof(FRAME_SIZE_TYPE), packet, header->len);

		/* Update filled status */
		pkt_buffer_filled[currBlockID][currPktIdx] = PACKET_PRESENT;
	} else {
		fprintf(stderr, "Tagging produced a duplicate index: %d/%d\n", currBlockID, currPktIdx);
		exit(1);
	}

	/* Check if the block is ready for processing, i.e., all data packets in the block are populated */
	if (is_all_data_pkts_recieved_for_block(currBlockID)) {
#if WHARF_ENCODE_TIMEOUT != 0
		alarm(0);
#endif
		encode_and_forward_block(currBlockID, packet);
	}
	return;
}
