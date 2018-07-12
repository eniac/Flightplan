/*
Top-level P4 for Wharf
DCOMP project, UPenn, April 2018
*/

#include "Parsing.p4"
#include "FEC.p4"
#include "LLDP.p4"

control Pipeline(inout headers_t hdr, inout switch_metadata_t ctrl) {

  Drop() drop;
  FECControlPacket() fec_control_packet;
  bit<1> fcp_acted;
  PrePipeline() p;

  apply {
    if (!hdr.eth.isValid()) {
      drop.apply(hdr, ctrl); // FIXME needed?
      return; // FIXME or "exit"?
    }

    fec_control_packet.apply(hdr, ctrl, fcp_acted);

    p.apply(hdr, ctrl);
  }
}

XilinxSwitch(Parser(), Pipeline(), Deparser()) main;
