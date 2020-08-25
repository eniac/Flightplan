#ifndef EMPTY_BM_DEFINITIONS
#define EMPTY_BM_DEFINITIONS
struct booster_metadata_t {
    bit<1> generated;
}
control NoVerify(inout headers_t hdr, inout booster_metadata_t m) { apply {} }
control NoCheck(inout headers_t hdr, inout booster_metadata_t m) { apply {} }
control NoEgress(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) { apply {} }
control ComputeCheck(inout headers_t hdr, inout booster_metadata_t m) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { hdr.ipv4.version,
              hdr.ipv4.ihl,
//              hdr.ipv4.tos,
              hdr.ipv4.diffserv,
              hdr.ipv4.ecn,
              hdr.ipv4.len,
              hdr.ipv4.id,
              hdr.ipv4.flags,
              hdr.ipv4.frag,
              hdr.ipv4.ttl,
              hdr.ipv4.proto,
              hdr.ipv4.src,
              hdr.ipv4.dst },
            hdr.ipv4.chksum, HashAlgorithm.csum16);
    }
}
#endif // EMPTU_BM_DEFINITIONS
