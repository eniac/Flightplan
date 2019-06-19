#ifndef MAC_FEC_FORWARDING_P4_
#define MAC_FEC_FORWARDING_P4_

#include "targets.h"
#include "Parsing.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"

#struct bmv2_meta_t {}

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control MAC_FEC_Forwarder(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
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

    table fec_forward {
        key = {
           next_dataplane : exact;
           # meta.ingress_port: exact;
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

#    bit<FEC_K_WIDTH> k = 0;
#    bit<FEC_H_WIDTH> h = 0;
#    bit<24> proto_and_port = 0;
#    FEC_Classify() classification;
#    FecClassParams() decoder_params;
#    FecClassParams() encoder_params;

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        if (!hdr.fp.isValid()){
            hdr.fp.setValid();
            hdr.fp.src = hdr.eth.src;
            hdr.fp.dst = hdr.eth.dst;
            hdr.fp.type = ETHERTYPE_FLIGHTPLAN;

            hdr.fp.from_segment = 1;
            hdr.fp.to_segment = 2;
        }

        if(hdr.fp.isValid()){
           if(hdr.fp.to_segment == 5)
              hdr.fp.setInvalid();
              dst_mac = hdr.eth.dst;
              MAC_forward.apply(); 
        }
        else {
                next_dataplane = hdr.fp.to_segment;
                fec_forward.apply();
        }
      
      return;

    } 

}

#control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

#control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

#control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }

V1Switch(BMParser(), NoVerify(), MAC_FEC_Forwarder(), NoEgress(), NoCheck(), FecDeparser()) main;

#endif // MAC_FEC_FORWARDING_P4_
