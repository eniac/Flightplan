/**
 *
 * FEC header definition. 
 *
 */

#define FRAME_SIZE_TYPE uint16_t

typedef struct fec_header {
	uint8_t class_id : 3; // The class of the packet
	uint8_t block_id : 5; // The block ID of the FEC 
	uint8_t index; // The index or pkt ID of withing the block.
	FRAME_SIZE_TYPE size : 14; // For data frames this is the size of encoded frame; otherwise it's meaningless for parity frames.
} fec_header_t;

#define WHARF_ETHERTYPE 0x081C
#define MAX_BLOCK 6
#define FRAME_SIZE_CUTOFF 1400
