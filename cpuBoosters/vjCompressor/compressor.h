/**
 *
 * Defs for vj compressor.
 *
 */

#define ETYPE_COMPRESSED 0x66
#define CACHE_SZ 1024

/*================================
=            Headers.            =
================================*/

/**
 *
 * Custom IP and TCP header defs.
 * (Not necessary, but omitting bitfield arrays
 * simplifies the program.)
 *
 */

// fixed:         omitted in a compressed header
// carried:       always included in a compressed header
// recomputed:    omitted in a compressed header, recomputed during reconstruction.
// cond. carried: included if value is different from previous value.

struct ipHeader_t {
  uint8_t ihl_version;  // Fixed.
  uint8_t tos;          // Fixed.
  uint16_t tot_len;     // Carried.
  uint16_t id;          // Carried. 
  uint16_t frag_off;    // Fixed.
  uint8_t ttl;          // Fixed.
  uint8_t proto;        // Fixed.
  uint16_t check;       // Recomputed.
  uint32_t saddr;       // Fixed.
  uint32_t daddr;       // Fixed.
};

struct tcpHeader_t {
  uint16_t source;      // Fixed.
  uint16_t dest;        // Fixed.
  uint32_t seq;         // Conditionally carried.
  uint32_t ack_seq;     // Conditionally carried.
  uint16_t flags;       // Carried.
  uint16_t window;      // Carried.
  uint16_t check;       // Carried.
  uint16_t urg_ptr;     // Carried.
};

struct compressedHeader_t {
  // Compressor control fields. 
  uint16_t slotId     : 10;
  uint8_t seqChange  : 1;
  uint8_t ackChange  : 1;
  uint8_t __pad      : 4;

  // Header fields to always include.

  // IP fields.
  uint16_t tot_len;
  uint16_t id;

  // TCP fields.
  uint16_t flags;
  uint16_t window;
  uint16_t check;
  uint16_t urg_ptr;
};

struct compressorTuple_t { 
  uint16_t len;
  uint16_t idx;

  ipHeader_t ipHeader;
  tcpHeader_t tcpHeader;
};

// // Packet headers to include only if they've changed.
// struct varHeader_t {
//   uint32_t seqNum;
//   uint32_t ackNum;
// }


void printHeaderSizes(){
  printf("size compressionControlHeader_t: %li bytes\n",sizeof(compressedHeader_t));
  printf("size ipHeader_t: %li bytes\n", sizeof(ipHeader_t));
  printf("size tcpHeader_t: %li bytes\n", sizeof(tcpHeader_t));

}
/*=====  End of Headers.  ======*/

/*=========================================
=            Ported functions.            =
=========================================*/

bool compress(u_char * compressedPktBuf, uint32_t *compressedPktLen,
  uint32_t pktLen, 
  const struct ether_header* ethernetHeader, 
  const struct ipHeader_t* ipHeader,
  const struct tcpHeader_t* tcpHeader,
  char * payload, uint32_t payloadLen);

bool checkCache(uint32_t idx,
  const struct ipHeader_t* ipHeader,
  const struct tcpHeader_t* tcpHeader);


void buildCompressedHeader(compressedHeader_t *cHeader, compressorTuple_t *curPktTup);

void decompressHandler(const u_char*packet, uint32_t pktLen);

void buildDecompressedHeaders(compressorTuple_t *curPktTup, 
  const struct compressedHeader_t * cHeader);

/*=====  End of Ported functions.  ======*/

