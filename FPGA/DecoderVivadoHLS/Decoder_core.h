#ifndef HEADER_DECODER_CORE_H

#include "Decoder.h"
#include "rse.h"

data_word Matrix_multiply_word(data_word Input[FEC_MAX_K], fec_sym Coefficients[FEC_MAX_K],
    unsigned k);

void Lookup_coefficients(fec_sym Coefficients[FEC_MAX_K], unsigned k, unsigned h,
    unsigned Output_packet, unsigned Missing_packet);

#endif
