#include <unistd.h>
#include <stdarg.h>
#include <signal.h>
#include <stdio.h>
#include <arpa/inet.h>
#include <netinet/ether.h>
#include "wharf_pcap.h"
#include "fecBooster.h"
#include "fecBoosterApi.h"

// NOTE we only work with a single block because of how we interface with the rse_code function.
#define FB_INDEX 0

static pcap_t *input_handle = NULL;
static pcap_t *output_handle = NULL;

struct tclass_buffer {
	/** Buffer into which received and decoded packets are placed */
	u_char pkts[NUM_BLOCKS][TOTAL_NUM_PACKETS][PKT_BUF_SZ];
	/** Status of packets stored in pkts (present, absent, generated) */
	enum pkt_buffer_status status[NUM_BLOCKS][TOTAL_NUM_PACKETS];

	/** Block ID with which new wharf frames of this class will be tagged */
	uint8_t block_id;
	/** Frame index with which new wharf frames of this class will be tagged */
	uint8_t frame_idx;

	/** Number of packets for this traffic class */
	fec_sym k;
	/** Number of parity packets for this traffic class */
	fec_sym h;
	/** Offset used when calculating cbi of parity (always 0?) */
	fec_sym o;
};

static struct tclass_buffer tclasses[TCLASS_MAX + 1];

/** Sets the parameters k and h for a given traffic class within the fbk */
void set_fec_params(tclass_type tclass, fec_sym k, fec_sym h) {
	tclasses[tclass].k = k;
	tclasses[tclass].h = h;
}

/**
 * @brief Wrapper to invoke encoder
 */
void encode_block(void) {
	int rc;
	if ((rc = rse_code(FB_INDEX, 'e')) != 0 ) {
		LOG_ERR("Could not encode block!");
	} else {
		LOG_INFO("Encoded: ");
	}
	D0(fec_block_print(FB_INDEX));
}

/**
 * @brief Wrapper to invoke the decoder
 *
 * @param[in] tclass Class of traffic to be decoded (determines index in pkt_buffer)
 * @param[in] blockId Used to mark RECOVERED in appropriate index in pkt_buffer_filled
 */
void decode_block(tclass_type tclass, int blockId) {
	int rc;
	if ((rc = rse_code(FB_INDEX, 'd')) != 0 ) {
		LOG_ERR("Could not decode block!");
	} else {
		LOG_INFO("Decoded: ");
	}
	D0(fec_block_print(FB_INDEX));

	for (int i=0; i < tclasses[tclass].k; i++) {
		if (fbk[FB_INDEX].pstat[i] == FEC_FLAG_GENNED) {
			tclasses[tclass].status[blockId][i] = PACKET_RECOVERED;
		}
	}
}

/**
 * @brief Checks that no data packets in the block are marked as ABSENT
 *
 * @param[in] tclass Class of traffic (used to get value for k)
 * @param[in] blockId Block ID to check for absent packets
 *
 * @return true if no absent packets, false otherwise
 */
bool is_all_data_pkts_recieved_for_block(tclass_type tclass, int blockId) {

	for (int i = 0; i < tclasses[tclass].k; i++) {
		if (tclasses[tclass].status[blockId][i] == PACKET_ABSENT) {
			return false;
		}
	}
	return true;
}

/**
 * @brief Marks all packets in provided block as ABSENT
 *
 * @param[in]  tclass  Traffic class (used to index pkt_buffer)
 * @param[in]  blockId  The block identifier
 */
void mark_pkts_absent(tclass_type tclass, int blockId) {
	for (int i = 0; i < TOTAL_NUM_PACKETS; i++) {
		tclasses[tclass].status[blockId][i] = PACKET_ABSENT;
	}
	return;
}

/**
 * @brief Gets the total size of the packet to be placed in fbk
 *
 * @return Size of original packet + sizeof(FRAME_SIZE_TYPE)
 */
static int get_pkt_payload_length(u_char* packet){

	FRAME_SIZE_TYPE *original_frame_size = (FRAME_SIZE_TYPE *)(packet);
	FRAME_SIZE_TYPE flipped = ntohs(*original_frame_size);
	int payloadLength = flipped + sizeof(FRAME_SIZE_TYPE);

	return payloadLength;
}

/**
 * @brief Inserts the packet, tagged with its size, into the packet buffer
 *
 * @param[in] tclass Traffic class of the packet
 * @param[in] blockId ID of the block into which the packet is to be placed
 * @param[in] pktIdx Index of the packet in the block
 * @param[in] pktSize Size of the packet
 * @param[in] packet The packet to be stored
 */
void insert_into_pkt_buffer(tclass_type tclass, int blockId, int pktIdx,
                            FRAME_SIZE_TYPE pktSize, const u_char *packet) {
	size_t offset = 0;

	u_char *buff = tclasses[tclass].pkts[blockId][pktIdx];
	if (pktIdx < tclasses[tclass].k) {
		FRAME_SIZE_TYPE flipped = htons(pktSize);
		memcpy(buff, &flipped, sizeof(pktSize));
		offset += sizeof(pktSize);
	}

	memcpy(buff + offset, packet, pktSize);
	tclasses[tclass].status[blockId][pktIdx] = PACKET_PRESENT;
}

/**
 * @brief Gets the packet from the packet buffer with the size stripped
 *
 * @param[in] tclass Traffic class of the packet
 * @param[in] blockId ID of the packet's block
 * @param[in] pktIdx Index of the packet in the block
 * @param[out] pktSize If a data packet, stores the size of the original packet stored
 *
 * @return The packet with the size stripped off
 */
u_char *retrieve_from_pkt_buffer(tclass_type tclass, int blockId, int pktIdx,
                                 FRAME_SIZE_TYPE *pktSize) {
	size_t offset = 0;
	u_char *buff = tclasses[tclass].pkts[blockId][pktIdx];
	if (pktIdx < tclasses[tclass].k) {
		FRAME_SIZE_TYPE *size_p = (FRAME_SIZE_TYPE *) buff;
		*pktSize = ntohs(*size_p);
		offset = sizeof(*pktSize);
	}
	return buff + offset;
}

/**
 * @brief Checks if a packet has already been inserted into the buffer
 * @returns True if the packet is already inserted
 */
bool pkt_already_inserted(tclass_type tclass, int blockId, int pktIdx) {
	return tclasses[tclass].status[blockId][pktIdx] != PACKET_ABSENT;
}

/**
 * @brief Checks if a packet is marked as recovered
 * @returns True of the packet is RECOVERED
 */
bool pkt_recovered(tclass_type tclass, int blockId, int pktIdx) {
	return tclasses[tclass].status[blockId][pktIdx] == PACKET_RECOVERED;
}

/**
 * @brief Populates the fbk with the packets present in the provided block
 *
 * If expectParity is true, parity packets will be copied to fbk from block.
 * Otherwise, parity packets will be marked as WANTED.
 *
 * @param[in] k Number of data packets
 * @param[in] h Number of parity packets
 * @param[in] o Offset used when calculating cbi of parity
 * @param[in] pkts Buffer containing the packets to be inserted
 * @param[in] pkts_filled Portion of pkt_buffer_filled containing relevant packets
 * @param[in] expectParity Whether to copy parity packets in addition to data packets
 *
 */
static void populate_fec_blk(tclass_buffer *buff, int blockId, bool expectParity) {
	int maxPacketLength = 0;

	fec_sym k = buff->k;
	fec_sym h = buff->h;
	fec_sym o = buff->o;

	fbk[FB_INDEX].block_N = k + h; /*TODO: replace this with a macro later.*/

	if (k > FEC_MAX_K) {
		LOG_ERR("Number of requested data packet (%d) > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
		return;
	}

	/* copy the K data packets from packet buffer */
	for (int i = 0; i < k; i++) {
		/* Regardless of packet presense, point it to the memory in the pkt_buffer.
		 * If the packet is marked as WANTED, RSE will later write the generated packet
		 * to that location */
		fbk[FB_INDEX].pdata[i] = (fec_sym *)buff->pkts[blockId][i];
		/* CBI must be marked even for WANTED packets */
		fbk[FB_INDEX].cbi[i] = i;

		if (buff->status[blockId][i] == PACKET_PRESENT) {
			fbk[FB_INDEX].pstat[i] = FEC_FLAG_KNOWN;

			int payloadLength = get_pkt_payload_length(buff->pkts[blockId][i]);

			fbk[FB_INDEX].plen[i] = payloadLength;

			/* Keep track of maximum packet length to set block_C field of FEC structure */
			if (payloadLength > maxPacketLength) {
				maxPacketLength = payloadLength;
			}
		} else {
			fbk[FB_INDEX].pstat[i] = FEC_FLAG_WANTED;
		}
	}

	/** Block size is greater than max packet length by the number of extra cols in parity */
	fbk[FB_INDEX].block_C = maxPacketLength + FEC_EXTRA_COLS;

	if (h > FEC_MAX_H) {
		LOG_ERR("Number of requested parity packet (%d) > FEC_MAX_H (%d)\n", h, FEC_MAX_H);
		return;
	}

	/* Now populate parity packets, either from the static parity parity buffer, or
	 * the next blocks received in pkt_buffer */
	for (int i = 0; i < h; i++) {

		/* FEC block index */
		int y = k + i;

		/* Codeword index */
		fbk[FB_INDEX].cbi[y] = FEC_MAX_N - o - i - 1;

		if (expectParity) {
			/* If parity should be in the pkt_buffer */
			if (buff->status[blockId][y] == PACKET_PRESENT) {
				fbk[FB_INDEX].pdata[y] = (fec_sym *)buff->pkts[blockId][y];
				fbk[FB_INDEX].pstat[y] = FEC_FLAG_KNOWN;
				fbk[FB_INDEX].plen[y] = fbk[FB_INDEX].block_C;
			} else {
				/* If it should be, but is not */
				fbk[FB_INDEX].pstat[y] = FEC_FLAG_IGNORE;
			}
		} else {
			/* Otherwise, mark the parity packets as WANTED */
			fbk[FB_INDEX].pdata[y] = (fec_sym *)buff->pkts[blockId][y];
			fbk[FB_INDEX].pstat[y] = FEC_FLAG_WANTED;
			fbk[FB_INDEX].plen[y] = fbk[FB_INDEX].block_C;
		}
	}
}

/**
 * @brief Populates the fec block with the data packets from pkt_buffer
 *
 * Marks the parity packets as WANTED, so they will be generated on next call to encode.
 *
 * @param[in] tclass Traffic class with which to populate fbk
 * @param[in] blockId The block of pkt_buffer from which to populate the fbk
 */
int populate_fec_blk_data(tclass_type tclass, int blockId) {
	LOG_INFO("Populating fec block with class %d, block %d", tclass, blockId);
	populate_fec_blk(&tclasses[tclass], blockId, false);

	return 0;
}

/**
 * @brief Populates the fec block with both data _and_ parity packets from buffer
 *
 * Missing parity packets are marked as IGNORE.
 *
 * @param[in] tclass Traffic class from which to populate fbk
 * @param[in] blockId The block of pkt_buffer from which to populate the fbk
 */
int populate_fec_blk_data_and_parity(tclass_type tclass, int blockId) {
	LOG_INFO("Populating fec block with class %d, block %d", tclass, blockId);
	populate_fec_blk(&tclasses[tclass], blockId, true);

	return 0;
}

/**
 * @brief Copies parity packets from fbk to pkt_buffer
 *
 * @param[in] tclass Traffic class to which packets belong
 * @param[in] blockId block into which packets are copied
 *
 * @return Size of each individual parity packet
 */
int copy_parity_packets_to_pkt_buffer(tclass_type tclass, int blockId) {

	struct tclass_buffer *tc = &tclasses[tclass];

	fec_sym k = tc->k;
	fec_sym h = tc->h;
	int sizeOfParityPackets = fbk[FB_INDEX].plen[k];

	for (int i = k; i < (k + h); i++) {
		memcpy(tc->pkts[blockId][i], fbk[FB_INDEX].pdata[i], sizeOfParityPackets);
		tc->status[blockId][i] = PACKET_PRESENT;
	}
	return sizeOfParityPackets;
}

/**
 * @brief Advances the block id for new wharf frames and resets frame index
 *
 * @return New block ID
 */
int advance_block_id(tclass_type tclass) {
	tclasses[tclass].block_id = (tclasses[tclass].block_id + 1) % MAX_BLOCK;
	tclasses[tclass].frame_idx = 0;
	return tclasses[tclass].block_id;
}


/**
 * @brief Encapsulate the packet with new header.
 *
 * The new resulting packet looks like NEW_ETH_HEADER | WHARF_TAG | oldPacket w/o eth_header
 *
 * If the tagged packet is a parity packet, ether_header is not removed
 * (it does not exist to begin with)
 *
 * @param[in] tclass Class of the wharf frame, indicating parity ratio
 * @param[in] packet Packet data to be encapsulated
 * @param[out] result Pointer to buffer which will be allocated and filled with the encapsulation
 *
 * @return resulting size of the newly encapsulated packet.
 */
int wharf_tag_frame(tclass_type tclass, const u_char* packet, int size, u_char** result) {
	if (size >= FRAME_SIZE_CUTOFF) {
		LOG_ERR("Frame too big for tagging (%d)", size);
		return -1;
	}
	struct ether_header *orig_eth_header = (struct ether_header *)packet;

	fec_sym k = tclasses[tclass].k;
	fec_sym h = tclasses[tclass].h;

	/* make space for the new header to be added */
	const int extra_header_size = sizeof(struct ether_header) + sizeof(struct fec_header);
	*result = (u_char *)malloc(size + extra_header_size);

	/* Copy the original ether header and replace the ether_type with wharf_ethertype*/
	struct ether_header *eth_header = (struct ether_header *)*result;
	*eth_header = *orig_eth_header;
	eth_header->ether_type=htons(WHARF_ETHERTYPE);

	/* Populate the wharf tag with the block_id, packet_id, class, & packetsize*/
	struct fec_header *tag = (struct fec_header *)(*result + sizeof(struct ether_header));
	tag->class_id = tclass;
	tag->block_id = tclasses[tclass].block_id;
	tag->index = tclasses[tclass].frame_idx;

	/* Populate the wharf tag with the packet's ethertype */
	tag->orig_ethertype = orig_eth_header->ether_type;

	size_t offset = 0;
	/* If it's a data packet, don't copy the ether header */
	if (tag->index < k && size > 0) {
		offset = sizeof(struct ether_header);
	}

	/* Copy over the original packet as is.*/
	if (size > 0) {
		memcpy(*result + extra_header_size, packet + offset, size - offset);
	}

	/* update the block_id and frame_index */
	tclasses[tclass].frame_idx = (tclasses[tclass].frame_idx + 1) % (k + h);
	if (0 == tclasses[tclass].frame_idx) {
		tclasses[tclass].block_id = (tclasses[tclass].block_id + 1) % MAX_BLOCK;
	}

	return size + extra_header_size - offset;
}

/**
 * @brief Gets the pointer to the original packet within the tagged frame.
 *
 * NOTE: If a data packet, modifies the packet to restore the ether header
 * prior to the data.
 *
 * @param[in] packet Encapsulated packet
 * @param[inout] size Total size of received packet in, packet payload size out
 *
 * @return Pointer to the stripped packet (within the tagged frame)
 */
const u_char *wharf_strip_frame(const u_char* packet, int *size) {
	/* It's necessary to make a copy of the eth_header because we may write
	 * over this memory later */
	struct ether_header eth_header = *(struct ether_header *)packet;
	/*If not a wharf encoded packet*/
	if (htons(WHARF_ETHERTYPE) != eth_header.ether_type) {
		LOG_ERR("Cannot strip non-warf frame");
		return 0;
	}

	struct fec_header fec_hdr = *(struct fec_header *)(packet + sizeof(struct ether_header));

	struct ether_header *pkt_ether = (struct ether_header *)(packet + sizeof(fec_hdr));

	if (*size == sizeof(fec_hdr) + sizeof(eth_header)) {
		*size = 0;
		return packet + sizeof(fec_hdr) + sizeof(eth_header);
	}

	size_t offset = sizeof(struct fec_header);
	if (fec_hdr.index < tclasses[fec_hdr.class_id].k) {
		*pkt_ether = eth_header;
		pkt_ether->ether_type = fec_hdr.orig_ethertype;
	} else {
		offset += sizeof(struct ether_header);
	}

	*size = *size - offset;
	return packet + offset;
}

/**
 * @brief Forwards the provided frame to the configured output pcap handle.
 *
 * @param[in] packet Packet data to be send on the output interface
 * @param[in] len Size of the provided packet
 */
void forward_frame(const void * packet, int len) {
	if (NULL != output_handle) {
		pcap_inject(output_handle, packet, len);
	} else {
		pcap_inject(input_handle, packet, len);
	}
}

static void sigalrm_handler(int signal) {
	pcap_breakloop(input_handle);
}

int main (int argc, char** argv) {
	char* inputInterface = NULL;
	char* outputInterface = NULL;
	int opt = 0;
	int rc;

	/* initialize fec codewords */
	if ((rc = rse_init()) != 0 ) exit(rc);

	while ((opt = getopt(argc, argv, "i:o:w:t:r:")) != -1)
	{
		switch (opt)
		{
		case 'i':
			printf("inputInterface: %s\n",optarg);
			inputInterface = optarg;
			break;
		case 'o':
			printf("outputInterface: %s\n",optarg);
			outputInterface = optarg;
			break;
		case 'w':
			fprintf(stderr, "Warning: worker ID is unused\n");
			break;
		case 't':
			fprintf(stderr, "Warning: Worker Count is unused\n");
			break;
		case 'r':
			printf("Loading rules from file: %s\n", optarg);
			if (wharf_load_from_file(optarg) != 0) {
				abort();
			}
			break;
		default:
			printf("\nNot yet defined opt = %d\n", opt);
			abort();
		}
	}

	if (NULL == inputInterface) {
		LOG_ERR("Need -i at least -i parameter");
		fprintf(stderr, "Usage: %s -i input [-o output] [-w workerId] [-t workerCt]\n", argv[0]);
		exit(1);
	}

	if (NULL != outputInterface) {
		char output_error_buffer[PCAP_ERRBUF_SIZE];
		output_handle = pcap_open_live(outputInterface, BUFSIZ, 0, 0, output_error_buffer);
		if (output_handle == NULL) {
			LOG_ERR("Could not open device %s: %s", outputInterface, output_error_buffer);
			exit(1);
		}
	}

	char input_error_buffer[PCAP_ERRBUF_SIZE];
	input_handle = pcap_open_live(
				inputInterface,
				BUFSIZ,
				1, /*set device to promiscous*/
				0, /*Timeout of 0*/
				input_error_buffer
			);
	if (input_handle == NULL) {
		LOG_ERR("Could not open device %s: %s\n", inputInterface, input_error_buffer);
		exit(1);
	}

	// Alarm handler will signal the pcap loop to break
	signal(SIGALRM, sigalrm_handler);

	while (1) {
		alarm(1);
		// Execute the pcap loop for 1 second, then break and call the timeout handler
		pcap_loop(input_handle, 0, my_packet_handler, NULL);
		LOG_INFO("Handled alarm...");
		booster_timeout_handler();
	}
}
