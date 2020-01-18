#include "Bmv2Definitions.p4"
#include "HC_extern.p4"

control NoOp(inout headers_t hdr,
             inout booster_metadata_t bmd,
             inout metadata_t md) {
    apply {
        md.egress_spec = md.ingress_port;
    }
}

Bmv2Switch(NoOp) main;
