/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/

/* Updated headers_t to include flightplan_h between ethernet and everything else:
struct headers_t {
  eth_h              eth;
  flightplan_h       fp;
  ...
*/
typedef flightplanReceive1_h flightplanReceive2_h;
typedef flightplanReceive1_h flightplanSend1_h;
typedef flightplanReceive1_h flightplanSend2_h;
struct fp_headers_t {
  eth_h        eth;
  flightplan_h fp;
  flightplanReceive1_h fpReceive1;
  flightplanReceive2_h fpReceive2;
  flightplanSend1_h fpSend1;
  flightplanSend2_h fpSend2;
}

parser Parser(packet_in pkt, out fp_headers_t hdr,
              inout booster_metadata_t m, inout metadata_t meta) {
  state start {
    pkt.extract(hdr.eth);
    transition select(hdr.eth.eth_type) {
      ETHERTYPE_FLIGHTPLAN : parse_flightplan;
      default        : reject;
    }
  }

  state parse_flightplan {
    pkt.extract(hdr.fp);
    transition select(hdr.fp.from_segment) {
      1 : parse_fpReceive1;
      2 : parse_fpReceive2;
      default        : reject;
    }
  }

  state parse_fpReceive1 {
    pkt.extract(hdr.fpReceive1);
    transition accept;
  }

  state parse_fpReceive2 {
    pkt.extract(hdr.fpReceive2);
    transition accept;
  }
}
