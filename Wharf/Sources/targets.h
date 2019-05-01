#ifndef TARGETS_H_
#define TARGETS_H_

extern void drop();

/*********
 * IF THE TARGET IS THE P4 BEHAVIORAL MODEL
 *********/
#if defined(TARGET_BMV2)
#include "v1model.p4"
#include "Parsing.p4"

// Hardware port size
#define PORT_SIZE 9

// Metadata and interface to egress port
#define metadata_t standard_metadata_t
#define SET_EGRESS(meta, port) meta.egress_spec = port

#define FEC_ENCODE(fec, k, h) \
    fec_encode(fec, k, h)

#define FEC_DECODE(fec, k, h) \
    fec_decode(fec, k, h)


/**********
 * IF THE TARGET IS SDNET
 **********/
#elif defined(TARGET_SDNET)

#include <xilinx.p4>

#define PORT_SIZE 12

#define metadata_t switch_metadata_t
#define SET_EGRESS(meta, port) meta.egress_port = port

// We need at least space for one packet or the encoder will deadlock.
@Xilinx_MaxLatency(200)
extern void fec_encode(in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
                       out bit<FEC_PACKET_INDEX_WIDTH> packet_index);
#define FEC_ENCODE(fec, k, h) \
    fec_encode(k, h, fec.packet_index)

#else // defined(TARGET_XILINX)
#error("No target defined")
#endif

#endif //TARGETS_H_
