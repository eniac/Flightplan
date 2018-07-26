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

        const entries = {
            1 : set_egress(2);
            2 : set_egress(1);
        }
    }

    apply {
        forward.apply();
    }
}

#endif // FORWARDING_P4_
