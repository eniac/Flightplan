#include "Bmv2Definitions.p4"

control OffloadForwarder(inout headers_t hdr,
                         inout booster_metadata_t bmd,
                         inout metadata_t md) {

    action set_to_segment(bit<SEGMENT_DESC_SIZE> to_segment) {
        hdr.fp.to_segment = to_segment;
    }

    action do_drop() {
        drop();
    }

    table advance_fp_hdr {
        key = {
            hdr.fp.from_segment : ternary;
            hdr.ipv4.proto : ternary;
            hdr.eth.dst : ternary;
        }

        actions = {
            set_to_segment;
            do_drop;
        }

        default_action = do_drop;
    }

    action set_booster_egress(bit<9> port) {
        md.egress_spec = port;
    }

    action set_host_egress(bit<9> port) {
        md.egress_spec = port;
        hdr.fp.setInvalid();
    }

    table fp_forward {
        key = {
            hdr.fp.to_segment : exact;
        }

        actions = {
            set_booster_egress;
            set_host_egress;
            do_drop;
        }

        default_action = do_drop;
    }

    apply {
        if (!hdr.eth.isValid()) {
            drop();
            return;
        }

        if (!hdr.fp.isValid()) {
            hdr.fp.setValid();
            hdr.fp.src = hdr.eth.src;
            hdr.fp.dst = hdr.eth.dst;
            hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
            hdr.fp.from_segment = 0;
        }

        advance_fp_hdr.apply();
        fp_forward.apply();
    }

}

Bmv2Switch(OffloadForwarder) main;
