#include <pcap.h>
#include <net/ethernet.h>
#include <stdint.h>
#include <unistd.h>
#include "fecDefs.h"
#include "rse.h"

#define SIZE_ETHERNET sizeof(struct ether_header)

#define NUM_DATA_PACKETS 8
#define NUM_PARITY_PACKETS 4
#define NUM_BLOCKS 256
#define PKT_BUF_SZ 2048


extern int workerId;
extern int workerCt;

extern int SIZE_FEC_TAG;

extern pcap_t *handle; /*PCAP handle*/

extern int cnt;

extern char* pkt_buffer[NUM_BLOCKS][NUM_DATA_PACKETS + NUM_PARITY_PACKETS]; /*Global pkt buffer*/
extern int pkt_buffer_filled[NUM_BLOCKS][NUM_DATA_PACKETS + NUM_PARITY_PACKETS]; /*Global pkt buffer*/

extern int Default_erase_list[FEC_MAX_N];


void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);
bool is_all_pkts_recieved_for_block(int blockId);
void zeroout_block_in_pkt_buffer(int blockId);
int get_payload_length_for_pkt(char* packet);
unsigned char* get_payload_start_for_packet(char* packet);
void fec_blk_get(fec_blk p, fec_sym k, fec_sym h, int c, int seed, fec_sym o, int blockId);
void call_fec_blk_get(int blockId);
void simulate_packet_loss();
void encode_block();
void decode_block();
void print_global_fb_block();
int copy_parity_packets_to_pkt_buffer(int blockId);
int get_total_packet_size(char* packet);
u_short compute_csum(struct sniff_ip *ip , int len);
void modify_IP_headers_for_parity_packets(int payloadSize, char* packet);

int wharf_tag_frame(const u_char* packet, int size, u_char** result);
int wharf_strip_frame(u_char* packet, int size);
#define WHARF_ORIG_FRAME_OFFSET (sizeof(struct ether_header) + sizeof(struct fec_header))

void print_hex_memory(void *mem, int len);
void forward_frame(const void * packet, int len);

void alloc_pkt_buffer();
void free_pkt_buffer();