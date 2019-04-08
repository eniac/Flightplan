#include "targets.h"
#include "HC_extern.p4"

control HeaderCompression(in bit<9> port, inout bit<1> compressed) {

    action set_port_compression(bit<1> on) {
        compressed = on;
    }

    table port_compression {
        key = {
            port : exact;
        }
        actions = { set_port_compression; NoAction; }
        default_action = NoAction;
    }

    apply {
        port_compression.apply();
    }
}

