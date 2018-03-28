#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"

// Try to decode new packets, and forward them on.
void decode_and_forward(const struct fec_header *fecHeader) {
	// FIXME when decode is run, find out what "new" packets we have and forward them. then the buffer is made available to another block_id


	if (is_all_pkts_recieved_for_block(fecHeader->block_id) == true) {
		return; // Since no need to decode
	}

	/*populate the global fec structure for rse encoder and call the encode.*/
	call_fec_blk_get(fecHeader->block_id);

	decode_block();

	// FIXME only inject recovered data packets into the network
	for (int i = NUM_DATA_PACKETS; i < NUM_DATA_PACKETS+NUM_PARITY_PACKETS; i++) {
		char* packetToInject = pkt_buffer[fecHeader->block_id][i];
		size_t outPktLen = get_total_packet_size(packetToInject);
		pcap_inject(handle, packetToInject, outPktLen);
	}
}


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
	// FIXME check ethertype; proceed if it's Wharf

	const struct fec_header *fecHeader = (fec_header_t *) (packet + SIZE_ETHERNET);

	// skip blocks that don't belong to this worker.
	if ((fecHeader->block_id) % workerCt != workerId){
		return;
	}

	// FIXME examine Wharf tag further: if next block_id started then run decode on what we have so far, see what can be retrieved.
	if (fecHeader->block_id != lastBlockId){
		decode_and_forward(fecHeader);
		lastBlockId = fecHeader->block_id;
		// FIXME set/refresh timer on arrival of new block_id: when timer expires then run decode.
	}

	// FIXME examine Wharf tag further: if packet is a parity then buffer it; if it's a data packet then buffer it, strip the tag and forward. Strip tag before buffering (for decoding).

	if (fecHeader->index < NUM_DATA_PACKETS){
		// FIXME strip tag
		pcap_inject(handle, packet, header->len);
	}

	/*Update the received pkt in the pkt buffer.*/
	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == 0) {

		memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
		pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = 1;
	}
	else {
		fprintf(stderr, "Received duplicate packet\n");
	}
}
