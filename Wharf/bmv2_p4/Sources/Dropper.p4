#include "targets.h"
#include "FEC.p4"
#include "Parsing.p4"
#include "Forwarding.p4"
struct bmv2_meta_t {}

parser BMParser(packet_in pkt, out headers_t hdr,
                inout bmv2_meta_t m, inout metadata_t meta) { 
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control DropProcess(inout headers_t hdr, inout bmv2_meta_t meta, inout metadata_t smd) {
    bit<FEC_K_WIDTH> k;
    bit<FEC_H_WIDTH> h;

    apply {
        Forwarder.apply(smd);
        if (hdr.fec.isValid()) {

            FecClassParams.apply(hdr.fec.traffic_class, k, h);
            if (hdr.fec.packet_index == k - 1){
                mark_to_drop();
                return;
            }
        }
    }
}

control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }


V1Switch(BMParser(), NoVerify(), DropProcess(), NoEgress(), NoCheck(), FecDeparser()) main;

