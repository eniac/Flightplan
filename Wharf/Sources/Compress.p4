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

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        bit<1> forward = 0;

        Forwarder.apply(meta);

        header_compress(forward);
/* NOTE the check for forward==0 is done because the extern creates a new
  packet (which must be forwarded) yet also returns the old packet (which
  must be dropped). The extern function returns twice -- first with the old
  packet (and setting forward==0) and then with the compressed packet (and
  setting forward==1).
*/
        if (forward == 0) {
            drop();
            return;
        }
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;

#else
#error Currently unsupported target
#endif
