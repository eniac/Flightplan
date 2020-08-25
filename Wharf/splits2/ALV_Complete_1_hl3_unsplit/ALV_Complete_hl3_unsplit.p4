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

#if 0
    ALV_Route() route;
    apply {
      if (!hdr.fp.isValid()) {
        // FIXME one of 2 entry points?
        check_run_Complete_ingress.apply();
        if (1 == run_program_ingress) {
          init_computation(hdr);
          set_computation_order(hdr, 1, 2);
        }
        // FIXME should hand-over at this point

        route.apply(hdr, m, meta);

        check_run_Complete_egress.apply();
        if (1 == run_program_egress) {
          init_computation(hdr);
          set_computation_order(hdr, 3, 4);
        }

        if (FALSE == computation_continuing) {
          end_computation(hdr);
        }
      } else {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);

        if (3 == hdr.fp.to_segment) {
          route.apply(hdr, m, meta);

          check_run_Complete_egress_COPY.apply();
          if (1 == run_program_egress) {
            set_computation_order(hdr, 3, 4);
          }

          if (FALSE == computation_continuing) {
            end_computation(hdr);
          }
        } else if (5 == hdr.fp.to_segment) {
          end_computation(hdr);
        } else {
          assert(FALSE == computation_continuing);
          hdr.fp.state = hdr.fp.state | InvalidCodeFlow;
        }
      }

      #include "FPPostComputation.p4"
    }
#elif 0
    apply {
      if (!hdr.fp.isValid()) {
        check_run_Complete_ingress.apply();
        if (1 == run_program_ingress) {
          init_computation(hdr);
          set_computation_order(hdr, computation_continuing, 1, 2);
        }
      }

      if (hdr.fp.isValid() &&
          2 != hdr.fp.to_segment &&
          4 != hdr.fp.to_segment) {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);

        if (3 == hdr.fp.to_segment) {
          // Moved this outside
        } else if (5 == hdr.fp.to_segment) {
          end_computation(hdr, computation_continuing, computation_ended);
        } else {
          assert(FALSE == computation_continuing);
          hdr.fp.state = hdr.fp.state | InvalidCodeFlow;
        }
      }

      if (!hdr.fp.isValid() ||
          3 == hdr.fp.to_segment) {
        ALV_Route.apply(hdr, m, meta);
      }

      if (FALSE == computation_ended) {
        check_run_Complete_egress.apply();
        if (1 == run_program_egress &&
            (!hdr.fp.isValid() ||
             3 == hdr.fp.to_segment)) {
          init_computation(hdr);
          set_computation_order(hdr, computation_continuing, 3, 4);
        } else if (hdr.fp.isValid() &&
             3 == hdr.fp.to_segment) {
            end_computation(hdr, computation_continuing, computation_ended);
        }
      }

      #include "FPPostComputation.p4"
    }
#elif 0
    apply {
      computation_incoming = hdr.fp.isValid() ? 1w1 : 1w0;
      if (TRUE == computation_incoming &&
          FALSE == computation_continuing &&
          FALSE == computation_ended) {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);
      }

      if (FALSE == computation_incoming) {
        check_run_Complete_ingress.apply();
        if (1 == run_program_ingress) {
          init_computation(hdr);
          set_computation_order(hdr, computation_continuing, 1, 2);
        }
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           (2 == hdr.fp.from_segment &&
            3 == hdr.fp.to_segment))) {
        ALV_Route.apply(hdr, m, meta);

        check_run_Complete_egress.apply();
        if (1 == run_program_egress) {
          init_computation(hdr);
          set_computation_order(hdr, computation_continuing, 3, 4);
        }
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           (4 == hdr.fp.from_segment &&
            5 == hdr.fp.to_segment))) {
        end_computation(hdr, computation_continuing, computation_ended);
      }

      if (TRUE == computation_incoming &&
          FALSE == computation_continuing &&
          FALSE == computation_ended) {
        hdr.fp.state = hdr.fp.state | InvalidCodeFlow;
        end_computation(hdr, computation_continuing, computation_ended);
      }

      #include "FPPostComputation.p4"
    }
#else
    apply {
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

#if !defined(END_FORWARDING_DECISION)
      // Default point at which forwarding decision is made
      ALV_Route.apply(hdr, m, meta);
#endif // !defined(END_FORWARDING_DECISION)

#if defined(COMPRESSION_BOOSTER)
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

#if defined(END_FORWARDING_DECISION)
      ALV_Route.apply(hdr, m, meta);
#endif // defined(END_FORWARDING_DECISION)
    }
#endif
}

V1Switch(CompleteParser(), NoVerify(), Crosspod(), NoEgress(), ComputeCheck(), FecDeparser()) main;
