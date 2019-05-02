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

control Offload(in bit<9> port, out bit<1> is_from_offload) {

    action is_offload_port(bit<1> on) {
        is_from_offload = on;
    }

    table offloaded_port {
        key = {
            port : exact;
        }
        actions = { is_offload_port; }
        default_action = is_offload_port(0);
    }

    apply {
        offloaded_port.apply();
    }
}
