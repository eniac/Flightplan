#include "v1model.p4"
#include "FecBM.p4"

control DropProcess(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
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

V1Switch(BMParser(), NoVerify(), DropProcess(), NoEgress(), NoCheck(), FecDeparser()) main;

