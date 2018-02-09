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

pcap_t * descr_in, *descr_out, *pcap;

uint64_t byteCt, pktCt;

// The function that we pass to libpcap.
void boostHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
// Memory dump helper.
void print_hex_memory(void *mem, int len);

int main(int argc, char *argv[]){
  int opt = 0;
  char *if_name;
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
    char * ethPayload;
    uint32_t ethPayloadLen;
    // Minimal packet parsing. 
    pktCt += 1;
    ethernetHeader = (struct ether_header*)packet;
    ethPayload = (char *)ethernetHeader + sizeof(*ethernetHeader);
    // Print packet.
    // std::cout << "raw bytes: " << std::endl;
    // print_hex_memory((void *)ethernetHeader, 14);
    // std::cout << "..." << std::endl;
    // std::cout << "---------------------------------" << std::endl;

    // Send the packet back out. 
    uint32_t outPktLen = (pkthdr -> len);
    pcap_inject(pcap,packet,outPktLen);
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
