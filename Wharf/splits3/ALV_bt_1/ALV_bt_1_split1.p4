/*
Adaptation of basic_tunnel.p4 to work on our ALV topology.
Nik Sultana, UPenn, August 2020
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

#include "FPRuntime.p4"

control ALV_bt(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    #include "FPProcessState.p4"

    apply {
      computation_incoming = hdr.fp.isValid() ? 1w1 : 1w0;
      if (TRUE == computation_incoming &&
          FALSE == computation_continuing &&
          FALSE == computation_ended) {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);
      }

      if (FALSE == computation_incoming) {
        if (hdr.ipv4.isValid() && !hdr.myTunnel.isValid()) {
            // Process only non-tunneled IPv4 packets
            ALV_Route.apply(hdr, m, meta);
        }
        init_computation(hdr);
        set_computation_order(hdr, computation_continuing, 1, 2);
      }

      if (FALSE == computation_continuing &&
          (FALSE == computation_incoming  ||
           (2 == hdr.fp.from_segment &&
            3 == hdr.fp.to_segment))) {
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
}

control ProcessEgress(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
  apply {
    #include "FPRuntimeEgress.p4"
  }
}

V1Switch(CompleteParser(), NoVerify(), ALV_bt(), NoEgress(), ComputeCheck(), FecDeparser()) main;
