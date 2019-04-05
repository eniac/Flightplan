#include "targets.h"
#include "EmptyBMDefinitions.p4"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"
#include "HC_extern.p4"

#if defined(TARGET_BMV2)

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control Process(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

    bit<24> proto_and_port = 0;
    FEC_Classify() classification;
    FecClassParams() decoder_params;
    FecClassParams() encoder_params;

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        // If we received an FEC update, then update the table.
        bit<1> is_ctrl;
        FECController.apply(hdr, meta, is_ctrl);
        if (is_ctrl == 1) {
            drop();
            return;
        }

        // If lossy link, then FEC decode.
        if (hdr.fec.isValid()) {
            decoder_params.apply(hdr.fec.traffic_class, k, h);
            hdr.eth.type = hdr.fec.orig_ethertype;
            FEC_DECODE(hdr.fec, k, h);
            if (hdr.fec.packet_index >= k) {
                drop();
                return;
            }
            hdr.fec.setInvalid();
        }

        bit<1> compressed_link = 0;
        bit<1> forward = 0;

#if defined(HEADER_COMPRESSION)
        // If multiplexed link, then header decompress.
        get_port_link_compression(meta.ingress_port, compressed_link);
        if (compressed_link == 1) {
        header_decompress(forward);
            if (forward == 0) {
                drop();
                return;
            }
        }
#endif

#if defined(MID_FORWARDING_DECISION)
        Forwarder.apply(meta);
#endif

        // If Memcached REQ/RES then pass through the cache.
        if (hdr.udp.isValid()) {
            if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
                memcached(forward);
                if (forward == 0) {
                    drop();
                    return;
                }
            }
        }

        bit<1> faulty = 1;

#if defined(HEADER_COMPRESSION)
        // If heading out on a multiplexed link, then header compress.
        get_port_link_compression(meta.egress_spec, compressed_link);
        if (compressed_link == 1) {
        header_compress(forward);
            if (forward == 0) {
                drop();
                return;
            }
        }
#endif

        // If heading out on a lossy link, then FEC encode.
        get_port_status(meta.egress_spec, faulty);
        if (faulty == 1) {
            if (hdr.tcp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.tcp.dport;
            } else if (hdr.udp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.udp.dport;
            } else {
                proto_and_port = hdr.ipv4.proto ++ (bit<16>)0;
            }

            classification.apply(hdr, proto_and_port);
            if (hdr.fec.isValid()) {
                encoder_params.apply(hdr.fec.traffic_class, k, h);
                update_fec_state(hdr.fec.traffic_class, k, h,
                                 hdr.fec.block_index, hdr.fec.packet_index);
                hdr.fec.orig_ethertype = hdr.eth.type;
                FEC_ENCODE(hdr.fec, k, h);
                hdr.eth.type = ETHERTYPE_WHARF;
            }
        }

#if !defined(MID_FORWARDING_DECISION)
        Forwarder.apply(meta);
#endif
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;

#else
#error Currently unsupported target
#endif