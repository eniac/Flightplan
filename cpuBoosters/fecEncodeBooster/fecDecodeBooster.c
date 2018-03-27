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
//	const struct fec_header *fecHeader = (fec_header_t *) (packet + SIZE_ETHERNET);
//
//	// skip blocks that don't belong to this worker.
//	if ((fecHeader->block_id) % workerCt != workerId){
//		return;
//	}
//
//	// TODO: Invalidate block before starting it.
//	if (fecHeader->block_id != lastBlockId){
//		lastBlockId = fecHeader->block_id;
//		invalidate_block_in_pkt_buffer(lastBlockId);
//	}
//	// Hack for rollover correctness in benchmarks.
//	if (fecHeader->index < lastPacketId){
//		invalidate_block_in_pkt_buffer(lastBlockId);
//	}
//	lastPacketId = fecHeader->index;
//
//
//	// TODO: If the packet is a data packet, send it back out asap. 
//	if (fecHeader->index < NUM_DATA_PACKETS){
//		pcap_inject(handle, packet, header -> len);
//	}
//
//	/*Update the received pkt in the pkt buffer.*/
//	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == 0) {
//
//		// TODO: copy packet to buffer.
//		memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
//		pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = 1;
//		// pkt_buffer[fecHeader->block_id][fecHeader->index] = (char* )packet;
//	} 
//	else { /*This is not good*/
//		// The block is invalid -- don't bother processing.
//		invalidate_block_in_pkt_buffer(lastBlockId);		
//		// memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
//		// pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = 1;
//		// printf("(%i) ERROR: Overwriting existing packet @ %i:%i \n",workerId,fecHeader->block_id, fecHeader->index);
//	}
////(	fec_dbg_printf)("The header len is ::::: %d\n", header->len);
//	/*check if the block is ready for processing*/
//	if (is_all_pkts_recieved_for_block(fecHeader->block_id) == true) {
//		/*populate the global fec structure for rse encoder and call the encode.*/
//		call_fec_blk_get(fecHeader->block_id);
//
//		/* Decoder */
//		decode_block();
//
//		/*Inject all packets in the block back to the network*/
//
//		// TODO: only inject the parity packets.
//		// printf("after encode call.\n");
//		for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS+NUM_PARITY_PACKETS; i++) {
//			char* packetToInject = pkt_buffer[fecHeader->block_id][i];
//			size_t outPktLen = get_total_packet_size(packetToInject);
//			pcap_inject(handle, packetToInject, outPktLen);
//
//			// if (i >= NUM_DATA_PACKETS) {
//			// 	free_parity_memory(packetToInject);
//			// }
//		}
//
//		/*Lastly just invalidate the block in the buffer*/
//		// invalidate_block_in_pkt_buffer(fecHeader->block_id);
//	}
//	return;
}
