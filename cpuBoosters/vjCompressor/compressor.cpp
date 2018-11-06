/**
 *
 * Empty booster. Reads packets, sends them back.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <pcap.h>
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

pcap_t * pcap;

uint64_t byteCt, pktCt;

// The function that we pass to libpcap.
void boostHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
// Memory dump helper.
void print_hex_memory(void *mem, int len);






int main(int argc, char *argv[]){
  // printHeaderSizes();
  // return 1;
  int opt = 0;
  char *if_name = nullptr;
  while ((opt =  getopt(argc, argv, "i:")) != EOF)
  {
    switch (opt)
    {
    case 'i':
      if_name = optarg;
      break;
    default:
      printf("\nNot yet defined opt = %d\n", opt);
      abort();
    }
  }
  cout << "booster running on interface: " << if_name << endl;

  char pcap_errbuf[PCAP_ERRBUF_SIZE];
  pcap_errbuf[0]='\0';
  pcap=pcap_open_live(if_name,MTU,1,0,pcap_errbuf);
  if (pcap_errbuf[0]!='\0') {
      fprintf(stderr,"%s",pcap_errbuf);
  }
  if (!pcap) {
      exit(1);
  }
  // start packet processing loop.
  if (pcap_loop(pcap, 0, boostHandler, NULL) < 0) {
      cerr << "pcap_loop() failed: " << pcap_geterr(pcap);
      return 1;
  }
  return 0;
}

void boostHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {
    const struct ether_header* ethernetHeader;
    const struct ipHeader_t* ipHeader;
    const struct tcpHeader_t* tcpHeader;
    const struct udphdr* udpHeader;
    char * payload;
    uint32_t payloadLen;

    bool doCompress = false;
    // Parse eth, ip, and tcp/udp headers.
    ethernetHeader = (struct ether_header*)packet;
    if (ntohs(ethernetHeader->ether_type) == ETHERTYPE_IP) {
        ipHeader = (struct ipHeader_t*)(packet + sizeof(struct ether_header));
      if (ipHeader->proto == 6){
        tcpHeader = (tcpHeader_t*)((u_char*)ipHeader + sizeof(*ipHeader));
        payload = (char *)tcpHeader + sizeof(*tcpHeader);
        payloadLen = (pkthdr -> len) - sizeof(*ipHeader) - sizeof(*tcpHeader);
        doCompress = true;
      }
    }

    // Attempt compression.
    if (doCompress){
      char compressedPktBuf[pkthdr -> len];
      uint32_t compressedPktLen = 0;
      if (compress(compressedPktBuf, &compressedPktLen, pkthdr -> len, ethernetHeader, ipHeader, tcpHeader, payload, payloadLen)){
        // Compression, send compressed buffer.
        pcap_inject(pcap,compressedPktBuf,compressedPktLen);
      }
      else {
        // No compression, send unmodified packet.
        pcap_inject(pcap,packet,pkthdr -> len);

      }
    }
    // Don't attempt compression.
    else {
      pcap_inject(pcap,packet,pkthdr -> len);
      return;
    }

}


/*=========================================
=            Compressor State.            =
=========================================*/

#define CACHE_SZ 1024
compressorTuple_t compressorCache[CACHE_SZ];


/*=====  End of Compressor State.  ======*/

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

/**
 *
 * Main compress function.
 *
 */
bool compress(char * compressedPktBuf, uint32_t *compressedPktLen,
  uint32_t pktLen, 
  const struct ether_header* ethernetHeader, 
  const struct ipHeader_t* ipHeader,
  const struct tcpHeader_t* tcpHeader,
  char * payload, uint32_t payloadLen) {

  bool isHit;

  // Initialize tuple for current packet.
  compressorTuple_t curPktTup;
  curPktTup.ipHeader = *ipHeader;
  curPktTup.tcpHeader = *tcpHeader;
  curPktTup.len = pktLen;

  // 0. Check length.
  if (curPktTup.len < 100) {
    return false;
  }
  // 1. Calculate index into cache.
  curPktTup.idx = (uint32_t)(curPktTup.ipHeader.saddr) % CACHE_SZ; // TODO: use a hash function.

  // 2. Check if hit.
  isHit = checkCache(curPktTup);

  // 2.a. If not hit, this is the first packet in a flow. 
  // Save this packet's header to the cache and don't build a compressed packet.
  if (!isHit){
    compressorCache[curPktTup.idx] = curPktTup;
    return false;
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
    memcpy(compressedPktBuf, ethernetHeader, sizeof(ethernetHeader));
    (*compressedPktLen) += sizeof(ethernetHeader);
    // compressedHeader_t
    memcpy(compressedPktBuf + (*compressedPktLen), &compressedHeader, sizeof(compressedHeader));
    (*compressedPktLen) += sizeof(compressedHeader);
    // optional fields
    if (compressedHeader.seqChange == 1){
      memcpy(compressedPktBuf + (*compressedPktLen), &(curPktTup.tcpHeader.seq), sizeof(curPktTup.tcpHeader.seq));
      (*compressedPktLen) += sizeof(curPktTup.tcpHeader.seq);
    }
    if (compressedHeader.ackChange == 1){
      memcpy(compressedPktBuf + (*compressedPktLen), &(curPktTup.tcpHeader.ack_seq), sizeof(curPktTup.tcpHeader.ack_seq));
      (*compressedPktLen) += sizeof(curPktTup.tcpHeader.ack_seq);
    }
    // tcp payload
    memcpy(compressedPktBuf + (*compressedPktLen), payload, payloadLen);
    (*compressedPktLen) += payloadLen;

    // save current packet tuple to cache
    compressorCache[curPktTup.idx] = curPktTup;
    return true;
  }
}

void print_hex_memory(void *mem, int len) {
  int i;
  unsigned char *p = (unsigned char *)mem;
  for (i=0;i<len;i++) {
    printf("0x%02x ", p[i]);
    // if (i%16==0)
    //   printf("\n");
  }
  printf("\n");
}
