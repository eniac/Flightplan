#include <stdio.h>
#include <stdlib.h>
#include <time.h>

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
	if (workerCt > 1){
		fprintf(stderr, "This booster doesn't work across workers at present\n");
		exit(1);
	}

	u_char *new_packet = NULL;
	int tagged_size = wharf_tag_frame(packet, header->len, &new_packet);

	const struct fec_header *fecHeader = (struct fec_header *) (new_packet + SIZE_ETHERNET);

	if (fecHeader->block_id != lastBlockId){
		lastBlockId = fecHeader->block_id;
		zeroout_block_in_pkt_buffer(lastBlockId);
	}

	if (fecHeader->index < NUM_DATA_PACKETS) {
		forward_frame(new_packet, tagged_size);
		free(new_packet);
	}

	/*Update the received pkt in the pkt buffer.*/
	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == PACKET_ABSENT) {
		FRAME_SIZE_TYPE *original_frame_size = (FRAME_SIZE_TYPE *)(pkt_buffer[fecHeader->block_id][fecHeader->index]);
		*original_frame_size = fecHeader->size;
		memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index] + sizeof(FRAME_SIZE_TYPE), packet, header->len);
		pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = PACKET_PRESENT;
	} else {
		fprintf(stderr, "Tagging produced a duplicate index\n");
		exit(1);
	}

	/*check if the block is ready for processing*/
	if (is_all_data_pkts_recieved_for_block(fecHeader->block_id)) {
		/*populate the global fec structure for rse encoder and call the encode.*/
		call_fec_blk_get(fecHeader->block_id); // FIXME check this

		/* Encoder */
		encode_block();

		int parity_payload_size = copy_parity_packets_to_pkt_buffer(fecHeader->block_id);

		/*Inject all packets in the block back to the network*/
		for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS+NUM_PARITY_PACKETS; i++) {
			tagged_size = wharf_tag_frame((const u_char*)pkt_buffer[fecHeader->block_id][i], parity_payload_size, &new_packet); // We don't encapsulate ethernet header for parity packets
			struct ether_header *packet_eth_header = (struct ether_header *)packet;
			struct ether_header *parity_eth_header = (struct ether_header *)pkt_buffer[fecHeader->block_id][i];
			memcpy(parity_eth_header->ether_dhost, packet_eth_header->ether_dhost, 6);
			memcpy(parity_eth_header->ether_shost, packet_eth_header->ether_shost, 6);
			forward_frame(new_packet, tagged_size);
			free(new_packet);
		}
	}
	return;
}
