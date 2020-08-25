/*
Split of ALV_Complete.p4
Nik Sultana, UPenn, March 2020
*/

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
        if (hdr.eth.isValid()) {
            if (mac_forwarding.apply().hit) return;
            if (hdr.ipv4.isValid() &&
                  hdr.ipv4.ttl > 1 &&
                  ipv4_forwarding.apply().hit) {
                if (next_hop_arp_lookup.apply().hit) return;
            }
        }
        drop();
    }
}


parser CompleteParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

#include "FPRuntimeHL3.p4"

#define FEC_BOOSTER
#define COMPRESSION_BOOSTER
#define MEMCACHED_BOOSTER

control Crosspod(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

    bit<1> run_fec_egress = 0;

    action run_FEC_egress(bit<1> status) {
      run_fec_egress = status;
    }

    table check_run_FEC_egress {
        key = {
            hdr.ipv4.dst : exact;
        }
        actions = {
            run_FEC_egress;
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

    #include "FPProcessStateHL3new.p4"

    apply {
      assert(offload_port_lookup.apply().hit);
      bool did_something = false;

      if (2 == fp_to_segment - 1) { did_something = true;
          bit<1> compressed_link = 0;
          bit<1> forward = 0;

#if defined(FEC_BOOSTER)
          // If lossy link, then FEC decode.
          if (hdr.fec.isValid()) {
              decoder_params.apply(hdr.fec.traffic_class, k, h);
              hdr.eth.type = hdr.fec.orig_ethertype;
              FEC_DECODE(hdr.fec, k, h);
              if (hdr.fec.isValid() && hdr.fec.packet_index >= k) {
                  drop();
                  return;
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
                  return;
              }
          }
#endif

#if defined(MEMCACHED_BOOSTER)
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
#endif
      } else if (4 == fp_to_segment - 1) { did_something = true;
#if defined(COMPRESSION_BOOSTER)
          bit<1> compressed_link = 0;
          bit<1> forward = 0;
          // If heading out on a multiplexed link, then header compress.
          egress_compression.apply(meta.egress_spec, compressed_link);
          if (compressed_link == 1) {
              header_compress(forward);
              if (forward == 0) {
                  drop();
                  return;
              }
          }
#endif

#if defined(FEC_BOOSTER)
          // If heading out on a lossy link, then FEC encode.
          check_run_FEC_egress.apply();
          if (run_fec_egress == 1) {
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
      assert(did_something);
    }
}

V1Switch(CompleteParser(), NoVerify(), Crosspod(), NoEgress(), ComputeCheck(), FecDeparser()) main;
