
#include <stdarg.h>
#include <stdio.h>
#include <arpa/inet.h>
#include "fecBooster.h"
#include "wharf_pcap.h"

// NOTE we only work with a single block because of how we interface with the rse_code function.
#define FB_INDEX 0

pcap_t *input_handle = NULL;
pcap_t *output_handle = NULL;

/** Global buffer into which received and decoded packets will be placed */
char pkt_buffer[NUM_BLOCKS][TOTAL_NUM_PACKETS][PKT_BUF_SZ];
/** Status of packets stored in global buffer */
enum pkt_buffer_status pkt_buffer_filled[NUM_BLOCKS][TOTAL_NUM_PACKETS];

/**
 * @brief Wrapper to invoke encoder
 */
void encode_block(void) {
	int rc;
	if ((rc = rse_code(FB_INDEX, 'e')) != 0 ) {
		D0(fprintf(stderr, "\nCould not encode block: "));
	} else {
		D0(fprintf(stderr, "\nEncoded: "));
	}
	D0(fec_block_print(FB_INDEX));
}

/**
 * @brief Wrapper to invoke the decoder
 *
 * @param[in] blockId Used to mark RECOVERED in appropriate index in pkt_buffer_filled
 */
void decode_block(int blockId) {
	int rc;
	if ((rc = rse_code(FB_INDEX, 'd')) != 0 ) {
		D0(fprintf(stderr, "\nCould not decode block: "));
	} else {
		D0(fprintf(stderr, "\nDecoded: "));
	}
	D0(fec_block_print(FB_INDEX));
	for (int i=0; i < NUM_DATA_PACKETS; i++) {
		if (fbk[FB_INDEX].pstat[i] == FEC_FLAG_GENNED) {
			pkt_buffer_filled[blockId][i] = PACKET_RECOVERED;
		}
	}
}

/**
 * @brief Checks that no data packets in the block are marked as ABSENT
 *
 * @param[in] blockId Block ID to check for absent packets
 *
 * @return true if no absent packets, false otherwise
 */
bool is_all_data_pkts_recieved_for_block(int blockId) {
	for (int i = 0; i < NUM_DATA_PACKETS; i++) {
		if (pkt_buffer_filled[blockId][i] == PACKET_ABSENT) {
			return false;
		}
	}
	return true;
}

/**
 * @brief Marks all packets in provided block as ABSENT
 *
 * @param[in]  blockId  The block identifier
 */
void mark_pkts_absent(int blockId) {
	for (int i = 0; i < TOTAL_NUM_PACKETS; i++) {
		pkt_buffer_filled[blockId][i] = PACKET_ABSENT;
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
	int payloadLength = *original_frame_size + sizeof(FRAME_SIZE_TYPE);

	return payloadLength;
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
 * @param[in] blockId Block to be copied to fbk
 * @param[in] expectParity Whether to copy parity packets in addition to data packets
 *
 */
static void populate_fec_blk(fec_sym k, fec_sym h, fec_sym o,
                             int blockId, bool expectParity) {
	int maxPacketLength = 0;
	fbk[FB_INDEX].block_N = k + h; /*TODO: replace this with a macro later.*/

	if (k > FEC_MAX_K) {
		fprintf(stderr, "Number of Requested data packet (%d) > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
		exit (33);
	}

	/* copy the K data packets from packet buffer */
	for (int i = 0; i < k; i++) {
		/* Regardless of packet presense, point it to the memory in the pkt_buffer.
		 * If the packet is marked as WANTED, RSE will later write the generated packet
		 * to that location */
		fbk[FB_INDEX].pdata[i] = (fec_sym *)pkt_buffer[blockId][i];
		/* CBI must be marked even for WANTED packets */
		fbk[FB_INDEX].cbi[i] = i;

		if (pkt_buffer_filled[blockId][i] == PACKET_PRESENT) {
			fbk[FB_INDEX].pstat[i] = FEC_FLAG_KNOWN;

			int payloadLength = get_pkt_payload_length((u_char *)pkt_buffer[blockId][i]);

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
		fprintf(stderr, "Number of Requested parity packet (%d) > FEC_MAX_H (%d)\n", h, FEC_MAX_H);
		exit (34);
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
			if (pkt_buffer_filled[blockId][y] == PACKET_PRESENT) {
				fbk[FB_INDEX].pdata[y] = (fec_sym *)pkt_buffer[blockId][y];
				fbk[FB_INDEX].pstat[y] = FEC_FLAG_KNOWN;
				fbk[FB_INDEX].plen[y] = fbk[FB_INDEX].block_C;
			} else {
				/* If it should be, but is not */
				fbk[FB_INDEX].pstat[y] = FEC_FLAG_IGNORE;
			}
		} else {
			/* Otherwise, mark the parity packets as WANTED */
			fbk[FB_INDEX].pdata[y] = (fec_sym *)pkt_buffer[blockId][y];
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
 * @param[in] blockId The block of pkt_buffer from which to populate the fbk
 */
void populate_fec_blk_data(int blockId) {

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	fec_sym k = NUM_DATA_PACKETS;
	fec_sym h = NUM_PARITY_PACKETS;
	fec_sym o = 0;
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

	populate_fec_blk(k, h, o, blockId, false);
}

/**
 * @brief Populates the fec block with both data _and_ parity packets from buffer
 *
 * Missing parity packets are marked as IGNORE.
 *
 * @param[in] blockId The block of pkt_buffer from which to populate the fbk
 */
void populate_fec_blk_data_and_parity(int blockId) {
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	fec_sym k = NUM_DATA_PACKETS;
	fec_sym h = NUM_PARITY_PACKETS;
	fec_sym o = 0;
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

	populate_fec_blk(k, h, o, blockId, true);
}

/**
 * @brief Copies parity packets from fbk to pkt_buffer
 *
 * @param[in] blockId block into which packets are copied
 *
 * @return Size of each individual parity packet
 */
int copy_parity_packets_to_pkt_buffer(int blockId) {
	int startIndexOfParityPacket = NUM_DATA_PACKETS;
	int sizeOfParityPackets = fbk[FB_INDEX].plen[startIndexOfParityPacket];

	for (int i = startIndexOfParityPacket; i < (startIndexOfParityPacket + NUM_PARITY_PACKETS); i++) {
		memcpy(pkt_buffer[blockId][i], fbk[FB_INDEX].pdata[i], sizeOfParityPackets);
		pkt_buffer_filled[blockId][i] = PACKET_PRESENT;
	}
	return sizeOfParityPackets;
}

/** Block ID with which new wharf frames will be tagged */
static unsigned int block_id = 0;
/** Frame index with which new wharf frames will be tagged */
static unsigned int frame_index = 0;

/**
 * @brief Advances the block id for new wharf frames and resets frame index
 *
 * @return New block ID
 */
unsigned int advance_block_id(void) {
	block_id = (block_id + 1) % MAX_BLOCK;
	frame_index = 0;
	return block_id;
}


/**
 * @brief Encapsulate the packet with new header.
 *
 * The new resulting packet looks like NEW_ETH_HEADER | WHARF_TAG | oldPacket
 *
 * @param[in] tclass Class of the wharf frame, indicating parity ratio
 * @param[in] packet Packet data to be encapsulated
 * @param[out] result Pointer to buffer which will be allocated and filled with the encapsulation
 *
 * @return resulting size of the newly encapsulated packet.
 */
int wharf_tag_frame(enum traffic_class tclass, const u_char* packet, int size, u_char** result) {
  if (size >= FRAME_SIZE_CUTOFF) {
    fprintf(stderr, "Frame too big for tagging (%d)", size);
    exit(1);
  }

  /* make space for the new header to be added */
  const int extra_header_size = sizeof(struct ether_header) + sizeof(struct fec_header);
  *result = (u_char *)malloc(size + extra_header_size);

  /* Copy over the etherHeader from the original packet */
  memcpy(*result, packet, sizeof(struct ether_header));

  /* Copy over the original packet as is.*/
  memcpy(*result + extra_header_size, packet, size);

  /* Replace the ether_type in the new ether header with wharf_ethertype*/
  struct ether_header *eth_header = (struct ether_header *)*result;
  eth_header->ether_type=htons(WHARF_ETHERTYPE);

  /* Populate the wharf tag with the block_id, packet_id, class, & packetsize*/
  struct fec_header *tag = (struct fec_header *)(*result + sizeof(struct ether_header));
  tag->class_id = (int)tclass;
  tag->block_id = block_id;
  tag->index = frame_index;
  tag->size = size;

  /* update the block_id and frame_index */
  frame_index = (frame_index + 1) % (NUM_DATA_PACKETS + NUM_PARITY_PACKETS);
  if (0 == frame_index) {
    block_id = (block_id + 1) % MAX_BLOCK;
  }

  return size + extra_header_size;
}

/**
 * @brief Removes the added wharf & new ether tag and returns the original packet
 *
 * @param[out] tclass Class of traffic that was marked in header
 * @param[inout] packet Encapsulated packet, which will be stripped to original packet
 * @param[in] size Total size of received packet
 *
 * @return size of newly stripped packet
 */
int wharf_strip_frame(enum traffic_class * tclass, u_char* packet, int size) {
  struct ether_header *eth_header = (struct ether_header *)packet;
  /*If not a wharf encoded packet*/
  if (htons(WHARF_ETHERTYPE) != eth_header->ether_type) {
    fprintf(stderr, "Cannot strip non-Wharf frame");
    exit(1);
  }

  /*extract the original size and copy in place*/
  struct fec_header *tag = (struct fec_header *)(packet + sizeof(struct ether_header));
  *tclass = (enum traffic_class)tag->class_id;
  const int original_size = tag->size;
  const int offset = sizeof(struct ether_header) + sizeof(struct fec_header);
  for (int i = 0; i < original_size; i++) {
    packet[i] = packet[i + offset];
  }
  return size - offset;
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

int main (int argc, char** argv) {
	char* inputInterface = NULL;
	char* outputInterface = NULL;
	int opt = 0;
	int rc;

	/* initialize fec codewords */
	if ((rc = rse_init()) != 0 ) exit(rc);

	while ((opt = getopt(argc, argv, "i:o:w:t:")) != -1)
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
		default:
			printf("\nNot yet defined opt = %d\n", opt);
			abort();
		}
	}

	if (NULL == inputInterface) {
		fprintf(stderr, "Need -i parameter at least\n");
		fprintf(stderr, "Usage: %s -i input [-o output] [-w workerId] [-t workerCt]\n", argv[0]);
		exit(1);
	}

	if (NULL != outputInterface) {
		char output_error_buffer[PCAP_ERRBUF_SIZE];
		output_handle = pcap_open_live(outputInterface, BUFSIZ, 0, 0, output_error_buffer);
		if (output_handle == NULL) {
			fprintf(stderr, "Could not open device %s: %s\n", outputInterface, output_error_buffer);
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
		fprintf(stderr, "Could not open device %s: %s\n", inputInterface, input_error_buffer);
		exit(1);
	}

	pcap_loop(input_handle, 0, my_packet_handler, NULL);
}
