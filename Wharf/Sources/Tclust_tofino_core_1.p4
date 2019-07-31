#include "Bmv2Definitions.p4"

#define SEG_DECODE 0x2      // 2
#define SEG_DECOMPRESS 0x4 // 4
#define SEG_KV_STORE 0x6   // 6
#define SEG_COMPRESS 0x8
#define SEG_ENCODE 0xa
#define SEG_FORWARD 0xc

control BoostedLink(in bit<9> port, out bit<1> enabled) {
    action set_enabled(bit<1> on) {
        enabled = on;
    }

    table boost {
        key = {
            port : exact;
        }
        actions = { set_enabled; }
        default_action = set_enabled(0);
    }

    apply {
        boost.apply();
    }
}

control OffloadForwarder(inout headers_t hdr,
                         inout booster_metadata_t bmd,
                         inout metadata_t md) {

    BoostedLink() egress_compression;
    BoostedLink() egress_encoding;

    bit<1> faulty_egress;
    bit<1> compressed_egress;
    bit<1> compressed_ingress;
    bit<SEGMENT_DESC_SIZE> next_segment = 0;

    action set_egress(bit<9> port) {
        md.egress_spec = port;
    }

    table mac_forwarding {
        key = {
            hdr.eth.dst : exact;
        }

        actions = {
            set_egress;
            NoAction;
        }
    }

    action strip_fp_hdr() {
        hdr.fp.setInvalid();
    }

    action do_drop() {
        drop();
    }

    table offload {
        key = {
            next_segment : exact;
        }

        actions = {
            set_egress;
            strip_fp_hdr;
            do_drop;
        }

        default_action = do_drop();
    }

    bit<1> segment_set = 0;

    action forward_to_host() {
        next_segment = SEG_FORWARD;
        segment_set = 1;
    }

    action fec_encode() {
        if (faulty_egress == 1) {
            next_segment = SEG_ENCODE;
            segment_set = 1;
        }
        hdr.fp.to_segment = SEG_FORWARD;
    }


    action hc_compress() {
        if (compressed_egress == 1) {
            next_segment = SEG_COMPRESS;
            segment_set = 1;
        }
        hdr.fp.to_segment = SEG_ENCODE - 1;
    }

    action kv_store() {
        if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
            next_segment = SEG_KV_STORE;
            segment_set = 1;
        }
        hdr.fp.to_segment = SEG_COMPRESS - 1;
    }

    action forwarding_logic() {
        if (hdr.fp.from_segment <= SEG_KV_STORE) {
            kv_store();
            if (segment_set == 1) {
                return;
            }
        }
        if (hdr.fp.from_segment <= SEG_COMPRESS) {
            hc_compress();
            if (segment_set == 1) {
                return;
            }
        }
        if (hdr.fp.from_segment <= SEG_ENCODE) {
            fec_encode();
            if (segment_set == 1) {
                return;
            }
        }
        forward_to_host();
    }

    table segment_match {
        key = {
            hdr.fp.to_segment : exact;
        }

        actions = {
            hc_compress;
            kv_store;
            fec_encode;
            forward_to_host;
            forwarding_logic;
        }

        const entries = {
            ( SEG_KV_STORE ) : kv_store();
            ( SEG_COMPRESS ) : hc_compress();
            ( SEG_ENCODE )   : fec_encode();
            ( SEG_FORWARD )  : forward_to_host();
        }

        default_action = forwarding_logic();
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
        hdr.fp.from_segment = hdr.fp.to_segment;

        mac_forwarding.apply();
        egress_compression.apply(md.egress_spec, compressed_egress);
        egress_encoding.apply(md.egress_spec, faulty_egress);
        segment_match.apply();
        offload.apply();
    }

}

Bmv2Switch(OffloadForwarder) main;
