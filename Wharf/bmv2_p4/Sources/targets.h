#ifndef TARGETS_H_
#define TARGETS_H_


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

extern void fec_encode<T1,T2>(
          in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
          in eth_h eth, in ipv4_h ip, in T1 proto1, in T2 proto2
);
#define FEC_ENCODE(fec, k, h, ...) \
    fec_encode(fec, k, h, __VA_ARGS__)

extern void fec_decode(
        in eth_h eth, in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h
);
#define FEC_DECODE(eth, fec, k, h) \
    fec_decode(eth, fec, k, h)

#define DROP(meta) mark_to_drop()


/**********
 * IF THE TARGET IS SDNET
 **********/
#elif defined(TARGET_SDNET)

#include <xilinx.p4>

#define PORT_SIZE 12

#define metadata_t switch_metadata_t
#define SET_EGRESS(meta, port) meta.egress_port = port

extern void fec_encode(in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
                       out bit<FEC_PACKET_INDEX_WIDTH> packet_index);
#define FEC_ENCODE(fec, k, h, ...) \
    fec_encode(k, h, fec)

#else // defined(TARGET_XILINX)
#error("No target defined")
#endif

#endif //TARGETS_H_
