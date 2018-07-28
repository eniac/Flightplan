#ifndef FEC_BOOSTER_H_
#define FEC_BOOSTER_H_

#include <pcap.h>
#include <net/ethernet.h>
#include <stdint.h>
#include <unistd.h>
#include <stdbool.h>
#include "fecDefs.h"
#include "rse.h"

#ifndef LOG_ERR
#define LOG_ERR(s, ...) fprintf(stderr, "[%s:%s()::%d] ERROR: " s "\n", __FILE__, __func__, __LINE__, ##__VA_ARGS__)
#endif

#ifndef LOG_INFO
#define LOG_INFO(s, ...) fprintf(stderr, "[%s:%s()::%d] " s "\n", __FILE__, __func__, __LINE__, ##__VA_ARGS__)
#endif

#define LOG_HEX(buff, len) \
    for (int _i_=0; _i_ < len; _i_++) { \
        fprintf(stderr, "%02x", ((char*)buff)[_i_] & 0xff); \
        if (_i_ % 2 == 1) { \
            fprintf(stderr, " "); \
        } \
    } \
    fprintf(stderr, "\n");

#define SIZE_ETHERNET sizeof(struct ether_header)
#define WHARF_TAG_SIZE sizeof(struct ether_header) + sizeof(struct fec_header)

#define SIZE_ETHERNET sizeof(struct ether_header)

#define MAX_NUM_DATA_PACKETS 50
#define MAX_NUM_PARITY_PACKETS 5
#define NUM_BLOCKS 256

/** Size of an individual packet in pkt_buffer */
#define PKT_BUF_SZ 2048

/** Number of packets in a block of pkt_buffer */
#define TOTAL_NUM_PACKETS MAX_NUM_DATA_PACKETS + MAX_NUM_PARITY_PACKETS

/** Offset into the wharf-encapsulated packet at which original frame occurs */
#define WHARF_ORIG_FRAME_OFFSET (sizeof(struct ether_header) + sizeof(struct fec_header))

/** Marks in pkt_buffer_filled whether the packet has been received */
enum pkt_buffer_status {
    PACKET_ABSENT = 0,
    PACKET_PRESENT,
    PACKET_RECOVERED
};

/** Traffic class that determines parity/data ratio */
typedef unsigned short int tclass_type;
#define TCLASS_MAX 0x0F
#define TCLASS_NULL 0xFF

/** Sets the parameters k and h for a given traffic class */
void set_fec_params(tclass_type tclass, fec_sym k, fec_sym h);
void get_fec_params(tclass_type tclass, fec_sym *k, fec_sym *h);

/** Inserts a packet, tagged with its size, into the buffer */
void insert_into_pkt_buffer(tclass_type tclass, int blockId, int pktIdx,
                            FRAME_SIZE_TYPE pkt_size, const u_char *packet);

/** Gets a packet without its tagged size from the buffer */
u_char *retrieve_from_pkt_buffer(tclass_type tclass, int blockId, int pktIdx, FRAME_SIZE_TYPE *pktSize);
/** Gets a packet directly from the fec block */
u_char *retrieve_encoded_packet(tclass_type tclass, int pktIdx, size_t *sz_out);

/** Checks if a packet is already inserted into the buffer */
bool pkt_already_inserted(tclass_type tclass, int blockId, int pktIdx);
/** Checks if a packet has been recovered by FEC */
bool pkt_recovered(tclass_type tclass, int blockId, int pktIdx);

/** Checks that no packets are absent */
bool is_all_data_pkts_recieved_for_block(tclass_type type, int blockId);
/** Marks all packets in given block as absent */
void mark_pkts_absent(tclass_type tclass, int blockId);
/** Copies pkt_buffer data to fbk */
int populate_fec_blk_data_and_parity(tclass_type type, int blockId);
/** Copies pkt_buffer data and parity to fbk */
int populate_fec_blk_data(tclass_type type, int blockId);
/** Wrapper to envoke encoder on filled fbk */
void encode_block(void);
/** Wrapper to envoke decoder on filled fbk */
void decode_block(tclass_type type, int block_id);
/** Advances the block ID with which new wharf frames will be tagged */
int advance_block_id(tclass_type tclass);
/** Advances the packet index for the next inserted wharf frame */
int advance_packet_idx(tclass_type tclass);
/** Encapsulates a parity packet with new header */
int wharf_tag_parity(tclass_type tclass, int frame_index, int block_id,
                     const u_char* packet, size_t size_in,
                     u_char *out, size_t *size_out);
/** Encapsulates the next data packet with new header */
int wharf_tag_data(tclass_type tclass,
                   const u_char *packet, size_t size_in,
                   u_char *out, size_t *size_out);
/** Removes header from encapsulated packet */
const u_char *wharf_strip_frame(const u_char* packet, int *size);

uint8_t get_fec_block_id(tclass_type tclass);
uint8_t get_fec_frame_idx(tclass_type tclass);

/** Checks if enough data + parity packets have been received to forward a block */
bool can_decode(tclass_type tclass, int block_id);
#endif // FEC_BOOSTER_H_
