#include "Bmv2Definitions.p4"

extern void memcached_fp(out bit<1> forward, in flightplan_h fp);

control KVStore(inout headers_t hdr,
                 inout booster_metadata_t bmd,
                 inout metadata_t md) {
    apply {
        bit<1> forward;
        memcached_fp(forward, hdr.fp);
        if (forward == 0) {
            drop();
            return;
        } else {
            md.egress_spec = md.ingress_port;
        }
    }
}

Bmv2Switch(KVStore) main;
