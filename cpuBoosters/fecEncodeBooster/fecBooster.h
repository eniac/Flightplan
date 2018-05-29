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

/** Size of an individual packet in pkt_buffer */
#define PKT_BUF_SZ 2048
/** Number of packets in a block of pkt_buffer */
#define TOTAL_NUM_PACKETS NUM_DATA_PACKETS + NUM_PARITY_PACKETS

/** Offset into the wharf-encapsulated packet at which original frame occurs */
#define WHARF_ORIG_FRAME_OFFSET (sizeof(struct ether_header) + sizeof(struct fec_header))

/**
 * Amount of time before the decoder attempts to decode packets if no activity
 * WHARF_DECODE_TIMEOUT==0 means we're not using the timeout
 */
#define WHARF_DECODE_TIMEOUT 2

/**
 * Amount of time before the encoder forwards parity packets if no activity.
 * WHARF_ENCODE_TIMEOUT should be less than WHARF_DECODE_TIMEOUT, otherwise
 * a frame could be decoded before it's finished being sent.
 * WHARF_ENCODE_TIMEOUT==0 disables the timeout
 */
#define WHARF_ENCODE_TIMEOUT 1

enum pkt_buffer_status {
    PACKET_ABSENT = 0,
    PACKET_PRESENT,
    PACKET_RECOVERED
};

/** Global buffer into which received and decoded packets will be placed */
extern char pkt_buffer[NUM_BLOCKS][TOTAL_NUM_PACKETS][PKT_BUF_SZ];
/** Status of packets stored in global buffer */
extern enum pkt_buffer_status pkt_buffer_filled[NUM_BLOCKS][TOTAL_NUM_PACKETS];

void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);
/** Checks that no packets are absent */
bool is_all_data_pkts_recieved_for_block(int blockId);
/** Marks all packets in given block as absent */
void mark_pkts_absent(int blockId);
/** Copies pkt_buffer data to fbk */
void populate_fec_blk_data_and_parity(int blockId);
void populate_fec_blk_data(int blockId);
/** Wrapper to envoke encoder on filled fbk */
void encode_block(void);
/** Wrapper to envoke decoder on filled fbk */
void decode_block(int block_id);
/** Copies parity from fbk to pkt_buffer */
int copy_parity_packets_to_pkt_buffer(int blockId);
/** Advances the block ID with which new wharf frames will be tagged */
unsigned int advance_block_id();
int wharf_tag_frame(enum traffic_class tclass, const u_char* packet, int size, u_char** result);
int wharf_strip_frame(enum traffic_class * tclass, u_char* packet, int size);
void forward_frame(const void * packet, int len);

