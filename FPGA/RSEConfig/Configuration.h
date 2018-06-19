// Configuration constants
// =======================

// BE CAREFUL WHEN MODIFYING THIS FILE!
// This file is also the basis of files included in Verilog and P4 code.

// Number of data packets in a group
#define FEC_K (8)
// Number of parity packets in a group
#define FEC_H (4)

// Maximum number of data packets per group
#define FEC_MAX_K (50)
// Maximum number of parity packets per group
#define FEC_MAX_H 5

// Width in bits of traffic class
#define FEC_TRAFFIC_CLASS_WIDTH 3
// Width in bits of block index
#define FEC_BLOCK_INDEX_WIDTH 5
// Width in bits of packet index (within block)
#define FEC_PACKET_INDEX_WIDTH 8
// Width in bits of k parameter
#define FEC_K_WIDTH 8
// Width in bits of h parameter
#define FEC_H_WIDTH 8
// Width in bits of Ethernet Type field
#define FEC_ETHER_TYPE_WIDTH 16
// Width in bits of packet length (including reserved bits)
#define FEC_PACKET_LENGTH_WIDTH 16
// Width in bits of AXI bus
#define FEC_AXI_BUS_WIDTH (64)

// Length in bits of Ethernet header
#define FEC_ETH_HEADER_SIZE (112)
// Maximum length of Ethernet packet in bytes
#define FEC_MAX_PACKET_SIZE (1518)

// FIXME hardcoded
#define FEC_BLOCK_INDEX 0
