#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"

bool nothing_to_decode = true; // This is true when the buffer doesn't contain any packets for decoding.
int lastBlockId = 0;

// Try to decode new packets, and forward them on.
// FIXME possible race condition if have simultaneous timer expiry and a packet arrival that also triggers the decode.
void decode_and_forward(const int block_id) {
	if (nothing_to_decode || is_all_pkts_recieved_for_block(block_id)) {
		return;
	}

	decode_block();

	copy_data_packets_to_pkt_buffer(block_id);

	for (int i = 0; i < NUM_DATA_PACKETS; i++) {
		if (pkt_buffer_filled[block_id][i] == PACKET_RECOVERED) {
			char* packetToInject = pkt_buffer[block_id][i];
			size_t outPktLen = get_total_packet_size(packetToInject);
			pcap_inject(handle, packetToInject, outPktLen); // FIXME use forwarding function
		}
	}

	nothing_to_decode = true;
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
	// FIXME check ethertype; proceed if it's Wharf

	const struct fec_header *fecHeader = (fec_header_t *) (packet + SIZE_ETHERNET);

	// skip blocks that don't belong to this worker.
	if ((fecHeader->block_id) % workerCt != workerId){
		return;
	}

	if (fecHeader->block_id != lastBlockId) {
		decode_and_forward(fecHeader->block_id);
		lastBlockId = fecHeader->block_id;
		// FIXME set/refresh timer on arrival of new block_id: when timer expires then run decode.
	}

	// Forward data packets immediately
	if (fecHeader->index < NUM_DATA_PACKETS){
		// FIXME strip tag; and use forwarding function
		pcap_inject(handle, packet, header->len);
	}

	// Buffer data and parity packets in case need to decode.
	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == PACKET_ABSENT) {
		nothing_to_decode = false;
		memcpy(pkt_buffer[fecHeader->block_id][fecHeader->index], packet, header->len);
		pkt_buffer_filled[fecHeader->block_id][fecHeader->index] = PACKET_PRESENT;
	}
	else {
		fprintf(stderr, "Received duplicate packet\n");
	}
}
