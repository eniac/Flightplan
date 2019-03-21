#include "targets.h"
#include "HC_extern.p4"

control HeaderCompression(in bit<9> ingress_port, inout bit<1> compressed) {

    action set_compression(bit<1> on) {
        compressed = on;
    }

    table ingress_compression {
        key = {
            ingress_port : exact;
        }
        actions = { set_compression; NoAction; }
        default_action = NoAction;
    }

    apply {
        ingress_compression.apply();
    }
}

