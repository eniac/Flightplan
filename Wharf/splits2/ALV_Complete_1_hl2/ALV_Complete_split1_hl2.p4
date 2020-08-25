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

#include "FPRuntimeHL2.p4"

#define FEC_BOOSTER
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
    #include "FPProcessStateHL2.p4"
    // NOTE assuming this block to be extern-free
    apply {
//      #include "FPEntryProcessingHP.p4"
      if (!hdr.ipv4.isValid()) {
        drop();
        return;
      }
      if (5 != meta.ingress_port) { // FIXME hack, expecting frag to be 0
        hdr.ipv4.frag = 0;
      }

      bool is_active = false;
      computation_incoming = FALSE;
      fp_get_Active(hdr, is_active);
      if (is_active) {
        computation_incoming = TRUE;
      }
      fp_get_ToSegment(hdr, fp_to_segment);

      if (FALSE == computation_incoming) {
        check_run_Complete_ingress.apply();
        if (1 == run_program_ingress) {
          init_computation(hdr);
          set_computation_order(hdr, computation_continuing, 2, fp_to_segment, meta);
        }
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           3 == fp_to_segment ||
           5 == fp_to_segment/*Needed at final state*/)) {
        ALV_Route.apply(hdr, m, meta);
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           3 == fp_to_segment)) {
        check_run_Complete_egress.apply();
        if (1 == run_program_egress) {
          init_computation(hdr);
          set_computation_order(hdr, computation_continuing, 4, fp_to_segment, meta);
        }
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           3 == fp_to_segment)) {
        end_computation(hdr, computation_continuing, computation_ended);
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           5 == fp_to_segment)) {
        end_computation(hdr, computation_continuing, computation_ended);
      }

      if (TRUE == computation_continuing &&
          FALSE == computation_ended) {
        offload_port_lookup.apply();
      }

      assert (!(TRUE == computation_incoming &&
          FALSE == computation_continuing &&
          FALSE == computation_ended));
//      #include "FPPostComputationHP.p4"
    }
#endif
}

V1Switch(CompleteParser(), NoVerify(), Crosspod(), NoEgress(), ComputeCheck(), FecDeparser()) main;
