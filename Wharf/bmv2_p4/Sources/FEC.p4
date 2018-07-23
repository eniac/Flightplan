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
#define ETHERTYPE_LLDP  0x88CC

#define TCP_PROTOCOL 0x06
#define UDP_PROTOCOL 0x11


header tlv_t {
  bit<7> tlv_type;
  bit<9> tlv_length;
  bit<8> tlv_value;
}

header prefix_tlv_t {
  bit<7> tlv_type;
  bit<9> tlv_length;
}

header activate_fec_tlv_t {
  bit<8> tlv_value;
}

header tcp_h {
    bit<16>             sport;
    bit<16>             dport;
    bit<32>             seq;
    bit<32>             ack;
    bit<4>              dataofs;
    bit<4>              reserved;
    bit<8>              flags;
    bit<16>             window;
    bit<16>             chksum;
    bit<16>             urgptr;
}

header udp_h {
    bit<16>             sport;
    bit<16>             dport;
    bit<16>             len;
    bit<16>             chksum;
}
struct headers_t {
    eth_h  eth;
    fec_h  fec;
    ipv4_h ipv4;
	tcp_h tcp;
	udp_h udp;

    tlv_t              lldp_tlv_chassis_id;
    tlv_t              lldp_tlv_port_id;
    tlv_t              lldp_tlv_ttl_id;
    prefix_tlv_t       lldp_prefix;
    activate_fec_tlv_t lldp_activate_fec;
    tlv_t              lldp_tlv_end;
}


#define PORT_SIZE 9

extern void set_port_status(in bit<PORT_SIZE> port_number);
extern void get_port_status(in bit<PORT_SIZE> port_number, out bit<1> faulty);
extern void get_fec_state(in tclass_t class, out bindex_t block_index, out pindex_t packet_index);
extern void fec_encode<T>(in eth_h eth, in ipv4_h ip, in T proto, in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h);
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
            ETHERTYPE_LLDP: parse_lldp;
            default : accept;
        }

    }

    state parse_fec {
        pkt.extract(hdr.fec);
        transition accept;
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
		transition select(hdr.ipv4.proto) {
            TCP_PROTOCOL: parse_tcp;
            UDP_PROTOCOL: parse_udp;
            default: accept;
        }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        transition accept;
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        transition accept;
    }

    state parse_lldp {
        pkt.extract(hdr.lldp_tlv_chassis_id);
        pkt.extract(hdr.lldp_tlv_port_id);

        // NOTE when this and subsequent parsing code is enabled, 
        // we get this warning, it seems related to the parser: 
        //   *** Warning: Truncation of sized constant detected while generating C++ model:
        //    target width:5, value:48, width of value:6"
        pkt.extract(hdr.lldp_tlv_ttl_id); 
        pkt.extract(hdr.lldp_prefix);

        // FIXME ensure that hdr.lldp_prefix.tlv_type == 7w127
        transition select(hdr.lldp_prefix.tlv_length) {
            9w1 : parse_lldp_activate_fec;
            default        : accept;
        }
    }

    state parse_lldp_activate_fec {
        pkt.extract(hdr.lldp_activate_fec);
        // FIXME ensure that lldp_tlv_end has type=0 etc
        pkt.extract(hdr.lldp_tlv_end);
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

control FECControlPacket(inout headers_t hdr, in standard_metadata_t smd, out bit<1> acted) {

    apply {
        acted = 0;
        if (hdr.lldp_tlv_chassis_id.isValid()) {
            if (hdr.lldp_activate_fec.isValid()) {
                set_port_status(smd.ingress_port);
                mark_to_drop();
            }
            acted = 1;
        }
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

    bit<24> proto_and_port = 0;

    action classify(tclass_t tclass) {
        hdr.fec.setValid();
        hdr.fec.traffic_class = tclass;
    }

    table classification {
        key = {
            proto_and_port : exact;
        }

        actions = { classify; NoAction; }
        default_action = classify(0);

        const entries = {
            ((bit<8>)TCP_PROTOCOL ++ (bit<16>)0) : classify(0);
            ((bit<8>)UDP_PROTOCOL ++ (bit<16>)0) : classify(0);
        }
    }

    apply {
        if (!hdr.eth.isValid()) {
            mark_to_drop();
            return;
        }

        bit<1> is_ctrl;
        FECControlPacket.apply(hdr, smd, is_ctrl);
        if (is_ctrl == 1)
            return;

        Forwarder.apply(smd);
        bit<1> faulty = 1;
        // TODO: Disabling next line until there are lldp packets to test with
        //get_port_status(smd.ingress_port, faulty);
        if (faulty == 1) {
            if (hdr.tcp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.tcp.dport;
            } else if (hdr.udp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.udp.dport;
            } else {
                proto_and_port = hdr.ipv4.proto ++ (bit<16>)0;
            }

            classification.apply();
            if (hdr.fec.isValid()) {
                FecClassParams.apply(hdr.fec.traffic_class, k, h);
                get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index);
                hdr.fec.orig_ethertype = hdr.eth.type;
                if (hdr.tcp.isValid()) {
                    fec_encode(hdr.eth, hdr.ipv4, hdr.tcp, hdr.fec, k, h);
                } else {
                    fec_encode(hdr.eth, hdr.ipv4, hdr.udp, hdr.fec, k, h);
                }
                hdr.eth.type = ETHERTYPE_WHARF;
            }
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
        pkt.emit(hdr.tcp);
        pkt.emit(hdr.udp);
    }
}
