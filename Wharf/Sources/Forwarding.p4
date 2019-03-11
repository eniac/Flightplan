#ifndef FORWARDING_P4_
#define FORWARDING_P4_

#include "targets.h"


control Forwarder(inout metadata_t meta) {

    action set_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }

    action do_drop() {
        drop();
    }

    table forward {
        key = {
            meta.ingress_port : exact;
        }
        actions = { set_egress; do_drop; }
        default_action = do_drop;
    }

    apply {
        forward.apply();
    }
}

#endif // FORWARDING_P4_
