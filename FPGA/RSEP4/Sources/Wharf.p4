/*
Traffic classification for Wharf
Nik Sultana, UPenn, April 2018
*/

#include <xilinx.p4>

#define ETHERTYPE_WHARF 0x081C
#define ETHERTYPE_LLDP  0x88CC
#define ETHERTYPE_IPv4  0x0800

#if 0
// number of bits used for type-and-proto, concatenated to form key for lookup.
#define TAP_KEY_SIZE 24
// number of bits used for traffic class.
// NOTE setting CLASS_SIZE==3, while allowing the match to succeed in RTL, strangely doesn't result in the action taking place (to update the wharf header)
#define CLASS_SIZE 4

// FIXME fudge -- width of port number. Must agree with width of "egress" below.
#define PORT_SIZE 12
// Modes: 0 = read, 1 = write.
@Xilinx_MaxLatency(100)
extern void port_status(in bit<1> mode, in bit<PORT_SIZE> port_number, out bit<1> faulty);
#endif


#define BLOCK_ID_WIDTH 5
#define FRAME_ID_WIDTH 8

@Xilinx_MaxLatency(100)
extern void get_wharf_state(in bit<CLASS_SIZE> tclass, out bit<BLOCK_ID_WIDTH> block_id, out bit<FRAME_ID_WIDTH> frame_id);

header ethernet_h {
  bit<48> dst;
  bit<48> src;
  bit<16> type;
}

header tlv_t {
  bit<7> tlv_type;
  bit<9> tlv_length;
  bit<8> tlv_value;
}

header wharf_h {
  bit<CLASS_SIZE> tclass;
  bit<BLOCK_ID_WIDTH> block_id;
  bit<FRAME_ID_WIDTH> frame_id;
  // Encapsulated ethernet header + frame size is specified down the line.
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

header prefix_tlv_t {
  bit<7> tlv_type;
  bit<9> tlv_length;
}

header activate_wharf_tlv_t {
  bit<8> tlv_value;
}

struct headers_t {
  ethernet_h ethernet;
  wharf_h    wharf;
  ipv4_h     ipv4;

  tlv_t                lldp_tlv_chassis_id;
  tlv_t                lldp_tlv_port_id;
  tlv_t                lldp_tlv_ttl_id;
  prefix_tlv_t         lldp_prefix;
  activate_wharf_tlv_t lldp_activate_wharf;
  tlv_t                lldp_tlv_end;
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
parser Parser(packet_in pkt, out headers_t hdr) {
  state start {
    pkt.extract(hdr.ethernet);
    transition select(hdr.ethernet.type) {
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
      9w1 : parse_lldp_activate_wharf;
      default        : accept;
    }
  }

  state parse_lldp_activate_wharf {
    pkt.extract(hdr.lldp_activate_wharf);
    // FIXME ensure that lldp_tlv_end has type=0 etc
    pkt.extract(hdr.lldp_tlv_end);
    transition accept;
  }

  state parse_ipv4 {
    pkt.extract(hdr.ipv4);
    transition accept;
  }
}

control Pipeline(inout headers_t hdr, inout switch_metadata_t ctrl) {
    action drop() {
      ctrl.egress_port = 0xF; // FIXME not portable.
    }

    action classify (bit<CLASS_SIZE> tclass) {
      hdr.wharf.setValid();
      hdr.wharf.tclass = tclass;
      // NOTE block_id and frame_id will be updated downstream by get_wharf_state()
      hdr.wharf.block_id = /*BLOCK_ID_WIDTH*/5w0;
      hdr.wharf.frame_id = /*FRAME_ID_WIDTH*/8w0;
    }

    action zero_class () {
      classify(0);
    }

    bit<TAP_KEY_SIZE> type_and_proto;

    // NOTE adding this line sends sdnet into tailspin during RTL simulation @Xilinx_ExternallyConnected
    table classification {
      key = {
        type_and_proto : exact; // FIXME ternary might make more sense
      }
      actions = { classify; /*zero_class*/NoAction; }
      size = 64; // FIXME fudge
      default_action = /*zero_class*/NoAction;
/* NOTE not supported by SDNet
      const entries = {
        (0x0800, 17 ) : classify(1);
        (0x0800, 6 )  : classify(2);
        (0x0800, _ )  : classify(3);
        (_, _ )       : classify(4);
      }
*/
    }

    bit<12> egress = 0; // NOTE 12 since to be the least width for exact-match. Ideally its type should be "switch_port_t".
    bit<4/*FIXME arbitrary*/> h = 0;

    action set_egress (switch_port_t port) {
      egress = (bit<12>)port;
    }

    table forward {
      key = {
        hdr.ethernet.dst : exact;
      }
      actions = { set_egress; NoAction; }
      size = 64; // FIXME fudge
      default_action = NoAction/*FIXME broadcast*/;
    }

    action link_status (bit<4/*FIXME arbitrary*/> status) {
      h = status;
    }

    apply {
      if (!hdr.ethernet.isValid()) {
        drop(); // FIXME needed?
        return; // FIXME or "exit"?
      }

      if (hdr.lldp_tlv_chassis_id.isValid()) {
        if (hdr.lldp_activate_wharf.isValid()) {
          bit<1> faulty;
#if 0
          port_status(1, (bit<PORT_SIZE>/*FIXME can drop the cast?*/)ctrl.ingress_port, faulty);
#endif
          drop();
        }
      } else {
        forward.apply();
        bit<1> faulty;
#if 0
        port_status(0, egress, faulty);
#endif
        ctrl.egress_port = (switch_port_t)egress;

        if (!hdr.ipv4.isValid())
          return;

        if (h > 0) {
//        zero_class();
          type_and_proto = hdr.ethernet.type ++ hdr.ipv4.proto;
          classification.apply();
          hdr.wharf.setValid();

#if 0
          get_wharf_state(hdr.wharf.tclass, hdr.wharf.block_id, hdr.wharf.frame_id); // FIXME should manage its own timer?
#endif
          // FIXME hand over to Encoder
        }
      }
    }
}


@Xilinx_MaxPacketRegion(1518*8)  // in bits
control Deparser(in headers_t hdr, packet_out pkt) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.wharf);
        pkt.emit(hdr.ipv4);
    }
}

XilinxSwitch(Parser(), Pipeline(), Deparser()) main;

