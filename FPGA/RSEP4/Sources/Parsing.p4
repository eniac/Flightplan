#include "xilinx.p4"
#include "Configuration.h"

#define ETHERTYPE_WHARF 0x081C
#define ETHERTYPE_LLDP  0x88CC
#define ETHERTYPE_IPv4  0x0800

typedef bit<48> MacAddress;

header eth_h
{
	MacAddress	dst;
	MacAddress	src;
	bit<16>		type;
}

header fec_h
{
	bit<FEC_TRAFFIC_CLASS_WIDTH>	traffic_class;
	bit<FEC_BLOCK_INDEX_WIDTH>	block_index;
	bit<FEC_PACKET_INDEX_WIDTH>	packet_index;
	bit<16>				original_type;
}

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

struct headers_t {
  eth_h              eth;
  fec_h              fec;

  ipv4_h             ipv4;

  tlv_t              lldp_tlv_chassis_id;
  tlv_t              lldp_tlv_port_id;
  tlv_t              lldp_tlv_ttl_id;
  prefix_tlv_t       lldp_prefix;
  activate_fec_tlv_t lldp_activate_fec;
  tlv_t              lldp_tlv_end;
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
control Deparser(in headers_t hdr, packet_out pkt) {
  apply
  {
    pkt.emit(hdr.eth);
    pkt.emit(hdr.fec);
    pkt.emit(hdr.ipv4);
  }
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
parser Parser(packet_in pkt, out headers_t hdr) {
  state start {
    pkt.extract(hdr.eth);
    transition select(hdr.eth.type) {
      ETHERTYPE_IPv4 : parse_ipv4;
      ETHERTYPE_LLDP : parse_lldp;
      default        : accept;
    }
  }

  state parse_lldp {
    pkt.extract(hdr.lldp_tlv_chassis_id);
    pkt.extract(hdr.lldp_tlv_port_id);

    pkt.extract(hdr.lldp_tlv_ttl_id); // NOTE when this and subsequent parsing code is enabled, we get this warning, it seems related to the parser: "*** Warning: Truncation of sized constant detected while generating C++ model: target width:5, value:48, width of value:6"
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

  state parse_ipv4 {
    pkt.extract(hdr.ipv4);
    transition accept;
  }
}
