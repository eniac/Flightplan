/*
Flightplan runtime support -- headerless
Nik Sultana, UPenn, March 2020
*/

// FIXME const
#define V1S_WIDTH_PORT_NUMBER 9

#define TRUE 1
#define FALSE 0

#define FP_to_segment hdr.ipv4.frag[(2 * SEGMENT_DESC_SIZE) - 1 : SEGMENT_DESC_SIZE]
#define FP_active hdr.ipv4.frag[(2 * SEGMENT_DESC_SIZE) : (2 * SEGMENT_DESC_SIZE)]

void fp_get_Active(in headers_t hdr, out bool value) {
  value = false;
  if (TRUE == FP_active) {
    value = true;
  }
}
void fp_set_Active(inout headers_t hdr, in bool value) {
  FP_active = FALSE;
  if (value) {
    FP_active = TRUE;
  }
}

void fp_get_ToSegment(in headers_t hdr, out bit<SEGMENT_DESC_SIZE> value) {
  value = FP_to_segment;
}

void fp_set_ToSegment(inout headers_t hdr, in bit<SEGMENT_DESC_SIZE> value) {
  FP_to_segment = value;
}

void init_computation(inout headers_t hdr) {
  fp_set_Active(hdr, true);
}

void end_computation(inout headers_t hdr, in bit<1> computation_continuing, out bit<1> computation_ended) {
  assert(FALSE == computation_continuing);
  computation_ended = TRUE;
  fp_set_Active(hdr, false);
  hdr.ipv4.frag = 0;
}

void set_computation_order(inout headers_t hdr, out bit<1> computation_continuing, in bit<SEGMENT_DESC_SIZE> to_segment, out bit<SEGMENT_DESC_SIZE> fp_to_segment, out metadata_t meta) {
  fp_to_segment = to_segment;
  fp_set_ToSegment(hdr, to_segment);
  computation_continuing = TRUE;
}
