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

	int pktId = get_packet_index_in_blk(packet);
	int blockId = get_block_index_of_pkt(packet);


	// TODO: Invalidate block before starting it.
	if (blockId != lastBlockId){
		lastBlockId = blockId;
		invalidate_block_in_pkt_buffer(lastBlockId);
	}
	// Hack for rollover correctness in benchmarks.
	if (pktId < lastPacketId){
		invalidate_block_in_pkt_buffer(lastBlockId);
	}
	lastPacketId = pktId;


	// TODO: If the packet is a data packet, send it back out asap. 
	if (pktId < NUM_DATA_PACKETS){
		pcap_inject(handle, packet, header -> len);
	}

	/*Update the received pkt in the pkt buffer.*/
	if (pkt_buffer_filled[blockId][pktId] == 0) {

		// TODO: copy packet to buffer.
		memcpy(pkt_buffer[blockId][pktId], packet, header->len);
		pkt_buffer_filled[blockId][pktId] = 1;
		// pkt_buffer[blockId][pktId] = (char* )packet;
	} 
	else { /*This is not good*/
		// The block is invalid -- don't bother processing.
		invalidate_block_in_pkt_buffer(lastBlockId);		
		// memcpy(pkt_buffer[blockId][pktId], packet, header->len);
		// pkt_buffer_filled[blockId][pktId] = 1;
		// printf("(%i) ERROR: Overwriting existing packet @ %i:%i \n",workerId,blockId, pktId);			
	}
//(	fec_dbg_printf)("The header len is ::::: %d\n", header->len);
	/*check if the block is ready for processing*/
	if (is_all_pkts_recieved_for_block(blockId) == true) {
		/*populate the global fec structure for rse encoder and call the encode.*/
		call_fec_blk_get(blockId);

#ifdef FEC_ENCODE_BOOSTER_BASELINE
		/* Encoder */
		encode_block();

		copy_parity_packets_to_pkt_buffer(blockId);
#endif // FEC_ENCODE_BOOSTER_BASELINE

		// TODO: disable packet loss and decoder blocks in the encoder.
		// /* Simulate loss of packets */
		// simulate_packet_loss();

		// /* Decoder */
		// decode_block();

		/*Inject all packets in the block back to the network*/

		// TODO: only inject the parity packets.
		// printf("after encode call.\n");
		for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS+NUM_PARITY_PACKETS; i++) {
			char* packetToInject = pkt_buffer[blockId][i];
			size_t outPktLen = get_total_packet_size(packetToInject);
			pcap_inject(handle, packetToInject, outPktLen);

			// if (i >= NUM_DATA_PACKETS) {
			// 	free_parity_memory(packetToInject);
			// }
		}

		/*Lastly just invalidate the block in the buffer*/
		// invalidate_block_in_pkt_buffer(blockId);
	}
	return;
}
