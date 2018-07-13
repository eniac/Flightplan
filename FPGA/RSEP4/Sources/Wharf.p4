/*
Top-level P4 for Wharf
DCOMP project, UPenn, April 2018
*/

#include "Parsing.p4"
#include "LLDP.p4"
#include "FEC.p4"

control Forward(inout headers_t hdr, inout switch_metadata_t ctrl, out bit<12> egress) {
  action set_egress (switch_port_t port) {
    egress = (bit<12>)port;
  }

  table forward {
    key = {
      hdr.eth.dst : exact;
    }
    actions = { set_egress; NoAction; }
    size = 64; // FIXME fudge
    default_action = NoAction/*FIXME broadcast*/;
  }

  apply {
    egress = 0;
    forward.apply();
  }
}

control Pipeline(inout headers_t hdr, inout switch_metadata_t ctrl) {

  Drop() drop;
  Forward() forward;
  bit<12> egress = 0; // NOTE 12 since to be the least width for exact-match. Ideally its type should be "switch_port_t".
  FECControlPacket() fec_control_packet;
  bit<1> fcp_acted;
  Encode() encode;

  apply {
    if (!hdr.eth.isValid()) {
      drop.apply(hdr, ctrl); // FIXME needed?
      return; // FIXME or "exit"?
    }
    fec_control_packet.apply(hdr, ctrl, fcp_acted);
    if (fcp_acted == 1)
      return;

    forward.apply(hdr, ctrl, egress);
    ctrl.egress_port = (switch_port_t)egress;

    bit<1> faulty;
    port_status(0, egress, faulty);
    if (faulty == 0)
      return; // FIXME check if the packet gets forwarded

    encode.apply(hdr, ctrl);
  }
}

XilinxSwitch(Parser(), Pipeline(), Deparser()) main;
