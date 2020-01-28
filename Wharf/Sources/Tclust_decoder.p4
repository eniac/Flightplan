#include "Bmv2Definitions.p4"

extern void fec_decode_fp(in fec_h fec,
                          in bit<FEC_K_WIDTH> k,
                          in bit<FEC_H_WIDTH> h,
                          in flightplan_h fp);

control Encode(inout headers_t hdr,
               inout booster_metadata_t bmd,
               inout metadata_t md) {

    bit<24> proto_and_port = 0;
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

    action set_k_h(bit<FEC_K_WIDTH> k_in, bit<FEC_H_WIDTH> h_in) {
        k = k_in;
        h = h_in;
    }

    table fec_params {
        key = {
            hdr.fec.traffic_class : exact;
        }
        actions = { set_k_h; NoAction; }
        default_action = NoAction;
    }


    apply {
        if (hdr.fec.isValid()) {
            fec_params.apply();
            hdr.eth.type = hdr.fec.orig_ethertype;
            fec_decode_fp(hdr.fec, k, h, hdr.fp);
            if (hdr.fec.isValid() && hdr.fec.packet_index >= k) {
                drop();
                return;
            }
            hdr.fec.setInvalid();
        }

        md.egress_spec = md.ingress_port;
    }
}

Bmv2Switch(Encode) main;
