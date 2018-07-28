#include <stdlib.h>
#include <unistd.h>
#include <stdarg.h>
#include <signal.h>
#include <stdio.h>
#include <arpa/inet.h>
#include <netinet/ether.h>
#include "fecBooster.h"
#include "fecBoosterApi.h"

// NOTE we only work with a single block because of how we interface with the rse_code function.
#define FB_INDEX 0


struct tclass_buffer {
	/** Buffer into which received and decoded packets are placed */
	u_char pkts[NUM_BLOCKS][TOTAL_NUM_PACKETS][PKT_BUF_SZ];

	/** Size of each packet as it is stored in the buffer */
	size_t pkt_sz[NUM_BLOCKS][TOTAL_NUM_PACKETS];

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

void get_fec_params(tclass_type tclass, fec_sym *k, fec_sym *h) {
	*k = tclasses[tclass].k;
	*h = tclasses[tclass].h;
}

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
		uint16_t flipped = htons(pktSize);
		memcpy(buff, &flipped, sizeof(flipped));
		offset = sizeof(flipped);
	}

	memcpy(buff + offset, packet, pktSize);
	tclasses[tclass].status[blockId][pktIdx] = PACKET_PRESENT;
	tclasses[tclass].pkt_sz[blockId][pktIdx] = pktSize + offset;

	LOG_INFO("Inserted packet %d (size %d) into block %d",
	         (int)pktIdx, (int)(offset + pktSize), (int)blockId);
	LOG_HEX(tclasses[tclass].pkts[blockId][pktIdx], 42);
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
 * @brief Gets a packet directly from the most-recently encoded fbk
 * (Useful for retrieving encoded parity)
 *
 * @param[in] i Index of the packet to be received
 * @param[out] sz_out Filled with the size of the retrieved packet
 *
 * @returns Pointer to the packet in the fbk
 */
u_char *retrieve_encoded_packet(tclass_type tclass, int i, size_t *sz_out) {
	if (sz_out != NULL) {
		*sz_out = (size_t)fbk[FB_INDEX].plen[i];
	}
	LOG_INFO("Retrieving parity %d, len %zu", i, *sz_out);
	LOG_HEX(fbk[FB_INDEX].pdata[i], 32);
	return fbk[FB_INDEX].pdata[i];
}

/**
 * Retrieves the current block ID for the given traffic class
 */
uint8_t get_fec_block_id(tclass_type tclass) {
	return tclasses[tclass].block_id;
}

/**
 * Retrieves the current frame index for the given traffic class
 */
uint8_t get_fec_frame_idx(tclass_type tclass) {
	return tclasses[tclass].frame_idx;
}

/**
 * @brief Checks if a packet has already been inserted into the buffer
 * @returns True if the packet is already inserted
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
static void populate_fec_blk(struct tclass_buffer *buff, int blockId, bool expectParity) {
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
		LOG_HEX(fbk[FB_INDEX].pdata[i], 32);
		/* CBI must be marked even for WANTED packets */
		fbk[FB_INDEX].cbi[i] = i;

		if (buff->status[blockId][i] == PACKET_PRESENT) {
			fbk[FB_INDEX].pstat[i] = FEC_FLAG_KNOWN;

			int payloadLength = buff->pkt_sz[blockId][i];

			fbk[FB_INDEX].plen[i] = payloadLength;

			/* Keep track of maximum packet length to set block_C field of FEC structure */
			if (payloadLength > maxPacketLength) {
				maxPacketLength = payloadLength;
			}
		} else {
			LOG_INFO("WANT data packet %d", i);
			fbk[FB_INDEX].pstat[i] = FEC_FLAG_WANTED;
		}
	}

	/** Block size is greater than max packet length by the number of extra cols in parity */
	fbk[FB_INDEX].block_C = maxPacketLength + FEC_EXTRA_COLS;

	if (h > FEC_MAX_H) {
		LOG_ERR("Number of requested parity packet (%d) > FEC_MAX_H (%d)\n", h, FEC_MAX_H);
		return;
	}
	LOG_INFO("block_C for encoded block set to %d", (int)fbk[FB_INDEX].block_C);

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

				int parity_sz = buff->pkt_sz[blockId][y];
				fbk[FB_INDEX].plen[y] = parity_sz;

				// It is possible that a missing packet is the largest in the frame.
				// In this case, the parity packet size should set block_C
				if (parity_sz > fbk[FB_INDEX].block_C) {
					fbk[FB_INDEX].block_C = parity_sz;
				}

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
 * @brief Advances the index for the next inserted packet in tclass
 *
 * (If resulting frame index is 0, new block has been started)
 *
 * @param[in] tclass Class of packet
 * @return Frame index of new packet
 */
int advance_packet_idx(tclass_type tclass) {
	/* update the block_id and frame_index */
	tclasses[tclass].frame_idx = (tclasses[tclass].frame_idx + 1) % (tclasses[tclass].k);
	if (0 == tclasses[tclass].frame_idx) {
		LOG_INFO("Advancing from block %d", (int)tclasses[tclass].block_id);
		tclasses[tclass].block_id = (tclasses[tclass].block_id + 1) % MAX_BLOCK;
	}
	/* Return the new frame index */
	return tclasses[tclass].frame_idx;
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
 * Adds the ether header and fec tag to a parity packet
 *
 * @param[in] tclass Traffic class to be tagged
 * @param[in] block_id Block of the parity packet
 * @param[in] frame_index Frame index of the parity packet
 * @param[in] packet Data to be encapsulated in the parity packet
 * @param[in] size_in Size of the data above
 * @param[out] out Instantiated array (big enough to hold headers) where packet is placed
 * @param[inout] size_out In: allocated size of `out`, Out: Size actually used
 */
int wharf_tag_parity(tclass_type tclass, int block_id, int frame_index,
                     const u_char *packet, size_t size_in,
                     u_char *out, size_t *size_out) {
	if (size_in >= FRAME_SIZE_CUTOFF) {
		LOG_ERR("Frame too big for tagging (%zu)", size_in);
		return -1;
	}
	if (*size_out < size_in + WHARF_TAG_SIZE) {
		LOG_ERR("Buffer not large enough for wharf tagging");
		return -1;
	}

	// TODO: The rest of this ether_header is junk
	// Need to supply MAC address?
	struct ether_header *eth_header = (struct ether_header*)out;
	eth_header->ether_type = htons(WHARF_ETHERTYPE);

	struct fec_header *tag = (struct fec_header *)(out + sizeof(struct ether_header));
	tag->class_id = tclass;
	tag->block_id = block_id;
	tag->index = frame_index;
	// TODO: This is also sort-of nonsense
	tag->orig_ethertype = htons(WHARF_ETHERTYPE);

	memcpy(out + WHARF_TAG_SIZE, packet, size_in);

	*size_out = size_in + WHARF_TAG_SIZE;
	return 0;
}

/**
 * Adds the fec header and modifies the ether header for a data packet
 *
 * (Also adds the next block/frame index to fec header, then advances frame index)
 *
 * @param[in] tclass Traffic class with which to tag packet
 * @param[in] packet Packet payload to be tagged
 * @param[in] size_in Size of `packet`
 * @param[out] out Array into which to place the tagged packet
 * @param[inout] size_out In: Allocated size of `out`, Out: Size of `out` actually used
 */
int wharf_tag_data(tclass_type tclass,
                   const u_char *packet, size_t size_in,
                   u_char *out, size_t *size_out) {
	if (size_in >= FRAME_SIZE_CUTOFF) {
		LOG_ERR("Frame too big for tagging (%zu)", size_in);
		return -1;
	}

	/* Space for the new headers */
	size_t new_size;

	if (packet == NULL) {
		new_size = WHARF_TAG_SIZE;
	} else {
		new_size = size_in + sizeof(struct fec_header);
	}
	if (*size_out < new_size) {
		LOG_ERR("Buffer not large enough for wharf tag");
		return -1;
	}

	struct ether_header *eth_out = (struct ether_header *)out;
	struct fec_header *fec = (struct fec_header *)(out + sizeof(struct ether_header));

	if (packet != NULL) {
		/* Copy the original ether header and replace the ether_type with wharf_ethertype */
		struct ether_header *eth_orig = (struct ether_header *)packet;
		*eth_out = *eth_orig;
		fec->orig_ethertype = eth_orig->ether_type;
	}
	eth_out->ether_type = htons(WHARF_ETHERTYPE);

	/* Populate the wharf tag with the block_id, packet_id, class, & packetsize */
	fec->class_id = tclass;
	fec->block_id = tclasses[tclass].block_id;
	fec->index = tclasses[tclass].frame_idx;

	// Skip copying the ether_header to the new packet
	// (if it's not a dummy packet)
	if (size_in > 0) {
		size_t offset = sizeof(struct ether_header);
		memcpy(out + sizeof(struct ether_header) + sizeof(struct fec_header),
		       packet + offset, size_in - offset);
	}

	*size_out = new_size;

	advance_packet_idx(tclass);

	return 0;
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

static int n_missing_data(struct tclass_buffer *tcb, int block_id, int k) {
    int n = 0;
    for (int i=0; i < k; i++) {
        if (tcb->status[block_id][i] == PACKET_ABSENT) {
            n++;
        }
    }
    return n;
}

static int n_present_parity(struct tclass_buffer *tcb, int block_id, int k, int h) {
    int n = 0;
    for (int i=k; i < (k + h); i++) {
        if (tcb->status[block_id][i] == PACKET_PRESENT) {
            n++;
        }
    }
    return n;
}


bool can_decode(tclass_type tclass, int block_id) {
    int missing = n_missing_data(&tclasses[tclass], block_id, tclasses[tclass].k);
    int parity = n_present_parity(&tclasses[tclass], block_id,
                                  tclasses[tclass].k, tclasses[tclass].h);
    LOG_INFO("Missing %d packets, received %d parity : can_decode = %d",
             missing, parity, missing <= parity);
    return missing <= parity;
}
