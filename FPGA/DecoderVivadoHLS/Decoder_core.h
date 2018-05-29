#ifndef HEADER_DECODER_CORE_H

#include "Decoder.h"
#include "rse.h"

data_word Matrix_multiply_word(data_word Input[FEC_MAX_K], fec_sym Matrix[FEC_MAX_K][FEC_MAX_K],
    int Packet, int k);

void Lookup_matrix(fec_sym Matrix[FEC_MAX_K][FEC_MAX_K], packet_index Packet_indices[FEC_MAX_K]);

#endif
