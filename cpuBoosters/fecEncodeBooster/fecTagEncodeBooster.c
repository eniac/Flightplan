#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <net/ethernet.h>

#include "fecBooster.h"

int lastBlockId = 0;
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
	if (workerCt > 1) {
		fprintf(stderr, "This booster doesn't work across workers at present\n");
		exit(1);
	}

	u_char *new_packet = NULL;
	/*Add a wharf and new ether tag to the original packet. Preprocessing step */
	int tagged_size = wharf_tag_frame(packet, header->len, &new_packet);

	const struct fec_header *fecHeader = (struct fec_header *) (new_packet + SIZE_ETHERNET);

	/*storing these values, since new_packet is freed later.*/
	int currBlockID = fecHeader->block_id;
	int currPktIdx = fecHeader->index;
	int currOriginalSize = fecHeader->size;

	/* If this packet belongs to a new block */
	if (fecHeader->block_id != lastBlockId) {
		lastBlockId = fecHeader->block_id;
		zeroout_block_in_pkt_buffer(lastBlockId);
	}

	/* Forward data packet now, then buffer it below (Needed for encoder) */
	if (fecHeader->index < NUM_DATA_PACKETS) {
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
		fprintf(stderr, "Tagging produced a duplicate index\n");
		exit(1);
	}

	/* Check if the block is ready for processing, i.e., all data packets in the block are populated */
	if (is_all_data_pkts_recieved_for_block(currBlockID)) {

		/* Populate the global fec structure for rse encoder and call the encode */
		call_fec_blk_get(currBlockID); // FIXME check this

		/* Encoder */
		encode_block();

		int parity_payload_size = copy_parity_packets_to_pkt_buffer(currBlockID);

		/* Inject all parity packets in the block to the network */
		for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS + NUM_PARITY_PACKETS; i++) {
			tagged_size = wharf_tag_frame((u_char*)pkt_buffer[currBlockID][i], parity_payload_size, &new_packet); // We don't encapsulate ethernet header for parity packets
			struct ether_header *packet_eth_header = (struct ether_header *)packet;
			struct ether_header *parity_eth_header = (struct ether_header *)new_packet;
			
			/* Copy over the src and dst mac from the last data packet in the block
			 * to the newpacket's newly added ether header */
			memcpy(parity_eth_header->ether_dhost, packet_eth_header->ether_dhost, ETHER_ADDR_LEN);
			memcpy(parity_eth_header->ether_shost, packet_eth_header->ether_shost, ETHER_ADDR_LEN);
			
			forward_frame(new_packet, tagged_size);
			free(new_packet);
		}
	}
	return;
}
