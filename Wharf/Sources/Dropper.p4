#include "targets.h"
#include "FEC.p4"
#include "Parsing.p4"
#include "Forwarding.p4"
struct bmv2_meta_t {}

extern void random_drop(in bit<16> before_drop, in bit<16> between_drops, in bit<9> egress);

parser BMParser(packet_in pkt, out headers_t hdr,
                inout bmv2_meta_t m, inout metadata_t meta) {
    state start {
        transition accept;
    }
}

control DropProcess(inout headers_t hdr, inout bmv2_meta_t meta, inout metadata_t smd) {
    action set_drop_rate(bit<16> before_drop, bit<16> between_drops) {
        random_drop(before_drop, between_drops, smd.egress_spec);
    }

    table dropper {
        key = {
            smd.egress_spec : exact;
        }
        actions = { set_drop_rate; NoAction; }
        default_action = NoAction;
    }

    apply {
        Forwarder.apply(smd);
        dropper.apply();
    }
}

control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }


V1Switch(BMParser(), NoVerify(), DropProcess(), NoEgress(), NoCheck(), FecDeparser()) main;

