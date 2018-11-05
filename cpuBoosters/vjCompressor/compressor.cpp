/**
 *
 * Empty booster. Reads packets, sends them back.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <pcap.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
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


using namespace std;

#define MTU 1500

pcap_t * pcap;

uint64_t byteCt, pktCt;

// The function that we pass to libpcap.
void boostHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
// Memory dump helper.
void print_hex_memory(void *mem, int len);


/*================================
=            Headers.            =
================================*/

// struct compressionControlHeader_t {
//   uint16_t slotId     : 10;
//   uint16_t __pad      : 4;
//   uint16_t newFlow    : 1;
//   uint16_t seqChange  : 1;
// };

struct compressedHeader_t {
  // Compressor control fields. 
  uint16_t slotId     : 16;
  uint8_t newFlow    : 1;
  uint8_t seqChange  : 1;
  uint8_t ackChange  : 1;
  uint8_t __pad      : 5;
  // Packet headers to always include.
  uint8_t tcpflags;
  uint16_t totalLen;
  uint16_t identification;
  uint16_t window;
  uint16_t checksum;
  uint16_t urg;
};

struct compressorTuple_t { 
  uint16_t len;
  uint16_t idx;

  // LEFT OFF HERE. Define specific IP and TCP headers.
  // IP headers.

  // TCP headers.
  uint8_t tcpflags;
  uint16_t totalLen;
  uint16_t identification;
  uint16_t window;
  uint16_t checksum;
  uint16_t urg;

  ip ipHeader;
  tcphdr tcpHeader;
};


// // Packet headers to include only if they've changed.
// struct varHeader_t {
//   uint32_t seqNum;
//   uint32_t ackNum;
// }


void printHeaderSizes(){
  printf("size compressionControlHeader_t: %li bytes\n",sizeof(compressedHeader_t));

}
/*=====  End of Headers.  ======*/

/*=========================================
=            Ported functions.            =
=========================================*/

void compressFunction(compressorTuple_t pkt);

/*=====  End of Ported functions.  ======*/



int main(int argc, char *argv[]){
  printHeaderSizes();
  return 1;
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
    const struct ip* ipHeader;
    const struct tcphdr* tcpHeader;
    const struct udphdr* udpHeader;
    char * payload;
    uint32_t payloadLen;

    bool doCompress = false;
    // Parse eth, ip, and tcp/udp headers.
    ethernetHeader = (struct ether_header*)packet;
    if (ntohs(ethernetHeader->ether_type) == ETHERTYPE_IP) {
        ipHeader = (struct ip*)(packet + sizeof(struct ether_header));
      if (ipHeader->ip_p == 6){
        tcpHeader = (tcphdr*)((u_char*)ipHeader + sizeof(*ipHeader));
        payload = (char *)tcpHeader + sizeof(*tcpHeader);
        payloadLen = (pkthdr -> len) - sizeof(*ipHeader) - sizeof(*tcpHeader);
        doCompress = true;
      }
      else if (ipHeader->ip_p == 17){
        udpHeader = (udphdr*)((u_char*)ipHeader + sizeof(*ipHeader));
        payload = (char *)udpHeader + sizeof(*udpHeader);
        payloadLen = (pkthdr -> len) - sizeof(*ipHeader) - sizeof(*udpHeader);
        // doCompress = true;
      }
    }

    // Compress -- inject modified packet buffer.
    if (doCompress){
      compressorTuple_t ct;
      ct.len = pkthdr -> len;
      memcpy(&ct.ipHeader, ipHeader, sizeof(ipHeader));
      memcpy(&ct.tcpHeader, tcpHeader, sizeof(tcpHeader));
      compressFunction(ct);
    }
    // Don't compress -- just inject packet unchanged.
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

void calculateIdx(compressorTuple_t *ct){
  uint16_t idx = (uint32_t)(ct -> ipHeader.ip_src.s_addr) % CACHE_SZ;
}

void compressFunction(compressorTuple_t ct) {
    bool isHit;
  if (ct.len > 100) {
    // TODO: replace this with a better function that uses full flow key.
    // 1. Calculate index.
    ct.idx = (uint32_t)(ct.ipHeader.ip_src.s_addr) % CACHE_SZ;
    // 2. Check if hit.

    // 2.a. If not hit, save this packet's header to the store and send the packet unmodified.
    if (isHit){

    }
    // 2.b. If its a hit, update the store and modify the packet header before tx.
    else {

    }


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
