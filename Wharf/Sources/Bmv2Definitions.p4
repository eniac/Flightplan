#ifndef BMV2_DEFINITIONS
#define BMV2_DEFINITIONS

#include "v1model.p4"
#include "Parsing.p4"

struct booster_metadata_t {}

parser Bmv2Parser(packet_in pkt, out headers_t hdr,
                  inout booster_metadata_t bmd, inout metadata_t md) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}
control Bmv2Deparser(packet_out pkt, in headers_t hdr) {
    apply {
        FecDeparser.apply(pkt, hdr);
    }
}

control Bmv2Verify(inout headers_t hdr, inout booster_metadata_t m) { apply {} }
control Bmv2Check(inout headers_t hdr, inout booster_metadata_t m) { apply {} }
control Bmv2Egress(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) { apply {} }

#define Bmv2Switch(Ingress) \
    V1Switch(Bmv2Parser(), Bmv2Verify(), \
             Ingress(), \
             Bmv2Egress(), Bmv2Check(), Bmv2Deparser())

#define Bmv2Switch2(Ingress, Egress) \
     V1Switch(Bmv2Parser(), Bmv2Verify(), \
             Ingress(), Egress(), \
             Bmv2Check(), Bmv2Deparser())

#endif
