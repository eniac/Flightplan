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
pcap_t * output_handle;

// The functions that we pass to libpcap.
void compressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
void decompressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
void forwardHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet);
// Memory dump helper.
void print_hex_memory(void *mem, int len);

/**
 * @brief Forwards the provided frame to the configured output pcap handle.
 *
 * @param[in] packet Packet data to be send on the output interface
 * @param[in] len Size of the provided packet
 */
void forward_frame(const void * packet, int len) {
	if (NULL != output_handle) {
		pcap_inject(output_handle, packet, len);
	} else {
		pcap_inject(pcap, packet, len);
	}
}


int main(int argc, char *argv[]){
  // printHeaderSizes();
  // return 1;
  int opt = 0;
  int flow = 0;
  char *if_name = nullptr;
  char *oif_name = nullptr;
  char *opt_flow = nullptr;
  while ((opt =  getopt(argc, argv, "i:o:f:")) != EOF)
  {
    switch (opt)
    {
    case 'i':
      if_name = optarg;
      break;
    case 'o':
      oif_name = optarg;
      break;
    case 'f':
      opt_flow = optarg;
      flow = atoi(opt_flow);
      if(flow == 0)
        printf("\nPacket Flow is to Compressor booster \n");
      else if(flow == 1)
        printf("\nPacket Flow is to Decompressor booster \n");
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

  char output_errbuf[PCAP_ERRBUF_SIZE];
  output_errbuf[0]='\0';
  output_handle = pcap_open_live(oif_name, MTU, 0, 0, output_errbuf);
  if(output_handle == NULL) {
      fprintf(stderr,"%s:%s",oif_name, output_errbuf);	
  }

  switch(flow) {
	case 0:
		  // start packet processing loop for compress.
  		  if (pcap_loop(pcap, 0, compressHandler, NULL) < 0) {
				  cerr << "pcap_loop() failed: " << pcap_geterr(pcap);
				  return 1;
		  }
		  break;
	case 1:
		  // start packet processing loop for decompress.
		  if (pcap_loop(pcap, 0, decompressHandler, NULL) < 0) {
				  cerr << "pcap_loop() failed: " << pcap_geterr(pcap);
				  return 1;
		  }
		  break;
	case 2:
		  // start packet processing loop for forward.
		  if (pcap_loop(pcap, 0, forwardHandler, NULL) < 0) {
				  cerr << "pcap_loop() failed: " << pcap_geterr(pcap);
				  return 1;
		  }
		  break;
  }
  return 0;
}


void compressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {

    compress(packet, pkthdr->len, forward_frame);
    return;
}

void decompressHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {

    decompress(packet, pkthdr->len, forward_frame);

    return;
}

void forwardHandler(u_char *userData, const struct pcap_pkthdr* pkthdr, const u_char* packet) {

    forward_frame(packet, pkthdr->len);

    return;
}
