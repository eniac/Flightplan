#include "Bmv2Definitions.p4"

extern void update_fec_state(in tclass_t tclass,
                             in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
                             out bindex_t block_index, out pindex_t packet_index);

extern void fec_encode(in fec_h fec,
                       in bit<FEC_K_WIDTH> k,
                       in bit<FEC_H_WIDTH> h);

extern void fec_decode(in fec_h fec,
                       in bit<FEC_K_WIDTH> k,
                       in bit<FEC_H_WIDTH> h);

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

    action set_fec_class(tclass_t tclass) {
        hdr.fec.setValid();
        hdr.fec.traffic_class = tclass;
    }

    table fec_class {
        key = {
            proto_and_port : ternary;
        }
        actions = {set_fec_class; NoAction;}
        default_action = set_fec_class(0);
    }

    apply {
        if (hdr.tcp.isValid()) {
            proto_and_port = hdr.ipv4.proto ++ hdr.tcp.dport;
        } else if (hdr.udp.isValid()) {
            proto_and_port = hdr.ipv4.proto ++ hdr.udp.dport;
        } else {
            proto_and_port = hdr.ipv4.proto ++ (bit<16>)0;
        }

        fec_class.apply();
        if (hdr.fec.isValid()) {
            fec_params.apply();
            if (k != 0) {
                update_fec_state(hdr.fec.traffic_class, k, h,
                                 hdr.fec.block_index, hdr.fec.packet_index);
                hdr.fec.orig_ethertype = hdr.eth.type;
                hdr.fp.setInvalid();
                fec_encode(hdr.fec, k, h);
                hdr.fp.setValid();
                hdr.eth.type = ETHERTYPE_WHARF;
            } else {
                hdr.fec.setInvalid();
            }
        }

        md.egress_spec = md.ingress_port;
    }
}

Bmv2Switch(Encode) main;
