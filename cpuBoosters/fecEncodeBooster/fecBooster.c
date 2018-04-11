
#include <stdarg.h>
#include <stdio.h>
#include <arpa/inet.h>
#include "fecBooster.h"
#include "wharf_pcap.h"

int workerId = 0;
int workerCt = 1;

pcap_t *input_handle = NULL;
pcap_t *output_handle = NULL;

int cnt = 0;

char* pkt_buffer[NUM_BLOCKS][NUM_DATA_PACKETS + NUM_PARITY_PACKETS]; /*Global pkt buffer*/

int pkt_buffer_filled[NUM_BLOCKS][NUM_DATA_PACKETS + NUM_PARITY_PACKETS]; /*Global pkt buffer*/

int Default_erase_list[FEC_MAX_N] = {0, 2, 4, FEC_MAX_N};

/**
 *
 * Allocate the entire packet buffer at once.
 *
 */
void alloc_pkt_buffer() {
	for (int i = 0; i<NUM_BLOCKS; i++){
		for (int j = 0; j < NUM_DATA_PACKETS + NUM_PARITY_PACKETS; j++){
			pkt_buffer[i][j] = (char *)malloc(PKT_BUF_SZ);
			pkt_buffer_filled[i][j] = PACKET_ABSENT;
		}
	}
}

/**
 * Clean up.
 */
void free_pkt_buffer() {
	for (int i = 0; i<NUM_BLOCKS; i++){
		for (int j = 0; j < NUM_DATA_PACKETS + NUM_PARITY_PACKETS; j++){
			free(pkt_buffer[i][j]);
		}
	}

}


/**
 * @brief      Wrapper to populate the fec structure.
 *
 * @param[in]  blockId  The block identifier
 */
void call_fec_blk_get(int blockId) {

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	fec_sym p[FEC_MAX_N][FEC_MAX_COLS];   /* storage for packets in FEC block (fb) */
	fec_sym k = NUM_DATA_PACKETS;
	fec_sym h = NUM_PARITY_PACKETS;
	fec_sym o = 0;
	fec_sym c = 2;
	fec_sym s = 3;
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

	fec_blk_get(p, k, h, c, s, o, blockId);
}

/**
 * @brief      Wrapper to invoke encoder
 */
void encode_block() {
	int rc;
	if ((rc = rse_code(1)) != 0 )  exit(rc);
#if 0
	D0(fec_block_print());
#endif
}

/**
 * @brief      wrapper to simulate packet loss.
 */
void simulate_packet_loss() {
	int e_list[FEC_MAX_N];
	int list_done = (int) FEC_MAX_N;
	e_list[0] = list_done;
	int i;
	/* If no erasure input indices input, then use defaults */
	if ( e_list[0] == list_done) {
		for (i = 0; Default_erase_list[i] != list_done; i++) {
			e_list[i] = Default_erase_list[i];      /* copy default values */
		}
	}
	e_list[i] = list_done; /* put list_done marker at end of input */

	/* Erasure Channel */
	fec_block_delete(e_list);
	fprintf(stderr, "\nReceived ");
	D0(fec_block_print());
}

/**
 * @brief      Wrapper to invoke the decoder
 */
void decode_block() {
	int rc;
	if ((rc = rse_code(1)) != 0 )  exit(rc);
#if 0
	D0(fec_block_print());
#endif
}

/**
 * @brief      returns if all packets for a given block are received or not
 *
 * @param[in]  blockId  The block identifier
 *
 * @return     True if all packets recieved for block, False otherwise.
 */
bool is_all_pkts_recieved_for_block(int blockId) {
	int blockSize = NUM_PARITY_PACKETS + NUM_DATA_PACKETS;
	for (int i = 0; i < blockSize; i++) {
		if (pkt_buffer_filled[blockId][i] == PACKET_ABSENT) {
			// printf("all_pkts_received_fail @ (%i, %i)\n",blockId, i);
			return false;
		}
	}
	return true;
}

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
void fec_blk_get(fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o, int blockId) {
	// fprintf(stderr, "At the top of fec_blk_get\n");
	fec_sym i, y, z;
	int maxPacketLength = 0;
	fb.block_N = k + h; 
	
	/* copy the K data packets from packet buffer */
	for (i = 0; i < k; i++) {
		if (i >= FEC_MAX_K) {
			fprintf(stderr, "Number of Requested data packet (%d) > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
			exit (33);
		}

		int payloadLength = updated_get_payload_length_for_pkt((u_char *)pkt_buffer[blockId][i]);

		fb.pdata[i] = (fec_sym *) pkt_buffer[blockId][i];
		fb.cbi[i] = i;
		fb.plen[i] = payloadLength;

		/*  Keep track of maximum packet length to set the block_C field of FEC structure    */
		if (payloadLength > maxPacketLength) {
			maxPacketLength = payloadLength;
		}
		fb.pstat[i] = FEC_FLAG_KNOWN;

	}


	fb.block_C = maxPacketLength + FEC_EXTRA_COLS;    /* One extra for length symbol */


	/* Leave H Parity packets empty */
	for (i = 0; i < h; i++) {
		if (i >= FEC_MAX_H) {
			fprintf(stderr, "Number of Requested parity packet (%d) > FEC_MAX_H (%d)\n", h, FEC_MAX_H);
			exit (34);
		}
		y = k + i;                                  /* FEC block index */
		z = FEC_MAX_N - o - i - 1;             /* Codeword index */
		fb.pdata[y] = p[y];
		fb.cbi[y] = z;
		fb.plen[y] = fb.block_C;
		fb.pstat[y] = FEC_FLAG_WANTED;
	}

	/* shorten last packet, if not: a) 1 symbol/packet, b) lone packet, c) fixed size */
	if ((c > 1) && (k > 1) && (FEC_EXTRA_COLS > 0)) {
		fb.plen[k - 1] -= 1;
		p[k - 1][0] -= 1;
	}
}

unsigned char* get_payload_start_for_packet(char* packet) {
	/*We need to account for the newly added tag after the ethernet heaader.*/
	const struct sniff_ip *ip;              /* The IP header */

	/* compute ip header offset */
	ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG);
	int sizeIP = IP_HL(ip) * 4;
	if (sizeIP < 20) {
		return NULL;
	}

	/* compute payload offset after IP header */
	unsigned char* payload = (u_char *)(packet + SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP);

	return payload;
}

int get_payload_length_for_pkt(char* packet) {
	/*We need to account for the newly added tag after the ethernet heaader.*/
	const struct sniff_ip *ip;              /* The IP header */

	/* compute ip header offset */
	ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG);
	int sizeIP = IP_HL(ip) * 4;
	if (sizeIP < 20) {
		return -1;
	}

	int sizePayload = ntohs(ip->ip_len) - (sizeIP);
	return sizePayload;
}

int get_total_packet_size(char* packet) {
	/*We need to account for the newly added tag after the ethernet heaader.*/
	const struct sniff_ip *ip;              /* The IP header */

	/* compute ip header offset */
	ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG);
	int sizeIP = IP_HL(ip) * 4;
	if (sizeIP < 20) {
	//(	fec_dbg_printf)("size0\n");
		return -1;
	}

	int sizePayload = ntohs(ip->ip_len) - (sizeIP /*FIXME should not care about TCP: + sizeTCP*/);
	int totalSize = SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP /*FIXME should not care about TCP: + sizeTCP*/ + sizePayload;
	return totalSize;
}

int copy_parity_packets_to_pkt_buffer_DEPRECATED(int blockId) {
	int startIndexOfParityPacket = 0 + NUM_DATA_PACKETS;
	int sizeOfParityPackets = fb.plen[startIndexOfParityPacket];
//(	fec_dbg_printf)("This is inside copy packets \n");
	/*For each parity packet*/
	for (int i = startIndexOfParityPacket; i < (startIndexOfParityPacket + NUM_PARITY_PACKETS); i++) {

		char* packet = pkt_buffer[blockId][i];

		/*We need to account for the newly added tag after the ethernet heaader.*/
		const struct sniff_ip *ip;              /* The IP header */

		/* compute ip header offset */
		/*Skip the ether header, wharf header, old ether_type*/
		ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG); 
		int sizeIP = IP_HL(ip) * 4;
		if (sizeIP < 20) {
		//(	fec_dbg_printf)("size0\n");
			return -1;
		}

		int totalHeaderSize =  SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP ;

		/*update the parity packet in the pkt buffer.*/
		// char* parityPacket = (char *) malloc(totalMallocSize);
		// pkt_buffer[blockId][i] = parityPacket;

		/*copy headers from the original packet.*/
		memcpy(pkt_buffer[blockId][i], packet, totalHeaderSize);

		/*Copy payload from the global fec struct*/
		memcpy(pkt_buffer[blockId][i] + totalHeaderSize, fb.pdata[i], sizeOfParityPackets);

		/*Update the the payload lenght and checksum*/
		modify_IP_headers_for_parity_packets(sizeOfParityPackets, pkt_buffer[blockId][i]);

		// // Set filled.
		// pkt_buffer_filled[blockId][i] = PACKET_PRESENT;
	}
	return 0;
}

int copy_parity_packets_to_pkt_buffer(int blockId) {
	int startIndexOfParityPacket = NUM_DATA_PACKETS;
	int sizeOfParityPackets = fb.plen[startIndexOfParityPacket];

	for (int i = startIndexOfParityPacket; i < (startIndexOfParityPacket + NUM_PARITY_PACKETS); i++) {
		memcpy(pkt_buffer[blockId][i], fb.pdata[i], sizeOfParityPackets);
		pkt_buffer_filled[blockId][i] = PACKET_PRESENT;
	}
	return sizeOfParityPackets;
}

void modify_IP_headers_for_parity_packets(int payloadSize, char* packet) {
	struct sniff_ip *ip;              /* The IP header */

	/* compute ip header offset */
	ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG);
	int sizeIP = IP_HL(ip) * 4;
	if (sizeIP < 20) {
	//(	fec_dbg_printf)("size0\n");
		return;
	}

	/*TODO: Need to verify this. */
	// TODO: use htons to format short ints in the right order.
	ip->ip_len = htons(payloadSize + sizeIP);

	/*Compute checksum*/
	ip->ip_sum =  compute_csum(ip, sizeIP);
}

/* Computes the checksum of the IP header. */
u_short compute_csum(struct sniff_ip *ipHeader , int len) {
	long sum = 0;  /* assume 32 bit long, 16 bit short */
	unsigned short* ip = (unsigned short*) ipHeader;
	while (len > 1) {
		sum += *ip;
		ip++;
		if (sum & 0x80000000)  /* if high order bit set, fold */
			sum = (sum & 0xFFFF) + (sum >> 16);
		len -= 2;
	}

	if (len)      /* take care of left over byte */
		sum += (unsigned short) * (unsigned char *)ip;

	while (sum >> 16)
		sum = (sum & 0xFFFF) + (sum >> 16);

	return ~sum;
}

//void ( fec_dbg_printf)( const char* format, ... ) {
	// printf("lolboat.\n");
// #ifdef DBG_PRINT
//     va_list args;
//     va_start( args, format );
//     vprintf(format, args );
//     va_end( args );
// #endif
// }

void print_hex_memory(void *mem, int len) {
  int i;
  unsigned char *p = (unsigned char *)mem;
  for (i=0;i<len;i++) {
    printf("0x%02x ", p[i]);
    // if (i%16==0)
    //   printf("\n");
  }
  printf("\n");
}

static unsigned int block_id = 0;
static unsigned int frame_index = 0;


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
  if (tag->index >= NUM_DATA_PACKETS) {
    fprintf(stderr, "Cannot strip non-data Wharf frame");
    exit(1);
  }
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
			workerId = atoi(optarg);
			break;
		case 't':
			workerCt = atoi(optarg);
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

	printf("starting worker %i / %i\n",workerId, workerCt);
	alloc_pkt_buffer();

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


	free_pkt_buffer();
}

void copy_data_packets_to_pkt_buffer(int blockId) {
	for (int i = 0; i < NUM_DATA_PACKETS; i++) {
		if (PACKET_PRESENT != pkt_buffer_filled[blockId][i]) {
			const FRAME_SIZE_TYPE original_frame_size = (FRAME_SIZE_TYPE)(*pkt_buffer[blockId][i]);
			memcpy(pkt_buffer[blockId][i] + sizeof(FRAME_SIZE_TYPE), fb.pdata[i], original_frame_size);
			pkt_buffer_filled[blockId][i] = PACKET_RECOVERED;
		}
	}
}
