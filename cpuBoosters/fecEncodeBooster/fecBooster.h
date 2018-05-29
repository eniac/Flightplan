#include <pcap.h>
#include <net/ethernet.h>
#include <stdint.h>
#include <unistd.h>
#include "fecDefs.h"
#include "rse.h"

#define SIZE_ETHERNET sizeof(struct ether_header)
#define SIZE_FEC_TAG sizeof(struct fec_header)

#define NUM_DATA_PACKETS 8
#define NUM_PARITY_PACKETS 4
#define NUM_BLOCKS 256
#define PKT_BUF_SZ 2048


extern int workerId;
extern int workerCt;

extern pcap_t *handle;

extern int cnt;

extern char* pkt_buffer[NUM_BLOCKS][NUM_DATA_PACKETS + NUM_PARITY_PACKETS];
extern int pkt_buffer_filled[NUM_BLOCKS][NUM_DATA_PACKETS + NUM_PARITY_PACKETS];

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);
bool is_all_pkts_recieved_for_block(int blockId);
bool is_all_data_pkts_recieved_for_block(int blockId);
void zeroout_block_in_pkt_buffer(int blockId);
int get_payload_length_for_pkt(char* packet);
unsigned char* get_payload_start_for_packet(char* packet);
void fec_blk_get(fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o, int blockId);
void call_fec_blk_get(int blockId);
void call_fec_blk_put(int blockId);
void fec_blk_put(fec_sym k, fec_sym h, int c, int seed, fec_sym o, int blockId);
void encode_block();
void decode_block(int block_id);
int copy_parity_packets_to_pkt_buffer_DEPRECATED(int blockId);
int copy_parity_packets_to_pkt_buffer(int blockId);
void copy_data_packets_to_pkt_buffer(int blockId);
int get_total_packet_size(char* packet);
u_short compute_csum(struct sniff_ip *ip , int len);
void modify_IP_headers_for_parity_packets(int payloadSize, char* packet);

enum traffic_class {one=1, two=2, three=3};
unsigned int advance_block_id();
int wharf_tag_frame(enum traffic_class tclass, const u_char* packet, int size, u_char** result);
int wharf_strip_frame(enum traffic_class * tclass, u_char* packet, int size);
#define WHARF_ORIG_FRAME_OFFSET (sizeof(struct ether_header) + sizeof(struct fec_header))

void print_hex_memory(void *mem, int len);
void forward_frame(const void * packet, int len);

void alloc_pkt_buffer();
void free_pkt_buffer();

#define PACKET_ABSENT 0
#define PACKET_PRESENT 1
#define PACKET_RECOVERED 2

// WHARF_DECODE_TIMEOUT==0 means we're not using the timeout, otherwise it's the seconds before a block is timed out.
#define WHARF_DECODE_TIMEOUT 2
// WHARF_ENCODE_TIMEOUT should be less than WHARF_DECODE_TIMEOUT, otherwise a frame could be
// decoded before it's finished being sent
#define WHARF_ENCODE_TIMEOUT 1
