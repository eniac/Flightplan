#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"

int lastBlockId = 0;
int lastPacketId = 0;
/**
 * @brief      packet handler function for pcap
 *
 * @param      args    The arguments
 * @param[in]  header  The header
 * @param[in]  packet  The packet
 *
 * Packets in a block can be reordered, but blocks must not have their packets mixed:
 * this code gets confused if packets of one block appear while the code is encoding another,
 * and unless is_all_pkts_recieved_for_block()==true then the parity packets won't be sent out.
 */
void my_packet_handler(
    u_char *args,
    const struct pcap_pkthdr *header,
    const u_char *packet
) {
	const struct fec_header *fecHeader = (fec_header_t *) (packet + SIZE_ETHERNET);

	// skip blocks that don't belong to this worker.
	if ((fecHeader->block_id) % workerCt != workerId){
		return;
	}

	if (fecHeader->block_id != lastBlockId){
		lastBlockId = fecHeader->block_id;
		zeroout_block_in_pkt_buffer(lastBlockId);
	} else if (fecHeader->index < lastPacketId){
		// Hack for rollover correctness in benchmarks.
		zeroout_block_in_pkt_buffer(lastBlockId);
	}
	lastPacketId = fecHeader->index;

	if (fecHeader->index < NUM_DATA_PACKETS){
		pcap_inject(handle, packet, header->len);
	}

	/*Update the received pkt in the pkt buffer.*/
	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == 0) {
		memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
		pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = 1;
	} 
	else { /*This is not good*/
		// The block is invalid -- don't bother processing.
		zeroout_block_in_pkt_buffer(lastBlockId);
		// memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
		// pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = 1;
		// printf("(%i) ERROR: Overwriting existing packet @ %i:%i \n",workerId,fecHeader->block_id, fecHeader->index);
	}

	/*check if the block is ready for processing*/
	if (is_all_pkts_recieved_for_block(fecHeader->block_id) == true) {
		/*populate the global fec structure for rse encoder and call the encode.*/
		call_fec_blk_get(fecHeader->block_id);

#ifndef FEC_ENCODE_BOOSTER_BASELINE
		/* Encoder */
		encode_block();

		copy_parity_packets_to_pkt_buffer(fecHeader->block_id);
#endif // FEC_ENCODE_BOOSTER_BASELINE

		/*Inject all packets in the block back to the network*/
		for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS+NUM_PARITY_PACKETS; i++) {
			char* packetToInject = pkt_buffer[fecHeader->block_id][i];
			size_t outPktLen = get_total_packet_size(packetToInject);
			pcap_inject(handle, packetToInject, outPktLen);
		}
	}
	return;
}
