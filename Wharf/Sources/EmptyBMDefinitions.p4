#ifndef EMPTY_BM_DEFINITIONS
#define EMPTY_BM_DEFINITIONS
struct booster_metadata_t {
    bit<1> generated;
}
control NoVerify(inout headers_t hdr, inout booster_metadata_t m) { apply {} }
control NoCheck(inout headers_t hdr, inout booster_metadata_t m) { apply {} }
control NoEgress(inout headers_t hdr, inout booster_metadata_t m, inout metadata_t meta) { apply {} }
#endif // EMPTU_BM_DEFINITIONS
