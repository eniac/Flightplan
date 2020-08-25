/*
Example P4 program split, using Flightplan runtime support.
Nik Sultana, UPenn, February 2020

NOTE:
* Based on Sources/ALV.p4

*/

#include "targets.h"
#include "EmptyBMDefinitions.p4"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"

#define WIDTH_PORT_NUMBER 9

parser CompleteParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

#include "FPRuntime.p4"

control Process(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
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

    #include "FPProcessState.p4"

    apply {
      if (!hdr.fp.isValid()) {
        drop(); // We're not expecting other traffic
      } else {
        #include "FPCheckFeedback.p4"
        deserialise_metadata(hdr, meta);

        if (2 == hdr.fp.to_segment) {
          // Continue code
          if (hdr.ipv4.isValid() &&
                hdr.ipv4.ttl > 1 &&
                ipv4_forwarding.apply().hit) {

              if (next_hop_arp_lookup.apply().hit) {
                set_computation_order(hdr, computation_continuing, 2, 3);
              } else {
                drop();
              }
          }
        } else {
          hdr.fp.state = hdr.fp.state | InvalidCodeFlow;
        }
      }

      #include "FPPostComputation.p4"
    }
}

control ProcessEgress(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
  apply {
    #include "FPRuntimeEgress.p4"
  }
}

//V1Switch(CompleteParser(), NoVerify(), Process(), NoEgress(), ComputeCheck(), FecDeparser()) main;
V1Switch(CompleteParser(), NoVerify(), Process(), ProcessEgress()/*NoEgress()*/, ComputeCheck(), FecDeparser()) main;
