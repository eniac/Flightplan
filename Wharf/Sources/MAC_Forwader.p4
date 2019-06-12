#ifndef MAC_FORWARDING_P4_
#define MAC_FORWARDING_P4_

#include "targets.h"

control MAC_Forwarder(inout metadata_t meta) {
    bit<48> dst_mac = 0;

    action set_MAC_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }

    action do_drop() {
        drop();
    }

    table MAC_forward {
        key = {
            dst_mac : exact;
        }
        actions = { set_MAC_egress; NoAction; }
        default_action = NoAction;
    }

    apply {
       # forward.apply();
        if (!hdr.eth.isValid()) {
            drop();
        }

       if (!hdr.fp.isValid()) {
             hdr.fp.setValid();
             hdr.fp.src = hdr.eth.src;
             hdr.fp.dst = hdr.eth.dst;
             hdr.fp.type = ETHERTYPE_FLIGHTPLAN;

             hdr.fp.from_segment = 1;
             hdr.fp.to_segment = 2;
       }

       if (hdr.fp.isValid()) {
          if(hdr.fp.to_segment == 5)
             hdr.fp.setInvalid();
          
          dst_mac = hdr.eth.dst;
          MAC_forward.apply();
       }

      return;

    }
}

#endif // MAC_FORWARDING_P4_
