#include "FEC.p4"

struct booster_metadata_t {}

parser BMParser(packet_in pkt,
                    out headers_t hdr,
                    inout booster_metadata_t meta,
                    inout standard_metadata_t smd) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control NoVerify(inout headers_t hdr,
                 inout booster_metadata_t meta) {
    apply {}
}

control NoEgress(inout headers_t hdr,
                 inout booster_metadata_t meta,
                 inout standard_metadata_t smd) {
    apply {}
}

control NoCheck(inout headers_t hdr,
                inout booster_metadata_t meta) {
    apply {}
}

