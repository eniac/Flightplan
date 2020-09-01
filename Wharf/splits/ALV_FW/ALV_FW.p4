/*
Split of ALV_Complete.p4
Nik Sultana, UPenn, March 2020
*/

#if !defined(TARGET_BMV2)
#error Currently unsupported target
#endif

#ifdef FP_ANNOTATE
#include "Flightplan.p4"
extern Landing Point_Alpha();
#endif // FP_ANNOTATE

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

// NOTE based on MyIngress implementation in https://github.com/p4lang/tutorials/blob/76a9067deaf35cd399ed965aa19997776f72ec55/exercises/firewall/solution/firewall.p4#L189
#define BLOOM_FILTER_ENTRIES 4096
#define BLOOM_FILTER_BIT_WIDTH 1
typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;
control FW(inout headers_t hdr,
                  inout booster_metadata_t user_metadata,
                  inout metadata_t meta) {

    register<bit<BLOOM_FILTER_BIT_WIDTH>>(BLOOM_FILTER_ENTRIES) bloom_filter_1;
    register<bit<BLOOM_FILTER_BIT_WIDTH>>(BLOOM_FILTER_ENTRIES) bloom_filter_2;
    bit<32> reg_pos_one; bit<32> reg_pos_two;
    bit<1> reg_val_one; bit<1> reg_val_two;
    bit<1> direction;

    action compute_hashes(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
       //Get register position
       hash(reg_pos_one, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1,
                                                           ipAddr2,
                                                           port1,
                                                           port2,
                                                           hdr.ipv4.proto},
                                                           (bit<32>)BLOOM_FILTER_ENTRIES);

       hash(reg_pos_two, HashAlgorithm.crc32, (bit<32>)0, {ipAddr1,
                                                           ipAddr2,
                                                           port1,
                                                           port2,
                                                           hdr.ipv4.proto},
                                                           (bit<32>)BLOOM_FILTER_ENTRIES);
    }

    action set_direction(bit<1> dir) {
        direction = dir;
    }

    table check_ports {
        key = {
            meta.ingress_port: exact;
            meta.egress_spec: exact;
        }
        actions = {
            set_direction;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    apply {
       direction = 0; // default
       if (check_ports.apply().hit) {
           // test and set the bloom filter
           if (direction == 0) {
               compute_hashes(hdr.ipv4.src, hdr.ipv4.dst, hdr.tcp.sport, hdr.tcp.dport);
           }
           else {
               compute_hashes(hdr.ipv4.dst, hdr.ipv4.src, hdr.tcp.dport, hdr.tcp.sport);
           }
           // Packet comes from internal network
           if (direction == 0){
               // If there is a syn we update the bloom filter and add the entry
               bit<1> syn = (bit<1>)((hdr.tcp.flags & 0b10) >> 1);
               if (syn == 1){
                   bloom_filter_1.write(reg_pos_one, 1);
                   bloom_filter_2.write(reg_pos_two, 1);
               }
           }
           // Packet comes from outside
           else if (direction == 1){
               // Read bloom filter cells to check if there are 1's
               bloom_filter_1.read(reg_val_one, reg_pos_one);
               bloom_filter_2.read(reg_val_two, reg_pos_two);
               // only allow flow to pass if both entries are set
               if (reg_val_one != 1 || reg_val_two != 1){
                   drop();
               }
           }
       }
    }
}

control ALV_FW(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    apply {
      if (hdr.ipv4.isValid()) {
        ALV_Route.apply(hdr, m, meta);
#ifdef FP_ANNOTATE
        flyto(Point_Alpha());
#endif // FP_ANNOTATE
        if (hdr.tcp.isValid()){
          FW.apply(hdr, m, meta);
        }
#ifdef FP_ANNOTATE
        flyto(FlightStart());
#endif // FP_ANNOTATE
      }
    }
}

V1Switch(CompleteParser(), NoVerify(), ALV_FW(), NoEgress(), ComputeCheck(), FecDeparser()) main;
