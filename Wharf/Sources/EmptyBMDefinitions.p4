#ifndef EMPTY_BM_DEFINITIONS
#define EMPTY_BM_DEFINITIONS
struct bmv2_meta_t {}
control NoVerify(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }
control NoCheck(inout headers_t hdr, inout bmv2_meta_t m) { apply {} }
control NoEgress(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) { apply {} }
#endif // EMPTU_BM_DEFINITIONS
