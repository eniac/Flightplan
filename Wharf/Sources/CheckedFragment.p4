/*
Prototype for Flightplan customised API

Nik Sultana, UPenn, January 2019
*/

#define ACKing
#define NAKing

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

  SenderSeqState() sender_seq_state;
  ReceiverNakState() receiver_seq_state;

  apply {
    sender_seq_state.initSeq(0);
    receiver_seq_state.initSeq(0);

    flightplan_id.apply();

    if (!hdr.fp.isValid()) {
      // Sender will initialise the headers, maybe do some processing,  and send encapsulated packet to receiver.

      next_dataplane = 1; // It's fine for this value to be hardcoded.

      hdr.fp.setValid();

      // fp version has been removed from flightplan_h
      //hdr.fp.version = 1;

      // encapsulated_ethertype removed because of full ethernet encapsulation
      //hdr.fp.encapsulated_ethertype = hdr.eth.type;
      hdr.eth.type = ETHERTYPE_FLIGHTPLAN;
      hdr.fp.from_segment = 1;
      hdr.fp.to_segment = 2;

      hdr.fpReceive1.setValid();
      sender_seq_state.nextSeq(hdr.fpReceive1.seqno);
      hdr.fpReceive1.byte1 = 1;
      // Context packaging for the next dataplane.

      flightplan_forward.apply(); // Replace flyto with lookup to determine which egress port to use.
    } else if (hdr.fpReceive2.isValid() && 0 == this_dataplane && 1 == hdr.fp.to_segment) {
      next_dataplane = 0; // It's fine for this value to be hardcoded.
      bit<1> ok = 0;
      receiver_seq_state.nextSeq(hdr.fpReceive2.seqno, ok);
      if (ok == 0) {
          receiver_seq_state.relink(ok); // FIXME not using "ok"
      }
      hdr.fpReceive2.setInvalid();
      // encapsulated_ethertype removed because of full ethernet encapsulation
      //hdr.eth.type = hdr.fp.encapsulated_ethertype;
      hdr.fp.setInvalid();
      flightplan_forward.apply(); // Replace flyto with lookup to determine which egress port to use.
    } else if (hdr.fpReceive1.isValid() && 1 == this_dataplane && 2 == hdr.fp.to_segment) {
      // Receiver will interpret the headers, maybe do some processing, and send packet to receiver.
      next_dataplane = 0; // It's fine for this value to be hardcoded.

      bit<1> ok = 0;
      receiver_seq_state.nextSeq(hdr.fpReceive1.seqno, ok);
      if (ok == 0) {
          receiver_seq_state.relink(ok); // FIXME not using "ok"
      }
      //hdr.fpReceive1.setInvalid();
      //hdr.eth.type = hdr.fp.encapsulated_ethertype;
      //hdr.fp.setInvalid();

      hdr.fp.from_segment = 2;
      hdr.fp.to_segment = 1;
      sender_seq_state.nextSeq(hdr.fpReceive1.seqno);
#if 0
FIXME for now just send the traffic back to s1
      // Context packaging for the next dataplane.
      hdr.fpReceive1.setInvalid();
      hdr.fpSend1.setValid();
      hdr.fpSend1.byte1 = hdr.fpReceive1.byte1;
      // FIXME invoke Sender and Receiver functions
#endif

      flightplan_forward.apply(); // Replace flyto with lookup to determine which egress port to use.
    } /* FIXME incomplete
      else if (hdr.fpReceive2.isValid()) {
      // TODO Work relative to the other upstream dataplane.
    } */ else {
      drop();
    }
  }
}

#include <FlightplanDeparser.p4>

V1Switch(FlightplanParser(), NoVerify(), FlightplanControl(), NoEgress(), NoCheck(), FlightplanDeparser()) main;
