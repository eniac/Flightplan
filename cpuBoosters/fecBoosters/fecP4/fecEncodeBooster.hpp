#ifndef FEC_ENCODE_BOOSTER_H
#include <functional>
#include "fecBooster.h"

typedef std::function<void(const u_char *, size_t)> forward_fn_t;

void fec_encode_p4_packet(const u_char *pkt, size_t sz_pkt,
                          const struct fec_header *fec,
                          int k, int h,
                          forward_fn_t forward_fn);

#endif //FEC_ENCODE_BOOSTER_H_
