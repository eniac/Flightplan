#ifndef FEC_PCAP_H_
#define FEC_PCAP_H_
#include <pcap.h>

/** To be called from the pcap loop to handle an expired timer */
void booster_timeout_handler();

/** Sends the packet out on the configured pcap interface */
void forward_frame(const void *packet, int len);

/** The handler to be specified in each individual booster file */
void my_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);
#endif // FEC_PCAP_H_
