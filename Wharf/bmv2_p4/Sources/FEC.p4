#include "Configuration.h"

typedef bit<48> MacAddress;

typedef bit<FEC_TRAFFIC_CLASS_WIDTH> tclass_t;
typedef bit<FEC_BLOCK_INDEX_WIDTH> bindex_t;
typedef bit<FEC_PACKET_INDEX_WIDTH> pindex_t;

header eth_h
{
    MacAddress dst;
    MacAddress src;
    bit<16> type;
}

header fec_h
{
    tclass_t traffic_class;
    bindex_t block_index;
    pindex_t packet_index;
    bit<16> orig_ethertype;
}

header ipv4_h {
  	bit<4>   version;
  	bit<4>   ihl;
  	bit<8>   tos;
  	bit<16>  len;
  	bit<16>  id;
  	bit<3>   flags;
  	bit<13>  frag;
  	bit<8>   ttl;
  	bit<8>   proto;
  	bit<16>  chksum;
  	bit<32>  src;
  	bit<32>  dst;
}

#define ETHERTYPE_WHARF 0x081C
#define ETHERTYPE_IPV4 0x0800

#define TCP_PROTOCOL 0x06
#define UDP_PROTOCOL 0x11

struct headers_t {
    eth_h  eth;
    fec_h  fec;
    ipv4_h ipv4;
}

extern void get_fec_state(in tclass_t class, out bindex_t block_index, out pindex_t packet_index);
extern void fec_encode(in eth_h eth, in ipv4_h ip, in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h);
extern void fec_decode(in eth_h eth, in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h);

parser FecParser(packet_in pkt, out headers_t hdr) {
    state start {
        transition parse_eth;
    }

    state parse_eth {
        pkt.extract(hdr.eth);
        transition select(hdr.eth.type) {
            ETHERTYPE_WHARF : parse_fec;
            ETHERTYPE_IPV4 : parse_ipv4;
            default : accept;
        }

    }

    state parse_fec {
        pkt.extract(hdr.fec);
        transition accept;
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }
}

control Forwarder(inout standard_metadata_t smd) {

    action set_egress(bit<9> port) {
        smd.egress_spec = port;
    }

    table forward {
        key = {
            smd.ingress_port : exact;
        }
        actions = { set_egress; NoAction; }
        default_action = NoAction;

        const entries = {
            1 : set_egress(2);
            2 : set_egress(1);
        }
    }

    apply {
        forward.apply();
    }
}


control FecClassParams(in tclass_t tclass, out bit<FEC_K_WIDTH> k, out bit<FEC_H_WIDTH> h) {

    action set_k_h(bit<FEC_K_WIDTH> k_in, bit<FEC_H_WIDTH> h_in) {
        k = k_in;
        h = h_in;
    }

    table classification {
        key = {
            tclass : exact;
        }

        actions = { set_k_h; }
        default_action = set_k_h(0,0);

        const entries = {
            0 : set_k_h(5, 1);
        }
    }

    apply {
        classification.apply();
    }
}

control FecEncode(inout headers_t hdr, inout standard_metadata_t smd) {
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

    action classify(tclass_t tclass) {
        hdr.fec.setValid();
        hdr.fec.traffic_class = tclass;
    }

    table classification {
        key = {
            hdr.ipv4.proto: exact;
        }

        actions = { classify; NoAction; }
        default_action = NoAction;

        const entries = {
            TCP_PROTOCOL : classify(0);
            UDP_PROTOCOL : classify(0);
        }
    }

    apply {

        if (!hdr.eth.isValid()) {
            mark_to_drop();
            return;
        }

        Forwarder.apply(smd);
        classification.apply();
        if (hdr.fec.isValid()) {
            FecClassParams.apply(hdr.fec.traffic_class, k, h);
            get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index);
            hdr.fec.orig_ethertype = hdr.eth.type;
            fec_encode(hdr.eth, hdr.ipv4, hdr.fec, k, h);
            hdr.eth.type = ETHERTYPE_WHARF;
        }
    }
}

control FecDecode(inout headers_t hdr, inout standard_metadata_t smd) {

    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

    apply {
        Forwarder.apply(smd);
        if (hdr.fec.isValid()) {
            FecClassParams.apply(hdr.fec.traffic_class, k, h);
            hdr.eth.type = hdr.fec.orig_ethertype;
            fec_decode(hdr.eth, hdr.fec, k, h);
            if (hdr.fec.packet_index >= k) {
                mark_to_drop();
            }
            hdr.fec.setInvalid();
        }
    }
}

control FecDeparser(packet_out pkt, in headers_t hdr) {
    apply {
        pkt.emit(hdr.eth);
        pkt.emit(hdr.fec);
        pkt.emit(hdr.ipv4);
    }
}
