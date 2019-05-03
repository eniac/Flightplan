#include "v1model.p4"

struct  booster_metadata_t {
}

typedef bit<48> MacAddress;
header eth_h
{
    MacAddress dst;
    MacAddress src;
    bit<16> type;
}

struct headers_t {
    eth_h eth;
}

extern SampleExtern {
    SampleExtern();
    void increment_1(int<16> by);
    void increment_2(int<16> by);
    void increment_both_by_1();
    void is_1_more_than(in bit<16> than, out bit<1> is_it);
}

parser SampleParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd)
{
    state start {
        transition parse_eth;
    }

    state parse_eth {
        pkt.extract(hdr.eth);
        transition accept;
    }
}

control SampleProcess(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    SampleExtern() extr;

    apply {
        extr.increment_1(7);
        extr.increment_2(3);
        extr.increment_both_by_1();
        bit<1> x = 0;
        extr.is_1_more_than(20, x);
        if (x == 1) {
            extr.increment_1(-20);
        }
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

