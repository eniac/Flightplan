// Configuration constants
// =======================

// BE CAREFUL WHEN MODIFYING THIS FILE!
// This file is also the basis of files included in Verilog and P4 code.

// Number of data packets in a group
#define FEC_K (8)
// Number of parity packets in a group
#define FEC_H (4)

// Maximum number of data packets per group
#define FEC_MAX_K (8)
// Maximum number of parity packets per group
#define FEC_MAX_H (4)

// Possible values for operation parameter for encoder
#define FEC_OP_START_ENCODER (1) // Prepare encoder for new block.
#define FEC_OP_ENCODE_PACKET (2) // Update parity with new data packet.
#define FEC_OP_GET_ENCODED   (4) // Store parity in packet.

// Width in bits of operation parameter for encoder
#define FEC_OP_WIDTH 3
// Width in bits of block index
#define FEC_BLOCK_INDEX_WIDTH 7
// Width in bits of packet index (within block)
#define FEC_PACKET_INDEX_WIDTH 8
// Width in bits of payload offset parameter for encoder
#define FEC_OFFSET_WIDTH 11
// Width of address to index registers
#define FEC_REG_ADDR_WIDTH 1

// Output ports
#define FEC_REGULAR_OUTPUT_PORT   (0) // Output to Ethernet MAC
#define FEC_DUPLICATE_OUTPUT_PORT (1) // Feedback to input

// Length in bits of Ethernet header
#define FEC_ETH_HEADER_SIZE (112)
// Length in bits of FEC header
#define FEC_HEADER_SIZE (FEC_BLOCK_INDEX_WIDTH + FEC_PACKET_INDEX_WIDTH + 1)
// Maximum length of Ethernet packet in bytes
#define FEC_MAX_PACKET_SIZE (1518)

// Number of registers in loop module
#define FEC_REG_COUNT (2)
