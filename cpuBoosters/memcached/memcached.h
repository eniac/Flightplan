#ifndef MEMCACHED_H_
#define MEMCACHED_H_
#include <functional>

using mcd_forward_fn = std::function<void(char *payload, size_t)>;

bool call_memcached(const char *packet, size_t packet_size, mcd_forward_fn forward);


#endif
