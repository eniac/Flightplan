/*
Split of ALV_qos.p4
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

#include "FPRuntimeHL3.p4"

// NOTE based on MyIngress implementation in qos.p4 from https://github.com/p4lang/tutorials/ at d964079ef8381316d32a19307509dd4a97edd070
const bit<8> IP_PROTOCOLS_TCP        =   6;
const bit<8> IP_PROTOCOLS_UDP        =  17;
control qos(inout headers_t hdr,
                  inout booster_metadata_t user_metadata,
                  inout metadata_t meta) {

    /* Default Forwarding */
    action default_forwarding() {
        hdr.ipv4.diffserv = 0;
    }

    /* Expedited Forwarding */
    action expedited_forwarding() {
        hdr.ipv4.diffserv = 46;
    }

    /* Voice Admit */
    action voice_admit() {
        hdr.ipv4.diffserv = 44;
    }

    /* Assured Forwarding */
    /* Class 1 Low drop probability */
    action af_11() {
        hdr.ipv4.diffserv = 10;
    }

    /* Class 1 Med drop probability */
    action af_12() {
        hdr.ipv4.diffserv = 12;
    }

    /* Class 1 High drop probability */
    action af_13() {
        hdr.ipv4.diffserv = 14;
    }

    /* Class 2 Low drop probability */
    action af_21() {
        hdr.ipv4.diffserv = 18;
    }

    /* Class 2 Med drop probability */
    action af_22() {
        hdr.ipv4.diffserv = 20;
    }

    /* Class 2 High drop probability */
    action af_23() {
        hdr.ipv4.diffserv = 22;
    }

    /* Class 3 Low drop probability */
    action af_31() {
        hdr.ipv4.diffserv = 26;
    }

    /* Class 3 Med drop probability */
    action af_32() {
        hdr.ipv4.diffserv = 28;
    }

    /* Class 3 High drop probability */
    action af_33() {
        hdr.ipv4.diffserv = 30;
    }

    /* Class 4 Low drop probability */
    action af_41() {
        hdr.ipv4.diffserv = 34;
    }

    /* Class 4 Med drop probability */
    action af_42() {
        hdr.ipv4.diffserv = 36;
    }

    /* Class 4 High drop probability */
    action af_43() {
        hdr.ipv4.diffserv = 38;
    }

    apply {
        if (hdr.ipv4.proto == IP_PROTOCOLS_UDP) {
            expedited_forwarding();
	}
        else if (hdr.ipv4.proto == IP_PROTOCOLS_TCP) {
	    voice_admit();
        }
    }
}

control ALV_qos(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

    #include "FPProcessStateHL3new.p4"

    apply {
      assert(offload_port_lookup.apply().hit);
      bool did_something = false;

      if (2 == fp_to_segment - 1) { did_something = true;
        if (hdr.ipv4.isValid()) {
          qos.apply(hdr, m, meta);
        }
      }
      assert(did_something);
    }
}

V1Switch(CompleteParser(), NoVerify(), ALV_qos(), NoEgress(), ComputeCheck(), FecDeparser()) main;
