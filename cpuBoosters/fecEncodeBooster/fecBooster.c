
#include <stdarg.h>
#include <stdio.h>
#include <arpa/inet.h>
#include "fecBooster.h"

int workerId = 0;
int workerCt = 1;

int SIZE_FEC_TAG = 0;

pcap_t *handle; /*PCAP handle*/

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
			pkt_buffer_filled[i][j] = 0;
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
 * @brief      Initialize packet capture
 *
 * @param      deviceToCapture  The device to capture
 *
 * @return
 */
void* capturePackets(char* deviceToCapture) {
	char *device;
	char error_buffer[PCAP_ERRBUF_SIZE];
	device = deviceToCapture;
//(	fec_dbg_printf)("Capturing packets on %s\n", device );
	/* Open device for live capture */
	handle = pcap_open_live(
	             device,
	             BUFSIZ,
	             1, /*set device to promiscous*/
	             0, /*Timeout of 0*/
	             error_buffer
	         );
	if (handle == NULL) {
		fprintf(stderr, "Could not open device %s: %s\n", device, error_buffer);
		return NULL;
	}

//(	fec_dbg_printf)("This is the start of capture\n");
	pcap_loop(handle, 0, my_packet_handler, NULL);
//(	fec_dbg_printf)("Ths is the end of capture\n");
//(	fec_dbg_printf)("Completed Capturing packets on %s\n", device );
	return NULL;
}


/**
 * @brief      Wrapper to populate the fec structure.
 *
 * @param[in]  blockId  The block identifier
 */
void call_fec_blk_get(int blockId) {

	int rc;

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	fec_sym p[FEC_MAX_N][FEC_MAX_COLS];   /* storage for packets in FEC block (fb) */
	fec_sym k = NUM_DATA_PACKETS; /*TODO: change to macro*/
	fec_sym h = NUM_PARITY_PACKETS; /*TODO: change to macro*/
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
//(	fec_dbg_printf)("\nSending ");
	D0(fec_block_print());
	// print_global_fb_block();
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
	fprintf(stderr, "\nRecovered ");
	D0(fec_block_print());
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
		if (pkt_buffer_filled[blockId][i] == 0) {
			// printf("all_pkts_received_fail @ (%i, %i)\n",blockId, i);
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
		pkt_buffer_filled[blockId][i] = 0;
	}
	return;
}

void print_global_fb_block() {
	for (int i = 0; i < fb.block_N; i++) {
	//(	fec_dbg_printf)("The length of %d packet is %d\n", i, fb.plen[i]);
	}
}


/*
 * Create Random Data and Blank Parity packets and link to the FEC block (fb)
 */
void fec_blk_get(fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o, int blockId) {
	// fprintf(stderr, "At the top of fec_blk_get\n");
	fec_sym i, y, z;
	int maxPacketLength = 0;
	fb.block_N = k + h; /*TODO: replace this with a macro later.*/

	/* Put C random symbols into each of the K data packets */
	for (i = 0; i < k; i++) {
		if (i >= FEC_MAX_K) {
			fprintf(stderr, "Number of Requested data packet (%d) > FEC_MAX_K (%d)\n", k, FEC_MAX_K);
			exit (33);
		}

		fec_sym* payloadStart = (fec_sym*) get_payload_start_for_packet(pkt_buffer[blockId][i]);
		int payloadLength = get_payload_length_for_pkt(pkt_buffer[blockId][i]);

		fb.pdata[i] = payloadStart;
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
	//(	fec_dbg_printf)(" The payloadlength for %d is %d\n", y, get_payload_length_for_pkt(pkt_buffer[blockId][y]));
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
	//(	fec_dbg_printf)("size0\n");
		return -1;
	}

	int sizePayload = ntohs(ip->ip_len) - (sizeIP);
	return sizePayload;
}

int get_total_packet_size(char* packet) {
	/*We need to account for the newly added tag after the ethernet heaader.*/
	const struct sniff_ip *ip;              /* The IP header */
	const struct sniff_tcp *tcp;            /* The TCP header */

	/* compute ip header offset */
	ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG);
	int sizeIP = IP_HL(ip) * 4;
	if (sizeIP < 20) {
	//(	fec_dbg_printf)("size0\n");
		return -1;
	}

	/* compute tcp header offset */
	tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP);
	int sizeTCP = TH_OFF(tcp) * 4;
	if (sizeTCP < 20) {
	//(	fec_dbg_printf)("size1\n");
		return -1;
	}

	int sizePayload = ntohs(ip->ip_len) - (sizeIP + sizeTCP);
	int totalSize = SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP + sizeTCP + sizePayload;
	return totalSize;
}

int copy_parity_packets_to_pkt_buffer(int blockId) {
	int startIndexOfParityPacket = 0 + NUM_DATA_PACKETS;
	int sizeOfParityPackets = fb.plen[startIndexOfParityPacket];
//(	fec_dbg_printf)("This is inside copy packets \n");
	/*For each parity packet*/
	for (int i = startIndexOfParityPacket; i < (startIndexOfParityPacket + NUM_PARITY_PACKETS); i++) {
		char* packet = pkt_buffer[blockId][i];

		/*We need to account for the newly added tag after the ethernet heaader.*/
		const struct sniff_ip *ip;              /* The IP header */
		const struct sniff_tcp *tcp;            /* The TCP header */

		/* compute ip header offset */
		ip = (struct sniff_ip*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG);
		int sizeIP = IP_HL(ip) * 4;
		if (sizeIP < 20) {
		//(	fec_dbg_printf)("size0\n");
			return -1;
		}

		/* compute tcp header offset */
		tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP);
		int sizeTCP = TH_OFF(tcp) * 4;
		if (sizeTCP < 20) {
		//(	fec_dbg_printf)("size1\n");
			return -1;
		}

		// int totalMallocSize = SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP + sizeTCP + sizeOfParityPackets;
		int totalHeaderSize =  SIZE_ETHERNET + SIZE_FEC_TAG + sizeIP ;

		////( fec_dbg_printf)("The totalMallocSize is ::::%d\n", totalMallocSize);


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
		// pkt_buffer_filled[blockId][i] = 1;
	}
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
	int i = 0;
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


int main (int argc, char** argv) {
	char* deviceToCapture;
	int opt = 0;
	int rc;

	/* initialize fec codewords */
	if ((rc = rse_init()) != 0 ) exit(rc);

	SIZE_FEC_TAG = sizeof(fec_header_t);

	while ((opt =  getopt(argc, argv, "i:w:t:")) != -1)
	{
		switch (opt)
		{
		case 'i':
			printf("deviceToCapture: %s\n",optarg);
			deviceToCapture = optarg;
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
	printf("starting worker %i / %i\n",workerId, workerCt);
	/* start packet capture on the specified interface.*/
	alloc_pkt_buffer();
	capturePackets(deviceToCapture);
	free_pkt_buffer();
}
