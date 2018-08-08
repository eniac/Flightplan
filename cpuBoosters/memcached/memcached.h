#ifndef MEMCACHED_H_
#define MEMCACHED_H_

bool call_memcached(char *packet, size_t packet_size,
                    char *udp, char *ipv4, char *eth);

#endif
