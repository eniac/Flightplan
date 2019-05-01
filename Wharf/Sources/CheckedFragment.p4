/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/

#include "Parsing.p4"
#include <FlightplanHeader.p4>
#include <FlightplanParser.p4>

control FlightplanControl(inout fp_headers_t hdr, inout booster_metadata_t m, inout metadata_t ctrl) {
  bit<MAX_DATAPLANE_CLIQUE_SIZE> next_dataplane = 0;

  action set_egress(bit<9> port) {
      SET_EGRESS(ctrl, port);
  }

  table flightplan_forward {
    key = {
      next_dataplane : exact;
    }
    actions = { set_egress; NoAction; }
    // FIXME map next_dataplane to egress
    default_action = NoAction/*FIXME report an error if we can't find where to forward to*/;
  }

  apply {
    if (hdr.fpReceive1.isValid()) {
      next_dataplane = 1; // It's fine for this value to be hardcoded.

      // Context packaging for the next dataplane.
      hdr.fpReceive1.setInvalid();
      hdr.fpSend1.setValid();
      hdr.fpSend1.byte1 = hdr.fpReceive1.byte1;
      // FIXME invoke Sender and Receiver functions

      flightplan_forward.apply(); // Replace flyto with lookup to determine which egress port to use.
    } else if (hdr.fpReceive2.isValid()) {
      // TODO Work relative to the other upstream dataplane.
    } // FIXME else drop  
  }
}

#include <FlightplanDeparser.p4>

V1Switch(FlightplanParser(), NoVerify(), FlightplanControl(), NoEgress(), NoCheck(), FlightplanDeparser()) main;
