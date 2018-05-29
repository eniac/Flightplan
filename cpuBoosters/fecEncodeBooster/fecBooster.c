
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
 * @brief      Wrapper to invoke encoder
 */
void encode_block() {
	int rc;
	if ((rc = rse_code(FB_INDEX, 'e')) != 0 )  exit(rc);
//(	fec_dbg_printf)("\nSending ");
	D0(fec_block_print(FB_INDEX));
	// print_global_fb_block();
}

/**
 * @brief      Wrapper to invoke the decoder
 */
void decode_block(int block_id) {
	int rc;
	if ((rc = rse_code(FB_INDEX, 'd')) != 0 ) {
		fprintf(stderr, "\nCould not decode block: ");
	} else {
		fprintf(stderr, "\nRecovered ");
	}
	D0(fec_block_print(FB_INDEX));
	for (int i=0; i < NUM_DATA_PACKETS; i++) {
		if (fbk[FB_INDEX].pstat[i] == FEC_FLAG_GENNED) {
			pkt_buffer_filled[block_id][i] = PACKET_RECOVERED;
		}
	}
}

/**
 * @brief checks if all packets for a given block are received or not
 *
 * @param[in]  blockId  The block identifier
 *
 * @return     True if all packets recieved for block, False otherwise.
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
 * @brief      Zeros-out the given block in the buffer.
 *
 * @param[in]  blockId  The block identifier
 */
void zeroout_block_in_pkt_buffer(int blockId) {
	int blockSize = NUM_PARITY_PACKETS + NUM_DATA_PACKETS;
	for (int i = 0; i < blockSize; i++) {
		pkt_buffer_filled[blockId][i] = PACKET_ABSENT;
	}
	return;
}

/*
 * Returns the size of original packet + sizeof(FRAME_SIZE_TYPE) 
 */
int updated_get_payload_length_for_pkt (u_char* packet){

	FRAME_SIZE_TYPE *original_frame_size = (FRAME_SIZE_TYPE *)(packet);
	int payloadLength = *original_frame_size + sizeof(FRAME_SIZE_TYPE);

	return payloadLength;
}

/*
 * Create Random Data and Blank Parity packets and link to the FEC block (fb)
 */
static void populate_fec_blk(fec_sym k, fec_sym h, fec_sym o,
                             int blockId, bool expect_parity) {
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

			int payloadLength = updated_get_payload_length_for_pkt((u_char *)pkt_buffer[blockId][i]);

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

		if (expect_parity) {
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
 * @brief		 Populates the fec block with the data packets from pkt_buffer
 *
 * Marks the parity packets as WANTED, so they will be generated on call to encode.
 *
 * @param[in]	 blockId		 The block of pkt_buffer from which to populate the fbk
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
 * @brief		 Populates the fec block with both data _and_ parity packets from buffer
 *
 * Missing parity packets are marked as IGNORE.
 *
 * @param[in]	 blockId		 The block of pkt_buffer from which to populate the fbk
 */
void populate_fec_blk_data_and_parity(int blockId) {
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	fec_sym k = NUM_DATA_PACKETS;
	fec_sym h = NUM_PARITY_PACKETS;
	fec_sym o = 0;
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

	populate_fec_blk(k, h, o, blockId, true);
}

int copy_parity_packets_to_pkt_buffer(int blockId) {
	int startIndexOfParityPacket = NUM_DATA_PACKETS;
	int sizeOfParityPackets = fbk[FB_INDEX].plen[startIndexOfParityPacket];

	for (int i = startIndexOfParityPacket; i < (startIndexOfParityPacket + NUM_PARITY_PACKETS); i++) {
		memcpy(pkt_buffer[blockId][i], fbk[FB_INDEX].pdata[i], sizeOfParityPackets);
		pkt_buffer_filled[blockId][i] = PACKET_PRESENT;
	}
	return sizeOfParityPackets;
}

static unsigned int block_id = 0;
static unsigned int frame_index = 0;

unsigned int advance_block_id(void) {
	block_id = (block_id + 1) % MAX_BLOCK;
	frame_index = 0;
	return block_id;
}


/**
 * @brief      Encapsulate the packet with new header.
 *  		   so the new resulting packet looks like NEW_ETH_HEADER | WHARF_TAG | oldPacket 
 * 
 * @return     resulting size of the newly encapsulated packet.
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
  memcpy(*result + sizeof(struct ether_header) + sizeof(struct fec_header), packet, size);

  /* Replace the ether_type in the new ether header with wharf_ethertype*/
  struct ether_header *eth_header = (struct ether_header *)*result;
  eth_header->ether_type=htons(WHARF_ETHERTYPE);

  /* Populate the wharf tag with the block_id, packet_id, class, & packetsize*/
  struct fec_header *tag = (struct fec_header *)(*result + sizeof(struct ether_header));
  tag->class_id = (int)tclass;
  tag->block_id = block_id;
  tag->index = frame_index;
  tag->size = size;

  /* update the block_id and packet_id */
  frame_index = (frame_index + 1) % (NUM_DATA_PACKETS + NUM_PARITY_PACKETS);
  if (0 == frame_index) {
    block_id = (block_id + 1) % MAX_BLOCK;
  }

  return size + extra_header_size;
}

/*Removes the added wharf & new ether tag and returns the original packet*/
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

	if (NULL == inputInterface && NULL == outputInterface) {
		fprintf(stderr, "Need -i parameter at least\n");
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
