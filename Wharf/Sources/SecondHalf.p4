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
#if defined(FEC_BOOSTER)
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;
    bit<24> proto_and_port = 0;
    FEC_Classify() classification;
    FecClassParams() decoder_params;
    FecClassParams() encoder_params;
#endif

#if defined(COMPRESSION_BOOSTER)
    HeaderCompression() ingress_compression;
    HeaderCompression() egress_compression;
#endif

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

#if defined (FEC_BOOSTER)
        // If we received an FEC update, then update the table.
        bit<1> is_ctrl;
        FECController.apply(hdr, meta, is_ctrl);
        if (is_ctrl == 1) {
            drop();
            return;
        }
#endif

        bit<1> compressed_link = 0;
        bit<1> forward = 0;

#if defined(FEC_BOOSTER)
        // If lossy link, then FEC decode.
        if (hdr.fec.isValid()) {
            decoder_params.apply(hdr.fec.traffic_class, k, h);
            hdr.eth.type = hdr.fec.orig_ethertype;
            FEC_DECODE(hdr.fec, k, h);
            if (hdr.fec.packet_index >= k) {
                drop();
                return;
            }
            hdr.fec.setInvalid();
        }
#endif

#if defined(COMPRESSION_BOOSTER)
        // If multiplexed link, then header decompress.
        ingress_compression.apply(meta.ingress_port, compressed_link);
        if (compressed_link == 1) {
            header_decompress(forward);
            if (forward == 0) {
                drop();
                return;
            }
        }
#endif

        Forwarder.apply(meta); // FIXME think whether this is best placed elsewhere
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;

#else
#error Currently unsupported target
#endif
