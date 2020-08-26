#ifndef PARSING_P4_
#define PARSING_P4_

#include "targets.h"
#include "Configuration.h"
#include "FlightplanHeader.p4"

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
    bit<16> packet_len;
}

header ipv4_h {
  	bit<4>   version;
  	bit<4>   ihl;
//	bit<8>   tos;
  	bit<6>   diffserv;
  	bit<2>   ecn;
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

// from tutorials/exercises/basic_tunnel
const bit<16> TYPE_MYTUNNEL = 0x1212;
header myTunnel_t {
    bit<16> proto_id;
    bit<16> dst_id;
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
    flightplan_h fp;
    eth_h  eth;
    fec_h  fec;
    myTunnel_t   myTunnel;
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


@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
parser FecParser(packet_in pkt, out headers_t hdr) {
    state start {
        //transition parse_eth;
        transition select(pkt.lookahead<bit<112>>() & 112w0xFFFF) {
            ETHERTYPE_FLIGHTPLAN : parse_flightplan;
            default : parse_eth;
        }
    }

    state parse_eth {
        pkt.extract(hdr.eth);
        transition select(hdr.eth.type) {
            ETHERTYPE_WHARF : parse_fec;
            ETHERTYPE_IPV4 : parse_ipv4;
            ETHERTYPE_LLDP: parse_lldp;
            TYPE_MYTUNNEL: parse_myTunnel; // from tutorials/exercises/basic_tunnel
            default : accept;
        }
    }

    state parse_flightplan {
      pkt.extract(hdr.fp);
      transition parse_eth;
    }

    state parse_fec {
        pkt.extract(hdr.fec);
        transition select(hdr.fec.orig_ethertype) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    // from tutorials/exercises/basic_tunnel
    state parse_myTunnel {
        pkt.extract(hdr.myTunnel);
        transition select(hdr.myTunnel.proto_id) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
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

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
control FecDeparser(packet_out pkt, in headers_t hdr) {
    apply {
        pkt.emit(hdr.fp);
        pkt.emit(hdr.eth);
        pkt.emit(hdr.fec);
        pkt.emit(hdr.myTunnel);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.tcp);
        pkt.emit(hdr.udp);

        pkt.emit(hdr.lldp_tlv_chassis_id);
        pkt.emit(hdr.lldp_tlv_port_id);
        pkt.emit(hdr.lldp_tlv_ttl_id);
        pkt.emit(hdr.lldp_prefix);
        pkt.emit(hdr.lldp_activate_fec);
        pkt.emit(hdr.lldp_tlv_end);
    }
}

#endif //PARSING_P4_
