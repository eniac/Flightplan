/**
 *
 * FEC header definition. 
 *
 */

typedef struct fec_header {
	uint8_t class_id : 3; // The class of the packet
	uint8_t block_id : 5; // The block ID of the FEC 
	uint8_t index; // The index or pkt ID of withing the block.
} fec_header_t;