#include "v1model.p4"
#include "FecBM.p4"

control ProcessDecode(inout headers_t hdr,
                      inout booster_metadata_t meta,
                      inout standard_metadata_t smd) {
    apply {
        FecDecode.apply(hdr, smd);
    }
}

V1Switch(BMParser(),
         NoVerify(),
         ProcessDecode(),
         NoEgress(),
         NoCheck(),
         FecDeparser()) main;

