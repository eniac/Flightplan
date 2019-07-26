#ifndef MAC_ENC_FWD_P4_
#define MAC_ENC_FWD_P4_

#include "targets.h"
#include "EmptyBMDefinitions.p4"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control MAC_Forwarder(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {
    bit<4> next_dataplane = 0;
    bit<1> forward = 0;
    
    action set_fp_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }
   
    table flightplan_forward { 
        key = {
            next_dataplane : exact;
       }
       actions = {set_fp_egress; NoAction; }
       default_action = NoAction;
    }
    

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        if(hdr.fp.isValid()){
              hdr.fp.to_segment = 1 + hdr.fp.to_segment;
              next_dataplane = hdr.fp.to_segment;
              flightplan_forward.apply();
        }
        else {
           drop();
        }


#if defined(MEMCACHED_BOOSTER)
        // If Memcached REQ/RES then pass through the cache.
        if (hdr.udp.isValid()) {
            if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
                hdr.fp.setInvalid();
                memcached(forward);
                if (forward == 0) {
                    drop();
                    return;
                }
                 hdr.fp.setValid();
                 hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
                 hdr.fp.to_segment = 5;

            }
        }
#endif
   }
}


V1Switch(BMParser(), NoVerify(), MAC_Forwarder(), NoEgress(), NoCheck(), FecDeparser()) main;

#endif // MAC_ENC_FWD_P4_
