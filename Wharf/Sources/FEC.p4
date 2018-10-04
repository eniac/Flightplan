#include "targets.h"
#include "Parsing.p4"
#include "LLDP.p4"
#include "Forwarding.p4"


@Xilinx_MaxLatency(200)
extern void get_fec_state(in tclass_t class, out bindex_t block_index, out pindex_t packet_index);
extern void print_headers();

control FecClassParams(in tclass_t tclass, out bit<FEC_K_WIDTH> k, out bit<FEC_H_WIDTH> h) {

    action set_k_h(bit<FEC_K_WIDTH> k_in, bit<FEC_H_WIDTH> h_in) {
        k = k_in;
        h = h_in;
    }

    table fec_params {
        key = {
            tclass : exact;
        }

        actions = { set_k_h; }
        default_action = set_k_h(0,0);
    }

    apply {
        fec_params.apply();
    }
}

control FecEncode(inout headers_t hdr, inout metadata_t meta) {
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

    bit<24> proto_and_port = 0;

    action classify(tclass_t tclass) {
        hdr.fec.setValid();
        hdr.fec.traffic_class = tclass;
    }

    // NOTE adding this line sends sdnet into tailspin during RTL simulation @Xilinx_ExternallyConnected
    table classification {
        key = {
            proto_and_port : exact;
        }

        actions = {classify; NoAction;}
        size = 64; // FIXME fudge
        default_action = classify(0);
    }

    apply {

        if (!hdr.eth.isValid()) {
            drop();
        }

        bit<1> is_ctrl;
        FECController.apply(hdr, meta, is_ctrl);
        if (is_ctrl == 1) {
            drop();
            return;
        }

        Forwarder.apply(meta);
        bit<1> faulty = 1;

        // TODO: Commenting out next line until lldp packets are tested
        get_port_status(meta.egress_spec, faulty);
        if (faulty == 1) {
            if (hdr.tcp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.tcp.dport;
            } else if (hdr.udp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.udp.dport;
            } else {
                proto_and_port = hdr.ipv4.proto ++ (bit<16>)0;
            }

            classification.apply();
            if (hdr.fec.isValid()) {
                FecClassParams.apply(hdr.fec.traffic_class, k, h);
                get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index);
                hdr.fec.orig_ethertype = hdr.eth.type;
                FEC_ENCODE(hdr.fec, k, h);
                hdr.eth.type = ETHERTYPE_WHARF;
            }
        }
    }
}

control FecDecode(inout headers_t hdr, inout metadata_t meta) {

    apply {
        bit<FEC_K_WIDTH> k = 0;
        bit<FEC_H_WIDTH> h = 0;

        Forwarder.apply(meta);
        if (hdr.fec.isValid()) {
            FecClassParams.apply(hdr.fec.traffic_class, k, h);
            hdr.eth.type = hdr.fec.orig_ethertype;
            FEC_DECODE(hdr.fec, k, h);
            if (hdr.fec.packet_index >= k) {
                drop();
            }
            hdr.fec.setInvalid();
        }
    }
}
