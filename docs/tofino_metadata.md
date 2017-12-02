#### Parser metadata ####
Parser metadata includes timestamp and error indicator. One important error type is FCS errors -- these are corrupt packets that will be dropped.

```
/* Produced by Ingress Parser-Auxiliary */ 
header_type ingress_intrinsic_metadata_from_parser_aux_t {
    fields {
        ingress_global_tstamp : 48;     // global timestamp (ns) taken upon arrival at ingress.
        ingress_global_ver : 32;        // global version number taken upon arrival at ingress.
        ingress_parser_err : 16;        // error flags indicating error(s) encountered at ingress parser.
    }
}
header ingress_intrinsic_metadata_from_parser_aux_t ig_intr_md_from_parser_aux;

/////////////////////////////////////////////////////////////
// Parser hardware error codes
/////////////////////////////////////////////////////////////
#define PARSER_ERROR_OK             0x0000
#define PARSER_ERROR_NO_TCAM        0x0001
#define PARSER_ERROR_PARTIAL_HDR    0x0002
#define PARSER_ERROR_CTR_RANGE      0x0004
#define PARSER_ERROR_TIMEOUT_USER   0x0008
#define PARSER_ERROR_TIMEOUT_HW     0x0010
#define PARSER_ERROR_SRC_ERR        0x0020
#define PARSER_ERROR_DST_ERR        0x0040
#define PARSER_ERROR_PIPE_OWNER     0x0080
#define PARSER_ERROR_MULTIWRITE     0x0100
#define PARSER_ERROR_CTR_RAM        0x0200
#define PARSER_ERROR_ACTION_RAM     0x0400
#define PARSER_ERROR_CHKSUM_RAM     0x0800
#define PARSER_ERROR_FCS            0x1000
#define PARSER_ERROR_ARRAY_OOB      0xC000
```
