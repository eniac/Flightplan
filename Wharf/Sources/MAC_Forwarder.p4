#ifndef MAC_FORWARDING_P4_
#define MAC_FORWARDING_P4_

#include "targets.h"
#include "Parsing.p4"

struct bmv2_meta_t {}

parser BMParser(packet_in pkt, out headers_t hdr,
                inout bmv2_meta_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control MAC_Forwarder(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) {
    bit<4> next_dataplane = 0;
    bit<48> dst_mac = 0;

    action set_MAC_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }
    
    action set_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }
    
    action do_drop() {
        drop();
    }

    table forward {
        key = {
            meta.ingress_port: exact;
       }
       actions = {set_egress; do_drop; }
       default_action = do_drop;
    }
    
    table MAC_forward {
        key = {
            dst_mac : exact;
        }
        actions = { set_MAC_egress; NoAction; }
        default_action = NoAction;
    }

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        else {
                dst_mac = hdr.eth.dst;
                MAC_forward.apply();
        }
      
      return;

    } 

}

control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }

V1Switch(BMParser(), NoVerify(), MAC_Forwarder(), NoEgress(), NoCheck(), FecDeparser()) main;

#endif // MAC_FORWARDING_P4_
