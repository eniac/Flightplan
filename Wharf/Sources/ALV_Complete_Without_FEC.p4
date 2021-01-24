/*
Fusion of ALV.p4 and Complete.p4
Nik Sultana, UPenn, March 2020
*/

/*
Modified to disable FEC (comment the define line) - KIM.
*/

#ifdef FP_ANNOTATE
#include "Flightplan.p4"
extern Landing Point_Alpha();
extern Landing Point_Bravo();
#endif // FP_ANNOTATE

#if !defined(TARGET_BMV2)
#error Currently unsupported target
#endif

#include "targets.h"
#include "EmptyBMDefinitions.p4"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"
#include "Compression.p4"

#define WIDTH_PORT_NUMBER 9

control ALV_Route(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    action mac_forward_set_egress(bit<WIDTH_PORT_NUMBER> port) {
        meta.egress_spec = port;
    }

    table mac_forwarding {
        key = {
            hdr.eth.dst : exact;
        }
        actions = {
            mac_forward_set_egress;
            NoAction;
        }
    }

    bit<32> dst_gateway_ipv4 = 0;

    action ipv4_forward(bit<32> next_hop, bit<WIDTH_PORT_NUMBER> port) {
        meta.egress_spec = port;
        dst_gateway_ipv4 = next_hop;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_forwarding {
        key = {
            hdr.ipv4.dst : ternary;
        }
        actions = {
            ipv4_forward;
            NoAction;
        }
    }

    action arp_lookup_set_addresses(bit<48> mac_address) {
        hdr.eth.src = hdr.eth.dst;
        hdr.eth.dst = mac_address;
    }

    table next_hop_arp_lookup {
        key = {
            dst_gateway_ipv4 : exact;
        }
        actions = {
            arp_lookup_set_addresses;
            NoAction;
        }
    }

    apply {
#if 0
        if (hdr.eth.isValid()) {
            if (mac_forwarding.apply().hit) return;
            if (hdr.ipv4.isValid() &&
                  hdr.ipv4.ttl > 1 &&
                  ipv4_forwarding.apply().hit) {
                if (next_hop_arp_lookup.apply().hit) return;
            }
        }
        drop();
#endif // 0

        bit<1> processed = 0;
        if (hdr.eth.isValid()) {
            if (mac_forwarding.apply().hit) {
                processed = 1;
            } else if (hdr.ipv4.isValid() &&
                  hdr.ipv4.ttl > 1 &&
                  ipv4_forwarding.apply().hit) {
                if (next_hop_arp_lookup.apply().hit) {
                    processed = 1;
                }
            }
        }
        if (0 == processed) {
            drop();
            exit;
        }
    }
}


parser CompleteParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

//#define FEC_BOOSTER
#define COMPRESSION_BOOSTER
#define MEMCACHED_BOOSTER

control Crosspod(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

    bit<1> run_program_ingress = 0;
    bit<1> run_program_egress = 0;

    action run_Complete_ingress() {
      run_program_ingress = 1;
    }

    table check_run_Complete_ingress {
        key = {
            meta.ingress_port : exact;
        }
        actions = {
            run_Complete_ingress;
            NoAction;
        }
    }

    action run_Complete_egress() {
      run_program_egress = 1;
    }

    table check_run_Complete_egress {
        key = {
            meta.egress_spec : exact;
        }
        actions = {
            run_Complete_egress;
            NoAction;
        }
    }

#if defined(FEC_BOOSTER)
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;
    bit<24> proto_and_port = 0;
    FEC_Classify() classification;
    FecClassParams() decoder_params;
    FecClassParams() encoder_params;
#endif

#if defined(COMPRESSION_BOOSTER)
    CompressedLink() ingress_compression;
    CompressedLink() egress_compression;
#endif

    apply {
        bit<1> compressed_link = 0;
        bit<1> forward = 0;

        check_run_Complete_ingress.apply();

#ifdef FP_ANNOTATE
        flyto(Point_Alpha());
#endif // FP_ANNOTATE

        if (1 == run_program_ingress) {
#if defined(FEC_BOOSTER)
            // If we received an FEC update, then update the table.
            bit<1> is_ctrl;
            FECController.apply(hdr, meta, is_ctrl);
            if (is_ctrl == 1) {
                drop();
                exit;
            }
#endif

#if defined(FEC_BOOSTER)
            // If lossy link, then FEC decode.
            if (hdr.fec.isValid()) {
                decoder_params.apply(hdr.fec.traffic_class, k, h);
                hdr.eth.type = hdr.fec.orig_ethertype;
                FEC_DECODE(hdr.fec, k, h);
                if (hdr.fec.isValid() && hdr.fec.packet_index >= k) {
                    drop();
                    exit;
                }
                hdr.fec.setInvalid();
            }
#endif

#if defined(COMPRESSION_BOOSTER)
            // If multiplexed link, then header decompress.
            ingress_compression.apply(meta.ingress_port, compressed_link);
            if (compressed_link == 1) {
                header_decompress(forward);
                if (forward == 0) {
                    drop();
                    exit;
                }
            }
#endif

// NOTE could move this to the later part of the program.
#if defined(MEMCACHED_BOOSTER)
            // If Memcached REQ/RES then pass through the cache.
            if (hdr.udp.isValid()) {
                if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
                    memcached(forward);
                    if (forward == 0) {
                        drop();
                        exit;
                    }
                }
            }
#endif
        }

#ifdef FP_ANNOTATE
        flyto(FlightStart());
#endif // FP_ANNOTATE

        // NOTE could do the routing step at very beginning, to get clarity on what follows.
        ALV_Route.apply(hdr, m, meta);

        check_run_Complete_egress.apply();

#ifdef FP_ANNOTATE
        flyto(Point_Bravo());
#endif // FP_ANNOTATE

        if (1 == run_program_egress) {
#if defined(COMPRESSION_BOOSTER)
            compressed_link = 0;
            forward = 0;
            // If heading out on a multiplexed link, then header compress.
            egress_compression.apply(meta.egress_spec, compressed_link);
            if (compressed_link == 1) {
                header_compress(forward);
                if (forward == 0) {
                    drop();
                    exit;
                }
            }
#endif

#if defined(FEC_BOOSTER)
            bit<1> faulty = 0;

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
#endif
        }

#ifdef FP_ANNOTATE
        flyto(FlightStart());
#endif // FP_ANNOTATE
    }
}

V1Switch(CompleteParser(), NoVerify(), Crosspod(), NoEgress(), ComputeCheck(), FecDeparser()) main;
