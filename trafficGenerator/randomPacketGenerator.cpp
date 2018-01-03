/**
 *
 * Middlebox tester / profiler. 
 * Generates, sends, and receives batches of random ethernet packets. 
 * Checks correctness of received packets and measures receiver throughput. 
 * Usage: sudo ./randomPacketGenerator <interface> <num packets>
 *
 */

#include <pcap.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <net/if.h>
#include <time.h>

#include <math.h>
#include <stdlib.h>
#include <unistd.h>
#include<stdlib.h>
#include<sys/wait.h>

#include <iostream>
#include <fstream>
#include <cstring>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <list>


using namespace std;

// maximum packet size.
#define MTU 1500
#define TIMEOUT 1000

// tx and rx buffers.
vector<struct pcap_pkthdr> txHdrs, rxHdrs;
vector<char> txPktBuf, rxPktBuf;
// pcap device fp used by both tx and rx processes.
pcap_t *adhandle;

// sleep interval (nanoseconds).
struct timespec sleepInterval, sleepLeft;

// tx packet set.
std::unordered_set<std::string> txSet;

// Make a bunch of packets. Stash them in a buffer.
uint32_t genPackets(uint32_t pktCt);

// Open port, dump packets.
void txProcess();

// Read packets to inBuffer.
void rxProcess();
void rxHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);

// Make sure RX and TX packets are the same. 
void checkRxCount();
void checkRxPacketCorrectness();

// Compute throughput based on RX timestamps.
void computeThroughput();

// Helpers.
uint64_t getMicrosecondTs(uint32_t seconds, uint32_t microSeconds);
void print_hex_memory(void *mem, int len);

int main(int argc, char *argv[]){
  /**
   *
   * Parameters: 
   * <interface> <packet count> 
   */
  
  // Parse input. 
  char * if_name = argv[1];
  uint32_t packetCount = atoi(argv[2]);

  uint32_t pktBufSz = genPackets(packetCount);

  // Open interface.
  char pcap_errbuf[PCAP_ERRBUF_SIZE];
  pcap_errbuf[0]='\0';
  adhandle=pcap_open_live(if_name,MTU,1,TIMEOUT,pcap_errbuf);
  if (pcap_errbuf[0]!='\0') {
      fprintf(stderr,"%s",pcap_errbuf);
  }
  if (!adhandle) {
      exit(1);
  }

  // Fork into tx and rx processes. 
  pid_t pid = fork();
  if (pid == 0) {    
    // child process: do tx.
    txProcess();
    exit(0);
  }
  else if (pid > 0) {
    // parent process: do rx.
    rxProcess();
    // check outputs.
    checkRxCount();
    checkRxPacketCorrectness();
    computeThroughput();
    wait(NULL);
  }
  else {
    // fork failed
    printf("fork() failed!\n");
    return 1;
  }

  return 0;
}

uint32_t genPackets(uint32_t pktCt) {
  vector<uint32_t> pktSizes;
  uint64_t totalBytes = 0;
  // select random packet sizes from 64 to MTU bytes.
  for (int i = 0; i<pktCt; i++){
    uint32_t pktSize = rand() % ((MTU) + 1 - (64)) + (64);
    pktSizes.push_back(pktSize);
    totalBytes += pktSize;
  }
  // reserve memory. 
  cout << "reserving memory for " << pktCt << " packets and " << totalBytes << " bytes" << endl;
  txHdrs.reserve(pktCt);
  rxHdrs.reserve(pktCt);
  txPktBuf.reserve(totalBytes);
  rxPktBuf.reserve(totalBytes);

  // fill tx headers and packets. 
  cout << "filling tx buffer with " << totalBytes << " random bytes." << endl;
  uint32_t pktId = 0;
  uint32_t curIdx = 0;
  for (auto pktSize : pktSizes){
    struct pcap_pkthdr hdr;
    hdr.caplen = pktSize;
    hdr.len = pktSize;
    txHdrs.push_back(hdr);    
    char pktBuf[pktSize];
    // Ethernet header.
    for (int i = 0; i<12; i++)
      pktBuf[i] = rand()%256;
    // use public ethertype
    pktBuf[12] = 0x88;
    pktBuf[13] = 0xb6;
    // packet id (for internal accounting).
    for (int i = 0; i<4; i++)
      pktBuf[i+14] = ((char *)&pktId)[i];
    // rest of packet.
    for (int i = 18; i<pktSize; i++)
      pktBuf[i] = rand() % 256;

    // add to streaming buffer.
    for (int i = 0; i<pktSize; i++)
      txPktBuf.push_back(pktBuf[i]);

    // add to packet map.
    string pktStr = string(pktBuf, pktSize);
    txSet.emplace(pktStr);
    pktId++;
    curIdx += pktSize;
  }
  return totalBytes;
}

void txProcess(){
  cout << "starting packet tx" << endl;
  uint32_t txPktCt = 0;

  uint32_t bufPos = 0;
  for (auto hdr : txHdrs){
    pcap_inject(adhandle,(char *)(&txPktBuf[bufPos]),hdr.len);
    bufPos += hdr.len;
    // nanosleep(&sleepInterval, &sleepLeft);
    txPktCt++;
  }
  cout << "# tx packets: " << txPktCt << endl;
}

void rxProcess(){
  pcap_setdirection(adhandle, PCAP_D_IN);
  cout << "starting packet rx" << endl;
  // start packet processing loop.
  uint32_t rxPktCt = 0;
  int doRx = 1;
  struct pcap_pkthdr *pkt_header;
  const u_char *pkt_data;
  while(doRx == 1){
    // get next packet.
    doRx = pcap_next_ex(adhandle, &pkt_header, &pkt_data);    
    if (doRx == 1){
      // copy header and packet bytes to buffers.
      rxHdrs.push_back(*pkt_header);
      rxPktBuf.insert(rxPktBuf.end(), pkt_data, pkt_data+(pkt_header->len));
      // increment counter.
      rxPktCt++;
    }
  }
  cout << "# rx packets: " << rxPktCt << endl;
}

void checkRxCount(){
  /**
   *
   * Check count of received packets.
   *
   */
  uint32_t rxCt = rxHdrs.size();
  uint32_t txCt = txHdrs.size();
  cout << "tx count: " << txCt << " rx count: " << rxCt << endl;
  if (txCt == rxCt)
    cout << "\tOK." << endl;
  else
    cout <<"\tINCORRECT." << endl;
}


void checkRxPacketCorrectness(){
  /**
   *
   * Check correctness of received packets.
   *
   */
  
  uint32_t incorrectLenCt = 0;
  uint32_t missingCt = 0;
  uint32_t dupCt = 0;
  uint32_t malformedCt = 0;

  std::unordered_map<uint32_t, uint32_t> rxPktIdCts;
  for (int i = 0; i<txHdrs.size(); i++){
    rxPktIdCts.emplace(i, 0);
  }

  cout << "comparing TX and RX packets." << endl;
  uint32_t bufPos = 0;
  cout << "rxbuf size: " << rxPktBuf.size() << endl;
  for (auto hdr : rxHdrs){

    // get length and embedded packet id. 
    uint32_t rxLen = hdr.caplen;
    uint32_t rxPktId = 0;
    for (int i = 0; i<4; i++)
      ((char *) &rxPktId)[i] = rxPktBuf[bufPos+14+i];
    // cout << "packet id: " << rxPktId << " len: " << rxLen << endl;

    // bogus ID --> packet is malformed, also need to skip.
    if (rxPktId >= txHdrs.size()){
      malformedCt++;
      bufPos+=rxLen;
      continue;
    }
    // count number of times this ID has been RXed.
    rxPktIdCts[rxPktId]++;
    if (rxPktIdCts[rxPktId] > 1){
      cout << "\tpacket ID: " << rxPktId << " dup count: " << rxPktIdCts[rxPktId] << endl;
    }

    // check length. 
    uint32_t txLen = txHdrs[rxPktId].caplen;
    if (rxLen != txLen){
      cout << "\tpacket ID < " << rxPktId << " > has incorrect len! (len: " << rxLen << " expected: " << txLen << ")" << endl;
      incorrectLenCt++;
      bufPos+=rxLen;
      continue;
    }

    // check if packet is malformed. 
    string rxPktStr = string(&rxPktBuf[bufPos], rxLen);    
    auto got = txSet.find(rxPktStr);
    // exact packet not found in tx set --> malformed
    if (got == txSet.end())
      malformedCt++;

    // move to next packet.
    bufPos+=rxLen;
  }

  // count missing and dups.
  for (auto kv : rxPktIdCts){
    if (kv.second == 0){
      // cout << "packet id " << kv.first << " is missing " << endl;
      missingCt++;
    }
    else if (kv.second > 1){
      dupCt++;
    }
  }
  cout << "correctness stats:" << endl;
  cout << "\tmissing: " << missingCt << endl;
  cout << "\tincorrect length: " << incorrectLenCt << endl;
  cout << "\tmalformed: " << malformedCt << endl;
  cout << "\tduplicated: " << dupCt << endl;
  cout << "------------------" << endl;


}
void computeThroughput(){
  /**
   *
   * Compute throughput based on RX packets.
   *
   */
  uint64_t firstTs = getMicrosecondTs(rxHdrs.front().ts.tv_sec, rxHdrs.front().ts.tv_usec);
  uint64_t lastTs = getMicrosecondTs(rxHdrs.back().ts.tv_sec, rxHdrs.back().ts.tv_usec);
  uint64_t pktCt = 0;
  uint64_t byteCt = 0;
  for (auto hdr : rxHdrs){
    pktCt ++;
    byteCt += hdr.caplen;
  }
  uint64_t runTime_ms = (lastTs - firstTs)/1000;
  float pktRate_ms = float(pktCt) / float(runTime_ms);
  float pktRate_s = pktRate_ms * 1000;

  float bitRate_ms = float(byteCt*8) / float(runTime_ms);
  float bitRate_s = bitRate_ms * 1000;
  float mbitRate_s = bitRate_s / 1000000;
  cout << "performance stats:" << endl;
  cout << "\tavg packet throughput: " << pktRate_s << " (pkts/s)" << endl;
  cout << "\tavg bit throughput: " << mbitRate_s << " (Mb/s)" << endl;
}


uint64_t getMicrosecondTs(uint32_t seconds, uint32_t microSeconds){
  /**
   *
   * Convert pcap header timestamp into 64 bit microsecond timestamp. 
   * usage: getMicrosecondTs(pkthdr->ts.tv_sec, pkthdr->ts.tv_usec);
   *
   */  
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
