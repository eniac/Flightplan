#include "targets.h"
#include "EmptyBMDefinitions.p4"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "FEC_Classify.p4"
#include "Compression.p4"

#if defined(TARGET_BMV2)

parser BMParser(packet_in pkt, out headers_t hdr,
                inout booster_metadata_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control Process(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) {

#if defined(COMPRESSION_BOOSTER)
    HeaderCompression() egress_compression;
#endif

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        bit<1> compressed_link = 0;
        bit<1> forward = 0;

#if defined(MID_FORWARDING_DECISION)
        Forwarder.apply(meta);
#endif

#if defined(COMPRESSION_BOOSTER)
        compressed_link = 0;
        // If heading out on a multiplexed link, then header compress.
        egress_compression.apply(meta.egress_spec, compressed_link);
        if (compressed_link == 1) {
            header_compress(forward);
            if (forward == 0) {
                drop();
                return;
            }
        }
#endif

#if !defined(MID_FORWARDING_DECISION)
        Forwarder.apply(meta);
#endif
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;

#else
#error Currently unsupported target
#endif
