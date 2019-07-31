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

control BoostedProtocol(in bit<8> proto, in bit<16> sport, in bit<16> dport, out bit<1> enabled) {

    action set_enabled(bit<1> on) {
        enabled = on;
    }

    table boost {
        key = {
            proto : ternary;
            sport : ternary;
            dport : ternary;
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

    BoostedLink() ingress_compression;
    BoostedLink() egress_compression;
    BoostedLink() egress_encoding;
    BoostedProtocol() kv_booster;

    bit<1> faulty_egress;
    bit<1> compressed_egress;
    bit<1> compressed_ingress;
    bit<1> kv_booster_enabled;
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
        if (kv_booster_enabled == 1) {
            next_segment = SEG_KV_STORE;
            segment_set = 1;
        }
        hdr.fp.to_segment = SEG_COMPRESS - 1;
    }

    action hc_decompress() {
        if (hdr.fp.to_segment == SEG_DECOMPRESS) {
            next_segment = SEG_DECOMPRESS;
            segment_set = 1;
        }
        hdr.fp.to_segment = SEG_KV_STORE - 1;
    }

    action fec_decode() {
        if (hdr.fec.isValid()) {
            next_segment = SEG_DECODE;
            segment_set = 1;
        }

        if (compressed_ingress == 1) {
            hdr.fp.to_segment = SEG_DECOMPRESS;
        } else {
            // Skip compression later
            hdr.fp.to_segment = SEG_DECOMPRESS + 1;
        }
    }

    action forwarding_logic() {
        if (hdr.fp.from_segment <= SEG_DECODE) {
            fec_decode();
            if (segment_set == 1) {
                return;
            }
        }
        if (hdr.fp.from_segment <= SEG_DECOMPRESS) {
            hc_decompress();
            if (segment_set == 1) {
                return;
            }
        }
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
            fec_decode;
            hc_compress;
            kv_store;
            hc_decompress;
            fec_encode;
            forward_to_host;
            forwarding_logic;
        }

        const entries = {
            ( SEG_DECODE )   : fec_decode();
            ( SEG_DECOMPRESS ) : hc_decompress();
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
        ingress_compression.apply(md.ingress_port, compressed_ingress);
        egress_compression.apply(md.egress_spec, compressed_egress);
        egress_encoding.apply(md.egress_spec, faulty_egress);
        bit<16> sport = 0;
        bit<16> dport = 0;
        if (hdr.tcp.isValid()) {
            sport = hdr.tcp.sport;
            dport = hdr.tcp.dport;
        } else if (hdr.udp.isValid()) {
            sport = hdr.udp.sport;
            dport = hdr.udp.dport;
        }
        kv_booster.apply(hdr.ipv4.proto, sport, dport, kv_booster_enabled);
        segment_match.apply();
        offload.apply();
    }

}

Bmv2Switch(OffloadForwarder) main;
