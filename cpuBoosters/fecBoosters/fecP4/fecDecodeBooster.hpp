#ifndef FEC_DECODE_BOOSTER_HPP_
#define FEC_DECODE_BOOSTER_HPP_
#include <functional>
#include "fecDefs.h"
#include "fecP4.hpp"

void fec_decode_p4_packet(const u_char *pkt, size_t pkt_size,
                          const struct fec_header *fec, int ingress_port,
                          int k, int h,
                          decode_forward_fn forward_fn, drop_fn_t drop_fn);

#endif //FEC_DECODE_BOOSTER_HPP_
