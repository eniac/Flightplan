#include <pcap.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <arpa/inet.h>

#include <math.h>
#include <stdlib.h>
#include <byteswap.h>

#include <iostream>
#include <fstream>
#include <cstring>
#include <sstream> // for ostringstream
#include <vector>
#include <deque>
#include <unordered_map>
#include <list>
#include <utility>


using namespace std;

// Parses timestamps out of packets.

// Simple packet processor that tracks per-flow packet counts.


// g++ parser.cpp -o parser -lpcap -std=c++11
// ./parser ./tmp.pcap


// The input PCAP.
char * inputFile;

struct telemetry_header {
  uint32_t pktId;
  uint16_t hopId;
  uint16_t pktLen;
  uint64_t  ingressTs;
  uint64_t  egressTs;
};



// // vector<pair<uint64_t, uint64_t>> testVec;
// // stores initial ingress time of packet.
// std::unordered_map<uint32_t, uint64_t > packetTable;

// The function that we pass to libpcap.
void packetHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);

// Memory dump.
void print_hex_memory(void *mem, int len);

void printHeader();

int main(int argc, char *argv[]){
  if (argc != 2){
    cout << "incorrect number of arguments. Need 1. (filename)." << endl;
    exit(0);
  }
  inputFile = argv[1];
  cout << "reading from file: " << inputFile << endl;

  // Process packets. 
  pcap_t *descr;
  char errbuf[PCAP_ERRBUF_SIZE];
  // open capture file for offline processing
  descr = pcap_open_offline(inputFile, errbuf);

  printHeader();

  if (descr == NULL) {
      cerr << "pcap_open_live() failed: " << errbuf << endl;
      return 1;
  }
  // start packet processing loop, just like live capture
  if (pcap_loop(descr, 0, packetHandler, NULL) < 0) {
      cerr << "pcap_loop() failed: " << pcap_geterr(descr);
      return 1;
  }

  return 0;
}

void printHeader() {
  cout << "pktId, hopId, ingressTs, egressTs, delta" << endl;
}

void packetHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {
  const struct ether_header* ethernetHeader;
  const struct telemetry_header * telemetryHeader;

  ethernetHeader = (struct ether_header*)packet;
  telemetryHeader = (struct telemetry_header*) (packet + sizeof(ether_header));
  telemetry_header th;
  memcpy(&th, telemetryHeader, sizeof(th));
  th.pktId = bswap_32(th.pktId);
  th.hopId = bswap_16(th.hopId);
  th.pktLen = bswap_16(th.pktLen);
  th.ingressTs = bswap_64(th.ingressTs);
  th.egressTs = bswap_64(th.egressTs);

  // compute dela of time through switch.
  uint64_t delta = th.egressTs - th.ingressTs;


  // Print the stats for this packet at this hop.
  cout << th.pktId << ", " << th.hopId << ", " << th.pktLen << ", " << th.ingressTs << ", " << th.egressTs << ", " << delta << endl;



  // uint32_t pktId;
  // uint16_t hopId;
  // uint16_t pktLen;
  // uint64_t  ingressTs;
  // uint64_t  egressTs;


  // // If the packet's key is not in the flow table, print its key. 
  // auto got = flowTable.find(pkt.keyStr);
  // if (got == flowTable.end()){
  //   cout << "adding new flow to table. Key:" << endl;
  //   print_hex_memory(pkt.key, KEYLEN);
  // }

  // // Increment flow counter -- this auto inserts if the key is not there. 
  // flowTable[pkt.keyStr] +=1;


}

// Helpers.
// Get 64 bit timestamp.
uint64_t getMicrosecondTs(uint32_t seconds, uint32_t microSeconds){
  uint64_t ts = seconds * 1000000 + microSeconds;
  return ts;
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
