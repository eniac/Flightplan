/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/

#include "Parsing.p4"
#include <FlightplanHeader.p4>
#include <FlightplanParser.p4>

control FlightplanControl(inout fp_headers_t hdr, inout booster_metadata_t m, inout metadata_t ctrl) {
  bit<MAX_DATAPLANE_CLIQUE_SIZE> this_dataplane = 0;
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

  action set_id(bit<MAX_DATAPLANE_CLIQUE_SIZE> did) {
      this_dataplane = did;
  }

  table flightplan_id {
    key = {
      this_dataplane : exact;
    }
    actions = { set_id; NoAction; }
    default_action = NoAction/*FIXME report an error if resolution fails*/;
  }

  apply {
    flightplan_id.apply();
    if (!hdr.fp.isValid()) {
      // Sender will initialise the headers, maybe do some processing,  and send encapsulated packet to receiver.

      next_dataplane = 1; // It's fine for this value to be hardcoded.

      hdr.fp.setValid();
      hdr.fp.version = 1;
      hdr.fp.encapsulated_ethertype = hdr.eth.type;
      hdr.fp.from_segment = 1;
      hdr.fp.to_segment = 2;
      // Context packaging for the next dataplane.
      hdr.fpReceive1.setValid();
      hdr.fpReceive1.byte1 = 1;

      flightplan_forward.apply(); // Replace flyto with lookup to determine which egress port to use.
    } else if (hdr.fpReceive1.isValid()) {
      // Receiver will interpret the headers, maybe do some processing, and send packet to receiver.
      next_dataplane = 1; // It's fine for this value to be hardcoded.

//      if (1 == this_dataplane) {
        hdr.fpReceive1.setInvalid();
        hdr.eth.type = hdr.fp.encapsulated_ethertype;
        hdr.fp.setInvalid();
//      }

// FIXME disabled this for the time being -- this dataplane will simply forward traffic forward
/*

      hdr.fp.from_segment = 2;
      hdr.fp.to_segment = 3;
      // Context packaging for the next dataplane.
      hdr.fpReceive1.setInvalid();
      hdr.fpSend1.setValid();
      hdr.fpSend1.byte1 = hdr.fpReceive1.byte1;
      // FIXME invoke Sender and Receiver functions
*/

      flightplan_forward.apply(); // Replace flyto with lookup to determine which egress port to use.
    } /* FIXME incomplete
      else if (hdr.fpReceive2.isValid()) {
      // TODO Work relative to the other upstream dataplane.
    } // FIXME else drop 
      */ 
  }
}

#include <FlightplanDeparser.p4>

V1Switch(FlightplanParser(), NoVerify(), FlightplanControl(), NoEgress(), NoCheck(), FlightplanDeparser()) main;
