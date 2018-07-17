#ifndef FEC_DECODE_BOOSTER_HPP_
#define FEC_DECODE_BOOSTER_HPP_
#include <functional>
#include "fecDefs.h"
#include "fecP4.hpp"

void fec_decode_p4_packet(const u_char *pkt, size_t sz_pkt,
                          const struct fec_header *fec,
                          int k, int h,
                          forward_fn_t forward_fn);

#endif //FEC_DECODE_BOOSTER_HPP_
