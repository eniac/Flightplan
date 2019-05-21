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

  bit<SEGMENT_DESC_SIZE> next_dataplane = 0;

  action set_fp_egress(bit<9> port) {
      SET_EGRESS(meta, port);
  }

  table flightplan_forward {
    key = {
      next_dataplane : exact;
    }
    actions = { set_fp_egress; NoAction; }
    // FIXME map next_dataplane to egress
    default_action = NoAction/*FIXME report an error if we can't find where to forward to*/;
  }

#if defined(FEC_BOOSTER)
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;
    bit<24> proto_and_port = 0;
    FEC_Classify() classification;
    FecClassParams() decoder_params;
    FecClassParams() encoder_params;
#endif

#if defined(COMPRESSION_BOOSTER)
    CompressedLink() ingress_compression;
    CompressedLink() egress_compression;
#endif

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        if (hdr.fp.isValid()) {
            hdr.fp.to_segment = 1 + hdr.fp.to_segment;
            next_dataplane = hdr.fp.to_segment;
            flightplan_forward.apply();
            return;
        } else {
            drop();
            return;
        }

        //Forwarder.apply(meta);
        return;
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;

#else
#error Currently unsupported target
#endif

