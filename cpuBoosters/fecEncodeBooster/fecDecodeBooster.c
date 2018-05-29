#include <arpa/inet.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "fecBooster.h"

bool nothing_to_decode = true; // This is true when the buffer doesn't contain any packets for decoding.
int lastBlockId = 0;

inline void reset_decoder (const int block_id) {
	nothing_to_decode = true;
	zeroout_block_in_pkt_buffer(block_id);
}

// Try to decode new packets, and forward them on.
// FIXME possible race condition if have simultaneous timer expiry and a packet arrival that also triggers the decode.
void decode_and_forward(const int block_id) {
	if (nothing_to_decode || is_all_data_pkts_recieved_for_block(block_id)) {
		reset_decoder (block_id);
		printf("Received all data packets for blockID :: %d Skipping calling decode\n", block_id);
		return;
	}

	call_fec_blk_put(block_id);

	// Decode inserts the packets directly into pkt_buffer
	decode_block(block_id);

#if WHARF_DEBUGGING
	int num_recovered_packets = 0;
#endif // WHARF_DEBUGGING
	for (int i = 0; i < NUM_DATA_PACKETS; i++) {
		if (pkt_buffer_filled[block_id][i] == PACKET_RECOVERED) {
			num_recovered_packets += 1;

			char* packetToInject = pkt_buffer[block_id][i] + sizeof(FRAME_SIZE_TYPE);
			FRAME_SIZE_TYPE *size_p = (FRAME_SIZE_TYPE*)pkt_buffer[block_id][i];
			// Recovered packet may have a length of 0, if it was filler
			// In this case, no need to forward
			if (*size_p > 0) {
				forward_frame(packetToInject, *size_p);
			}
		}
	}

#if WHARF_DEBUGGING
	printf("num_recovered_packets=%d\n", num_recovered_packets); // FIXME this is always printing the total number of data packets in the block.
#endif // WHARF_DEBUGGING

	reset_decoder (block_id);
}


#if WHARF_DECODE_TIMEOUT != 0
void sigalrm_handler(int signal) {
	if (signal != SIGALRM) {
		fprintf(stderr, "Unexpected signal: %d\n", signal);
		exit(1);
	}

	decode_and_forward(lastBlockId); // FIXME ensure the function is reentrant
}
#endif // WHARF_DECODE_TIMEOUT != 0

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

	enum traffic_class tclass = one;
	struct ether_header *eth_header = (struct ether_header *)packet;
	if (WHARF_ETHERTYPE != ntohs(eth_header->ether_type)) {
		fprintf(stderr, "Received untagged frame -- ignoring\n");
		return;
	}
	const struct fec_header *fecHeader = (struct fec_header *)(packet + sizeof(struct ether_header));

#if WHARF_DEBUGGING
	printf("class_id=%d block_id=%d index=%d size=%d\n", fecHeader->class_id, fecHeader->block_id,
	       fecHeader->index, fecHeader->size);
#endif // WHARF_DEBUGGING

	if (fecHeader->block_id != lastBlockId) {
		decode_and_forward(lastBlockId);
		lastBlockId = fecHeader->block_id;
#if WHARF_DECODE_TIMEOUT != 0
		alarm(WHARF_DECODE_TIMEOUT);
		signal(SIGALRM, sigalrm_handler);
#endif // WHARF_DECODE_TIMEOUT != 0
	}

	// Forward data packets immediately
	if (fecHeader->index < NUM_DATA_PACKETS) {
		// If there is no data outside of the wharf frame, no need to forward (packet was filler)
		if (header->len > WHARF_ORIG_FRAME_OFFSET) {
			forward_frame(packet + WHARF_ORIG_FRAME_OFFSET,
			              header->len - WHARF_ORIG_FRAME_OFFSET); // This also strips the Wharf tag.
		}
	}

	// Buffer data and parity packets in case need to decode.
	if (pkt_buffer_filled[fecHeader->block_id][fecHeader->index] == PACKET_ABSENT) {
		nothing_to_decode = false;
		u_char *untagged_packet = (u_char *) packet;

		/*Passing this, although we know what the size is*/
		int tagged_size = fecHeader->size + WHARF_ORIG_FRAME_OFFSET;

		/*storing these values,before stripping the tag.*/
		int currBlockID = fecHeader->block_id;
		int currPktIdx = fecHeader->index;

		/*First strip the wharf tag and copy the packet to the packet buffer*/
		int untagged_size = wharf_strip_frame(&tclass, untagged_packet, tagged_size);
		
		/* prepend the packet length for data packets.*/
		if (currPktIdx < NUM_DATA_PACKETS) {
			FRAME_SIZE_TYPE *original_frame_size = (FRAME_SIZE_TYPE *)(pkt_buffer[currBlockID][currPktIdx]);
			*original_frame_size = untagged_size;
			memcpy(pkt_buffer[currBlockID][currPktIdx] + sizeof(FRAME_SIZE_TYPE), untagged_packet, untagged_size);
		} else { /*For parity packets, do not prepend the length*/
			memcpy(pkt_buffer[currBlockID][currPktIdx], untagged_packet, untagged_size);
		}

		pkt_buffer_filled[currBlockID][currPktIdx] = PACKET_PRESENT;
	}
	else {
		fprintf(stderr, "Not buffering duplicate packet\n");
	}
}
