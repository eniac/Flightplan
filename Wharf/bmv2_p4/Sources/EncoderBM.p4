#include "v1model.p4"
#include "FecBM.p4"

control ProcessEncode(inout headers_t hdr,
                      inout booster_metadata_t meta,
                      inout standard_metadata_t smd) {
    apply {
        FecEncode.apply(hdr, smd);
    }
}

V1Switch(BMParser(), 
         NoVerify(),
         ProcessEncode(),
         NoEgress(),
         NoCheck(),
         FecDeparser()) main;


