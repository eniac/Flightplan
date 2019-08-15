#ifndef HDRCOMPRESS_H_
#define HDRCOMPRESS_H_
#include <functional>
using mcd_forward_fn = std::function<void(char *payload, size_t, int reverse)>;

bool call_compress(const char *packet, size_t packet_size, mcd_forward_fn forward);

bool call_decompress(const char *packet, size_t packet_size, mcd_forward_fn forward);

#endif
