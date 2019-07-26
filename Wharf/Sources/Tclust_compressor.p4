#include "Bmv2Definitions.p4"
#include "HC_extern.p4"

control Compress(inout headers_t hdr,
                 inout booster_metadata_t bmd,
                 inout metadata_t md) {
    apply {
        bit<1> forward;
        header_compress(forward);
        if (forward == 0) {
            drop();
            return;
        } else {
            md.egress_spec = md.ingress_port;
        }
    }
}

Bmv2Switch(Compress) main;
