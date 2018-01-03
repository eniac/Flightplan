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
#include <sstream> // for ostringstream
#include <vector>
#include <deque>
#include <unordered_map>
#include <list>
#include "rse.h"


using namespace std;

// Simple passthrough booster. 

pcap_t * descr_in, *descr_out, *pcap;

uint64_t byteCt;
uint64_t pktCt;
uint64_t uncompressedCt = 0;
uint64_t compressedCt = 0;

int procId;

// The function that we pass to libpcap.
void boostHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
// Memory dump.
void print_hex_memory(void *mem, int len);



enum {
    RING_BUFFER_BYTES = 1024 * 128,
    MAXPACKETSIZE = 1500
//  BLOCK_BYTES = 1024 * 64,
};


uint8_t cur_groupId = 0;
uint8_t cur_pktIdx = 0;

int main(int argc, char *argv[]){
  int rc;
  if ((rc = rse_init()) != 0 ) exit(rc);   /* initialize fec codewords */
  fb.block_C = 1600;
  fb.block_N = 5;


  char pcap_errbuf[PCAP_ERRBUF_SIZE];
  pcap_errbuf[0]='\0';
  const char *if_name = argv[1]; //"enp5s0f1";
  // procId = atoi(argv[2]); // 
  pcap=pcap_open_live(if_name,MAXPACKETSIZE,0,0,pcap_errbuf);
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


  // if (pcap_inject(pcap,&req,sizeof(req))==-1) {
  //     pcap_perror(pcap,0);
  //     pcap_close(pcap);
  //     exit(1);
  // }



char outPktBuf[MAXPACKETSIZE];

// char packetBuf[5][1600];
fec_sym p[FEC_MAX_N][FEC_MAX_COLS];   /* storage for packets in FEC block (fb) */

void boostHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {


  // check if encode or decode. 

  // encode. 

  // get codeword index. 

  // send out with group ID and codeword index. 

  // get, on the other side. 

  // mark known for each. 
  // when you get something from next batch:
  // if all known, send out packets. 
  // else, decode. 


    pktCt += 1;
    const struct ether_header* ethernetHeader;
    char * ethPayload;
    uint32_t ethPayloadLen;

    ethernetHeader = (struct ether_header*)packet;
    ethPayload = (char *)ethernetHeader + sizeof(*ethernetHeader);
    uint8_t boostStatus = ethPayload[0];
    uint8_t fecGroupId = ethPayload[1];
    uint8_t fecPacketId = ethPayload[2];
    std::cout << "------- Eth packet in booster -------" << std::endl;
    std::cout << "group id: " << unsigned(fecGroupId) << " packet id: " << unsigned(fecPacketId) << std::endl;
    std::cout << "raw bytes: " << std::endl;
    print_hex_memory((void *)ethernetHeader, 17);
    print_hex_memory((void *)ethernetHeader, 14);
    std::cout << "..." << std::endl;
    std::cout << "---------------------------------" << std::endl;
    // std::cout << "boost status: " << unsigned(boostStatus) << " fec packet type: " << unsigned(fecPacketType) << " packet id: " << unsigned(fecPacketId) << std::endl;
    ethPayload = (char *)ethernetHeader + sizeof(*ethernetHeader) + 5;
    ethPayloadLen = (pkthdr -> len)-sizeof(*ethernetHeader) - 5;

    uint32_t outPktLen = (pkthdr -> len);//sizeof(*ethernetHeader) + ethPayloadLen;
    // pcap_inject(pcap,packet,outPktLen);




    // if (boostStatus == 2){
    //   std::cout << "got ENCODE packet." << std::endl;
    //   // copy to fec block.
    //   fb.pdata[cur_pktIdx] = p[cur_pktIdx];      
    //   memcpy(p[cur_pktIdx], ethPayload, ethPayloadLen);
    //   fb.plen[cur_pktIdx] = ethPayloadLen;
    //   fb.pstat[cur_pktIdx] = FEC_FLAG_KNOWN;
    //   fb.cbi[cur_pktIdx] = cur_pktIdx;
    //   // increment 
    //   fb.block_N++;
    //   if (ethPayloadLen > fb.block_C){
    //     fb.block_C = ethPayloadLen;
    //   }
    //   // get the parity packets and send if you have enough to do it. 
    //   if (cur_pktIdx == 2){
    //     std::cout << "attempting encode.." << std::endl;
    //     for (int i = 1; i<=2; i++){
    //       fb.pdata[cur_pktIdx+i] = p[cur_pktIdx+i];
    //       fb.cbi[cur_pktIdx+i] = FEC_MAX_N - i - 1;
    //       fb.plen[cur_pktIdx+i] = fb.block_C;
    //       fb.pstat[cur_pktIdx+i] = FEC_FLAG_WANTED;
    //     }
    //     cur_pktIdx = 0;
    //     // fec_block_print();
    //     int retVal = rse_code(1);
    //     std::cout << "ret: " << retVal << std::endl;        
    //     // fec_block_print();

    //     // send out the 3 + 2 packets. 
    //     for (int i = 0; i<5; i++){
    //       std::cout << "sending packet with payload length: " << fb.plen[i] << std::endl;
    //     }
    //   }
    //   else{
    //     fb.block_C = 0;
    //     cur_pktIdx++;
    //   }



    // }
    // else if (boostStatus == 4){
    //   std::cout << "got DECODE packet." << std::endl;
    // }
    // else {
    //   std::cout << "got invalid request." << std::endl;
    // }



    // memcpy(outPktBuf, (char *)ethernetHeader, sizeof(*ethernetHeader));
    // memcpy(outPktBuf+sizeof(*ethernetHeader), ethPayload, ethPayloadLen);

    // std::cout << "packet count: " << pktCt << std::endl;
    // std::cout << "in packet: " << sizeof(*ethernetHeader)+ethPayloadLen << std::endl;
    // print_hex_memory((void *)packet, 20);
    // std::cout << "out packet: " << outPktLen << std::endl;
    // print_hex_memory(outPktBuf, 20);

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
