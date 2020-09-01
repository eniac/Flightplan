/*
Accompanying P4 program for my implementation of Al-Fares, Loukissas and Vahdat's SIGCOMM 2008 paper.
Nik Sultana, UPenn, February 2020

NOTE:
* Relies on inclusions of definitions used in Complete.p4, a lot of which aren't
  necessary for this example to work, but are reused as they are for expedience.
*/

#ifdef FP_ANNOTATE
#include "Flightplan.p4"
extern Landing Point_Alpha();
#endif // FP_ANNOTATE

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

    apply {
        if (hdr.eth.isValid()) {
            if (mac_forwarding.apply().hit) return;
#ifdef FP_ANNOTATE

#if !defined(FP_SPLIT1) && !defined(FP_SPLIT2)
#error Must define FP_SPLIT1/FP_SPLIT2/FP_SPLIT3 in addition to FP_ANNOTATE
#endif // !defined(FP_SPLIT1) && !defined(FP_SPLIT2)

#if defined(FP_SPLIT1) && defined(FP_SPLIT2)
#error Must define only ONE of FP_SPLIT1/FP_SPLIT2/FP_SPLIT3
#endif // defined(FP_SPLIT1) && defined(FP_SPLIT2)

#ifdef FP_SPLIT1
            flyto(Point_Alpha());
#endif // FP_SPLIT1
#endif // FP_ANNOTATE
            if (hdr.ipv4.isValid() &&
                  hdr.ipv4.ttl > 1 &&
                  ipv4_forwarding.apply().hit) {
#ifdef FP_ANNOTATE
#ifdef FP_SPLIT2
                flyto(Point_Alpha());
#endif // FP_SPLIT2
#endif // FP_ANNOTATE
                if (next_hop_arp_lookup.apply().hit) {
#ifdef FP_ANNOTATE
                    flyto(FlightStart());
#endif // FP_ANNOTATE
                    return;
                }
            }
        }
        drop();
    }
}

V1Switch(CompleteParser(), NoVerify(), Process(), NoEgress(), ComputeCheck(), FecDeparser()) main;
