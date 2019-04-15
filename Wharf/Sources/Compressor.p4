#include "targets.h"
#include "Compression.p4"
#include "EmptyBMDefinitions.p4"
#include "Forwarding.p4"

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control Process(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

    HeaderCompression() ingress_compression;
    HeaderCompression() egress_compression;

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        bit<1> forward = 1;
        bit<1> decompress = 0;

        ingress_compression.apply(meta.ingress_port, decompress);
        if (decompress == 1) {
            header_decompress(forward);
            if (forward == 0) {
                drop();
                return;
            }
        }

        Forwarder.apply(meta);

        bit<1> compress = 0;
        egress_compression.apply(meta.egress_spec, compress);
        if (compress == 1) {
            header_compress(forward);
            if (forward == 0) {
                drop();
                return;
            }
        }
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;
