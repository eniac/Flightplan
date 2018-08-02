#ifndef FORWARDING_P4_
#define FORWARDING_P4_

#include "targets.h"

control Forwarder(inout metadata_t meta) {

    action set_egress(bit<9> port) {
        SET_EGRESS(meta, port);
    }

    table forward {
        key = {
            meta.ingress_port : exact;
        }
        actions = { set_egress; NoAction; }
        default_action = NoAction;
    }

    apply {
        forward.apply();
    }
}

#endif // FORWARDING_P4_
