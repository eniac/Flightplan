#include "targets.h"
#include "FEC.p4"

#if defined(TARGET_BMV2)

struct bmv2_meta_t {}

parser BMParser(packet_in pkt, out headers_t hdr,
                inout bmv2_meta_t m, inout metadata_t meta) { 
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }

control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }

control ProcessEncode(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) {
    apply {
        print_headers();
        FecEncode.apply(hdr, meta);
    }
}

V1Switch(BMParser(), NoVerify(), ProcessEncode(), NoEgress(), NoCheck(), FecDeparser()) main;

#elif defined(TARGET_XILINX)

#endif
