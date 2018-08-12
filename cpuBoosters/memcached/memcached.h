#ifndef MEMCACHED_H_
#define MEMCACHED_H_


typedef std::function<void(char *payload, size_t)> mcd_forward_fn;

bool call_memcached(char *packet, size_t packet_size, mcd_forward_fn forward);


#endif
