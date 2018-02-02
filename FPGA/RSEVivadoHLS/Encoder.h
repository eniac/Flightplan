#ifndef HEADER_ENCODER_H

#include "rse.h"

void Incremental_encode(fec_sym Data, fec_sym Parity[FEC_MAX_H], int Packet_index, int h,
    int Clear);

#endif
