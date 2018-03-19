/**
 *
 * Simple libpcap based booster harness. Reads ethernet
 * packets and sends them out of the same port.
 * Usage: sudo ./passthrough <interface>
 * sudo ./passthrough enp65s0
 *
 */

#include <signal.h>
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

#include "fecDefs.h"

using namespace std;

#define MTU 1500
#define FEC_ETHER_TYPE 0x81C

/**
 * Models the tofino's functionality:
 * Adds booster header to packets from inVeth, sends out of outVeth.
 *
 */
pcap_t *pcapInterface;

uint8_t K, H; // number of data and parity packets.
uint8_t blockId, pktId; // current block and packet ID.
uint64_t pktCt, injectedPktCt; // internal counters.

void tofinoHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
void print_hex_memory(void *mem, int len);
void intHandler(int dummy) {
  pcap_close(pcapInterface);
  cout << "processed " << pktCt << " data packets" << endl;
  cout << "added " << injectedPktCt << " parity packets" << endl;
  exit(0);
}

int main(int argc, char *argv[]) {
  char pcap_errbuf[PCAP_ERRBUF_SIZE];
  pcap_errbuf[0] = '\0';
  if (argc != 4) {
    cout << "usage: ./tofinoModel <interface> <# data packets (K)> <# parity packets (H)>" << endl;
  }
  const char *intfName = argv[1]; //"enp5s0f1";
  cout << "reading / writing from interface: " << intfName << endl;
  K = atoi(argv[2]);
  H = atoi(argv[3]);
  blockId = pktId = 0;
  pktCt = injectedPktCt = 0;
  cout << "K = " << int(K) << " H = " << int(H) << endl;
  pcapInterface = pcap_open_live(intfName, MTU, 1, 0, pcap_errbuf);

  if (pcap_errbuf[0] != '\0') {
    fprintf(stderr, "%s", pcap_errbuf);
  }
  if (!pcapInterface) {
    cout << "error opening interface " << intfName << endl;
    exit(1);
  }
  // start packet processing loop.
  signal(SIGTERM, intHandler);
  if (pcap_loop(pcapInterface, 0, tofinoHandler, NULL) < 0) {
    cerr << "pcap_loop() failed: " << pcap_geterr(pcapInterface);
    return 1;
  }
  pcap_close(pcapInterface);
  cout << "processed " << pktCt << " packets and added " << injectedPktCt << " parity packets." << endl;
  return 0;
}

void tofinoHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {
  struct ether_header * ethHeader;
  u_char * ethPayload;
  struct fec_header fecHeader;
  uint plLen = pkthdr->len - sizeof(ether_header);

  /*Adding u_short to total size, to accommodate new ether type.*/
  uint outPktLen = sizeof(ether_header) + sizeof(fec_header) + sizeof(u_short) + plLen;
  u_char outPkt[outPktLen];

  // Fill fec header.
  fecHeader.index = pktId;
  fecHeader.block_id = blockId;
  fecHeader.class_id = 1; /*random value for testing*/

  /* Build tagged data packet to send out. */
  ethHeader = (struct ether_header *) packet;

  /* store the old ether type and update the ether type to FEC ether type */
  u_short oldEtherType = ethHeader->ether_type;
  ethHeader->ether_type = FEC_ETHER_TYPE;

  ethPayload = (u_char *) packet + sizeof(ether_header) + sizeof(u_short);

  memcpy(outPkt, ethHeader, sizeof(ether_header));
  memcpy(outPkt + sizeof(ether_header), &fecHeader, sizeof(fec_header));
  memcpy(outPkt + sizeof(ether_header) + sizeof(fec_header), &oldEtherType, sizeof(u_short));
  memcpy(outPkt + sizeof(ether_header) + sizeof(fec_header) + sizeof(u_short), ethPayload, plLen);

  // std::cout << "raw bytes: " << std::endl;
  // print_hex_memory((void *)ethernetHeader, 14);
  // std::cout << "..." << std::endl;
  // std::cout << "---------------------------------" << std::endl;
  // Send the data packet out.
  pcap_inject(pcapInterface, outPkt, sizeof(*ethHeader) + sizeof(fecHeader) + sizeof(u_short) + plLen);
  pktId++;
  // Send tagged parity packets out if necessary, adjusting their fecHeaders.
  if (pktId == K) {
    for (int i = 0; i < H; i++) {
      fecHeader.index = pktId;
      memcpy(outPkt + sizeof(*ethHeader), &fecHeader, sizeof(fecHeader));
      pcap_inject(pcapInterface, outPkt, sizeof(*ethHeader) + sizeof(fecHeader) + sizeof(u_short) + plLen);
      pktId++;
      injectedPktCt++;
    }
    pktId = 0;
    blockId++;
  }

  pktCt++;
}

void print_hex_memory(void *mem, int len) {
  int i;
  unsigned char *p = (unsigned char *)mem;
  for (i = 0; i < len; i++) {
    printf("0x%02x ", p[i]);
  }
  printf("\n");
}
