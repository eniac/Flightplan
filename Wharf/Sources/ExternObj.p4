#include "v1model.p4"

struct headers_t {
}
struct  booster_metadata_t {
}

extern SampleExtern {
    SampleExtern();
    void increment_1(bit<16> by);
    void increment_2(bit<16> by);
    void increment_both_by_1();
}

parser SampleParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd)
{
    state start {
        transition accept;
    }
}

control SampleProcess(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    SampleExtern() extr;

    apply {
        extr.increment_1(7);
        extr.increment_2(3);
        extr.increment_both_by_1();
    }
}

control NullVerifyCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}
control NullEgress(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    apply {}
}

control NullCompCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

control SampleDeparser(packet_out pkt, in headers_t hdr) {
	apply
	{
		pkt.emit(hdr);
	}
}

V1Switch(SampleParser(), NullVerifyCheck(), SampleProcess(), NullEgress(), NullCompCheck(), SampleDeparser()) main;

