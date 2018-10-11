#include "targets.h"
#include "Forwarding.p4"

struct bmv2_meta_t {}

parser BMParser(packet_in pkt, out headers_t hdr,
                inout bmv2_meta_t m, inout metadata_t meta) {
    state start {
        transition accept;
    }
}

control DropProcess(inout headers_t hdr, inout bmv2_meta_t meta, inout metadata_t smd) {
    apply {
        Forwarder.apply(smd);
    }
}

control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }


V1Switch(BMParser(), NoVerify(), DropProcess(), NoEgress(), NoCheck(), FecDeparser()) main;

