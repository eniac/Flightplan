#ifndef FEC_ENCODE_BOOSTER_HPP_
#define FEC_ENCODE_BOOSTER_HPP_
#include <functional>
#include "fecDefs.h"
#include "fecP4.hpp"

void fec_encode_p4_packet(const u_char *pkt, size_t pkt_size,
                          const struct fec_header *fec, int egress_port,
                          int k, int h, int t,
                          encode_forward_fn forward_fn);

void fec_encode_timeout_handler(encode_forward_fn forward_fn);

#endif //FEC_ENCODE_BOOSTER_HPP_
