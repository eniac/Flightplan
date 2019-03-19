/**
 *
 * Empty booster. Reads packets, sends them back.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <net/ethernet.h>
#include <netinet/in.h>
// #include <netinet/ip.h>
// #include <netinet/tcp.h>
// #include <netinet/udp.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <net/if.h>

#include <math.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <cstring>
#include <sstream>
#include <unordered_map>
#include <list>

#include "compressor.h"

using namespace std;

#define MTU 1500

static uint64_t byteCt, pktCt;

// Memory dump helper
static void print_hex_memory(void *mem, int len) {
  int i;
  unsigned char *p = (unsigned char *)mem;
  for (i=0;i<len;i++) {
    printf("0x%02x ", p[i]);
    // if (i%16==0)
    //   printf("\n");
  }
  printf("\n");
}

/*=========================================
=            Compressor.                  =
=========================================*/


static compressorTuple_t compressorCache[CACHE_SZ];
static uint32_t compressPktId = 0;
/**
 *
 * Main compress function.
 *
 */
void compress(const u_char*packet, uint32_t pktLen, forward_fn forward){
    compressPktId++;
    const struct ether_header* ethernetHeader;
    const struct ipHeader_t* ipHeader;
    const struct tcpHeader_t* tcpHeader;
    const struct udphdr* udpHeader;

    char * payload;
    uint32_t payloadLen;
    bool isHit = false;
    bool doCompress = false;

    compressorTuple_t curPktTup;
    u_char compressedPktBuf[pktLen];
    uint32_t compressedPktLen = 0;

    // Parse eth, ip, and tcp/udp headers. 
    // Check if its a TCP packet for compression.
    ethernetHeader = (struct ether_header*)packet;
    if (ntohs(ethernetHeader->ether_type) == ETHERTYPE_IP) {
        ipHeader = (struct ipHeader_t*)(packet + sizeof(struct ether_header));
      if (ipHeader->proto == 6){
        tcpHeader = (tcpHeader_t*)((u_char*)ipHeader + sizeof(*ipHeader));
        payload = (char *)tcpHeader + sizeof(*tcpHeader);
        payloadLen = (pktLen) - sizeof(*ethernetHeader) - sizeof(*ipHeader) - sizeof(*tcpHeader);
        doCompress = true;
      }
    }

    // emit packet without compression.
    if (doCompress == false){
      decompress(packet,pktLen, forward);
      // pcap_inject(pcap,packet,pktLen);
      return;
    }
    // Start compression logic.

    // Initialize tuple for current packet.
    curPktTup.ipHeader = *ipHeader;
    curPktTup.tcpHeader = *tcpHeader;
    curPktTup.len = pktLen;

    // 0. Check length.
    if (curPktTup.len < 100) {
      decompress(packet,pktLen, forward);
      // pcap_inject(pcap,packet,pkthdr -> len);
      return;
    }
    // 1. Calculate index into cache.
    curPktTup.idx = ntohl((uint32_t)(curPktTup.ipHeader.saddr)) % CACHE_SZ; // TODO: use a hash function.
    // 2. Check if hit.
    isHit = checkCache(curPktTup);

    // 2.a. If not hit, this is the first packet in a flow. 
    // Save this packet's header to the cache and don't build a compressed packet.
    if (!isHit){
      compressorCache[curPktTup.idx] = curPktTup;
      cout << "[" << compressPktId << "@compressor]:" << " NEW FLOW " << pktLen << "B packet [cache idx: " << curPktTup.idx << "]"  << endl;      
      decompress(packet,pktLen, forward);
      // pcap_inject(pcap,packet,pktLen);
      return;
    }
    // 2.b. If its a hit, this is a subsequent packet that can be compressed.
    // build and return a compressed packet, update the cache.
    else {
      // Get the compressed header.
      compressedHeader_t compressedHeader;
      buildCompressedHeader(&compressedHeader, &curPktTup);
      // Assemble the compressed buffer.
      // [Ethernet Header] | [compressedHeader_t] | [Optional Fields] | [TCP/UDP payload]
      // Ethernet
      memcpy(compressedPktBuf, ethernetHeader, sizeof(*ethernetHeader));
      compressedPktLen += sizeof(*ethernetHeader);
      // adjust ether type for compressed packet.
      ether_header *modEthHdr = (ether_header *)compressedPktBuf;
      modEthHdr -> ether_type = htons(ETYPE_COMPRESSED);    

      // compressedHeader_t
      memcpy(compressedPktBuf + compressedPktLen, &compressedHeader, sizeof(compressedHeader));
      compressedPktLen += sizeof(compressedHeader);

      // optional fields
      if (compressedHeader.seqChange == 1){
        memcpy(compressedPktBuf + compressedPktLen, &(curPktTup.tcpHeader.seq), sizeof(curPktTup.tcpHeader.seq));
        compressedPktLen += sizeof(curPktTup.tcpHeader.seq);
      }
      if (compressedHeader.ackChange == 1){
        memcpy(compressedPktBuf + compressedPktLen, &(curPktTup.tcpHeader.ack_seq), sizeof(curPktTup.tcpHeader.ack_seq));
        compressedPktLen += sizeof(curPktTup.tcpHeader.ack_seq);
      }
      // tcp payload
      memcpy(compressedPktBuf + compressedPktLen, payload, payloadLen);
      compressedPktLen += payloadLen;

      // save current packet tuple to cache
      compressorCache[curPktTup.idx] = curPktTup;

      // Compression, emit compressed buffer.
      cout << "[" << compressPktId << "@compressor]:" << " compressed " << pktLen << "B packet to " << compressedPktLen << "B packet [cache idx: " << curPktTup.idx << "]"  << endl;      
      decompress(compressedPktBuf,compressedPktLen, forward);
      // pcap_inject(pcap,compressedPktBuf,compressedPktLen);
      return;
  }
}


/**
 *
 * Check the cache for the new packet's flow.
 *
 */
bool checkCache(compressorTuple_t curPktTup){  
  compressorTuple_t lastPkt = compressorCache[curPktTup.idx];
  // If all keys are equal, return true.
  if(lastPkt.ipHeader.saddr == curPktTup.ipHeader.saddr){
  if(lastPkt.ipHeader.daddr == curPktTup.ipHeader.daddr){
  if(lastPkt.tcpHeader.source == curPktTup.tcpHeader.source){
  if(lastPkt.tcpHeader.dest == curPktTup.tcpHeader.dest){
    return true;
  }
  }
  }
  }
  return false;
}

/**
 *
 * Build the compressed header from context and the current packet.
 *
 */
void buildCompressedHeader(compressedHeader_t *cHeader, compressorTuple_t *curPktTup) {
  compressorTuple_t lastPkt = compressorCache[curPktTup->idx];
  memset(cHeader, 0, sizeof(compressedHeader_t));

  // Set slot ID.  
  cHeader->slotId = curPktTup->idx;

  // Add the header fields that are always included.
  // IP.
  cHeader->tot_len = curPktTup->ipHeader.tot_len;
  cHeader->id = curPktTup->ipHeader.id;
  // TCP.
  cHeader->flags = curPktTup->tcpHeader.flags;
  cHeader->window = curPktTup->tcpHeader.window;
  cHeader->check = curPktTup->tcpHeader.check;
  cHeader->urg_ptr = curPktTup->tcpHeader.urg_ptr;

  // Set change flags.
  if (lastPkt.tcpHeader.seq != curPktTup->tcpHeader.seq) {
    cHeader->seqChange = 1;
  }
  if (lastPkt.tcpHeader.ack_seq != curPktTup->tcpHeader.ack_seq) {
    cHeader->ackChange = 1;
  }

}


/*=====  End of Compressor.  ======*/


/*======================================
=            Decompressor.            =
======================================*/

static compressorTuple_t decompressorCache[CACHE_SZ];
static uint32_t decompressPktId = 0;


void decompress(const u_char *packet, uint32_t pktLen, forward_fn forward){
  decompressPktId++;
  // Parsed input.
  const struct ether_header* ethernetHeader;
  const struct ipHeader_t* ipHeader;
  const struct tcpHeader_t* tcpHeader;
  const struct compressedHeader_t* cHeader;
  uint32_t cHeaderLen;
  const u_char *payload;
  uint32_t payloadLen;

  // Output packet.
  compressorTuple_t curPktTup;
  u_char decompressedPktBuf[1500];
  uint32_t decompressedPktLen = 0;

  ethernetHeader = (struct ether_header*)packet;
  // Standard TCP packet -- update local cache and emit.
  if (ntohs(ethernetHeader->ether_type) == ETHERTYPE_IP) {
      ipHeader = (struct ipHeader_t*)(packet + sizeof(struct ether_header));
    if (ipHeader->proto == 6){
      tcpHeader = (tcpHeader_t*)((u_char*)ipHeader + sizeof(*ipHeader));

      // Initialize tuple for current packet.
      curPktTup.ipHeader = *ipHeader;
      curPktTup.tcpHeader = *tcpHeader;
      curPktTup.len = pktLen;
      curPktTup.idx = ntohl((uint32_t)(curPktTup.ipHeader.saddr)) % CACHE_SZ; // TODO: use a hash function.

      // update cache.
      decompressorCache[curPktTup.idx] = curPktTup;

      // emit packet.
      cout << "[" << compressPktId << "@decompressor]:" << " NEW FLOW " << pktLen << "B packet [cache idx: " << curPktTup.idx << "]"  << endl;      
      forward(packet, pktLen);
      return;

    }
  }
  // Not a TCP packet, but not compressed -- just emit.
  else if (ntohs(ethernetHeader->ether_type) != ETYPE_COMPRESSED){
    forward(packet, pktLen);
    return;
  }
  // Compressed packet -- decompress and emit.
  else {
    // Parse compressed header
    cHeader = (compressedHeader_t*) (packet + sizeof(struct ether_header));
    // reconstruct original headers.
    cHeaderLen = buildDecompressedHeaders(&curPktTup, cHeader);
    // fill output buffer.
    // Ethernet.
    memcpy(decompressedPktBuf, (u_char *)ethernetHeader, sizeof(*ethernetHeader));
    decompressedPktLen += sizeof(*ethernetHeader);
    // fix ethertype.
    ether_header *modEthHdr = (ether_header *)decompressedPktBuf;
    modEthHdr -> ether_type = htons(ETHERTYPE_IP);    

    // IP
    memcpy(decompressedPktBuf+decompressedPktLen, (u_char *)&(curPktTup.ipHeader), sizeof(curPktTup.ipHeader));
    decompressedPktLen += sizeof(curPktTup.ipHeader);

    // TCP
    memcpy(decompressedPktBuf+decompressedPktLen, (u_char *)&(curPktTup.tcpHeader), sizeof(curPktTup.tcpHeader));
    decompressedPktLen += sizeof(curPktTup.tcpHeader);

    // Payload
    payload = packet + sizeof(*ethernetHeader) + cHeaderLen;
    payloadLen = pktLen - (sizeof(*ethernetHeader) + cHeaderLen);
    memcpy(decompressedPktBuf+decompressedPktLen, payload, payloadLen);
    decompressedPktLen += payloadLen;

    // Emit packet.
    cout << "[" << decompressPktId << "@decompressor]:" << " decompressed " << pktLen << "B packet to " << decompressedPktLen << "B packet [cache idx: " << curPktTup.idx << "]" << endl;
    forward(decompressedPktBuf, decompressedPktLen);

  }



}

// Build decompressed headers.
// Return length of compressed header.
uint32_t buildDecompressedHeaders(compressorTuple_t *curPktTup, const struct compressedHeader_t * cHeader){
  const u_char * condHdrPos = (const u_char *)cHeader + sizeof(*cHeader);

  // Get index from compressed header.
  curPktTup->idx = cHeader->slotId;

  // Look up last packet from this flow.
  compressorTuple_t lastPktTup = decompressorCache[curPktTup->idx];

  // fill IP header.
  // Fixed fields -- load from last packet tup.
  curPktTup->ipHeader.ihl_version = lastPktTup.ipHeader.ihl_version;
  curPktTup->ipHeader.tos = lastPktTup.ipHeader.tos;
  curPktTup->ipHeader.frag_off = lastPktTup.ipHeader.frag_off;
  curPktTup->ipHeader.ttl = lastPktTup.ipHeader.ttl;
  curPktTup->ipHeader.proto = lastPktTup.ipHeader.proto;
  curPktTup->ipHeader.saddr = lastPktTup.ipHeader.saddr;
  curPktTup->ipHeader.daddr = lastPktTup.ipHeader.daddr;
  // Carried fields -- load from header.
  curPktTup->ipHeader.tot_len = cHeader->tot_len;
  curPktTup->ipHeader.id = cHeader->id;
  // Computed fields -- TODO. (checksum)

  // fill TCP header.
  // Fixed fields
  curPktTup->tcpHeader.source = lastPktTup.tcpHeader.source;
  curPktTup->tcpHeader.dest = lastPktTup.tcpHeader.dest;
  // Carried fields
  curPktTup->tcpHeader.flags = cHeader->flags;
  curPktTup->tcpHeader.window = cHeader->window;
  curPktTup->tcpHeader.check = cHeader->check;
  curPktTup->tcpHeader.urg_ptr = cHeader->urg_ptr;

  // Conditional fields
  // Seq num.
  // If change, load from packet and update cache.
  if (cHeader->seqChange == 1) {
    curPktTup->tcpHeader.seq = *(const uint32_t *)condHdrPos;
    condHdrPos += sizeof(uint32_t);
    decompressorCache[curPktTup->idx].tcpHeader.seq = curPktTup->tcpHeader.seq;
  }
  // If no change, load from cache.
  else {
    curPktTup->tcpHeader.seq = lastPktTup.tcpHeader.seq;
  }
  // Ack num.
  if (cHeader->ackChange == 1) {
    curPktTup->tcpHeader.ack_seq = *(const uint32_t *)condHdrPos;
    condHdrPos += sizeof(uint32_t);
    decompressorCache[curPktTup->idx].tcpHeader.ack_seq = curPktTup->tcpHeader.ack_seq;
  }
  else {
    curPktTup->tcpHeader.ack_seq = lastPktTup.tcpHeader.ack_seq;
  }

  return (uint64_t)condHdrPos - (uint64_t)cHeader;

}

/*=====  End of Decompressor.  ======*/


