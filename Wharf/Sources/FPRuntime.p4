/*
Flightplan runtime support
Nik Sultana, UPenn, February 2020
*/

// FIXME const
#define V1S_WIDTH_PORT_NUMBER 9

// FIXME this value should be customised for each generated program.
//       It should accommodate all idx_pip needed by this particular program split.
#define NUM_LINKS 8
register<bit<1>>(NUM_LINKS) flightplan_pip_syn_next; // Set syn on next outgoing packet (and reset local state wrt that next_segment). Used if we relink.
register<bit<SEQ_WIDTH>>(NUM_LINKS) flightplan_pip_seqno; // Current seqno for that next_segment (and symmetrically for a next_segment we're serving from this dataplane).
register<bit<1>>(NUM_LINKS) flightplan_pip_expecting_ack; // If sending to a next_segment, this indicates we're expecting an ACK back. Unused if we're serving a next_segment.
register<bit<SEQ_WIDTH>>(NUM_LINKS) flightplan_pip_seqno_ackreq_sent; // "lastack" Stores one of two values depending on context: if flightplan_pip_expecting_ack then it stores the seqno of when we sent the request for an ACK. Otherwise it stores the seqno of when we last received an ACK (we use this to decide when to set flightplan_pip_expecting_ack again, which we do wrt flightplan_pip_ackreq_interval). Unused if we're serving a next_segment.

register<bit<SEQ_WIDTH>>(NUM_LINKS) flightplan_pip_nak_count; // On both serving and using sides of a next_segment, the number of NAKs.

register<bit<SEQ_WIDTH>>(NUM_LINKS) flightplan_pip_nak_count_max; // Max number of NAKs sent/received before relink.
register<bit<SEQ_WIDTH>>(NUM_LINKS) flightplan_pip_ackreq_interval; // "regularcheck" On side using next_segment: how frequently to poll serving side for an ACK. Unused on serving side.
register<bit<SEQ_WIDTH>>(NUM_LINKS) flightplan_pip_ackreq_interval_exceed_max; // "maxsinceack" On side using next_segment: when expecting_ack, after how many sends do we relink. Unused on serving side.

// FIXME this value should be customised for each generated program
//       it's the total of next_segments linked from here.
#define NUM_NEXTSEGS 8
register<bit<SEGMENT_DESC_SIZE>>(NUM_NEXTSEGS) current_nextseg_state;
register<bit<SEGMENT_DESC_SIZE>>(NUM_NEXTSEGS) num_nextseg_states; // 2 by default (off and on), and more if there are fail-overs.
register<bit<1>>(NUM_NEXTSEGS) reg_drop_outgoing;

#define OFF_STATE 0
#define TRUE 1
#define FALSE 0

void relink(in int state_increase, in bit<32> idx_ns, in bit<32> idx_pip) {
  bit<SEGMENT_DESC_SIZE> ts_state;
  bit<SEGMENT_DESC_SIZE> ts_num_states;
  current_nextseg_state.read(ts_state, idx_ns);
  num_nextseg_states.read(ts_num_states, idx_ns);

  // Links can be reactived only from the controller.
  if (OFF_STATE == ts_state) {
    return;
  }

  ts_state = ts_state + (bit<SEGMENT_DESC_SIZE>)state_increase;
  current_nextseg_state.write(idx_ns, ts_state);

  if (ts_state >= ts_num_states) {
    // We're out of options, deactivate use of this next_segment
    current_nextseg_state.write(idx_ns, OFF_STATE);
    // FIXME could notify our upstream about this -- raise FPRelink.
  } else {
    flightplan_pip_syn_next.write(idx_pip, TRUE);
  }
}

void init_computation(inout headers_t hdr) {
  hdr.fp.setValid();
  hdr.fp.dst = hdr.eth.dst;
  hdr.fp.src = hdr.eth.src;
  hdr.fp.type = ETHERTYPE_FLIGHTPLAN;
}

void end_computation(inout headers_t hdr) {
  hdr.fp.setInvalid();
}

void set_computation_order(inout headers_t hdr, in bit<SEGMENT_DESC_SIZE> from_segment, in bit<SEGMENT_DESC_SIZE> to_segment) {
  hdr.fp.from_segment = from_segment;
  hdr.fp.to_segment = to_segment;
}

void serialise_metadata(inout headers_t hdr, inout metadata_t meta) {
  hdr.fp.quad1 = (bit<32>)meta.ingress_port;
  hdr.fp.quad2 = (bit<32>)meta.egress_spec;
}

void deserialise_metadata(inout headers_t hdr, inout metadata_t meta) {
  meta.ingress_port = (bit<V1S_WIDTH_PORT_NUMBER>)hdr.fp.quad1;
  meta.egress_spec = (bit<V1S_WIDTH_PORT_NUMBER>)hdr.fp.quad2;
}

void reset_pip_state(in bit<32> idx) {
  flightplan_pip_syn_next.write(idx, FALSE);
  flightplan_pip_seqno.write(idx, 0);
  flightplan_pip_expecting_ack.write(idx, FALSE);
  flightplan_pip_seqno_ackreq_sent.write(idx, 0);
  flightplan_pip_nak_count.write(idx, 0);
  // NOTE flightplan_pip_nak_count_max, flightplan_pip_ackreq_interval and
  //      flightplan_pip_ackreq_interval_exceed_max are only set by the controller.
}

void inc_seqno(inout headers_t hdr, in bit<32> idx) {
  flightplan_pip_seqno.read(hdr.fp.seqno, idx);
  flightplan_pip_seqno.write(idx, hdr.fp.seqno + 1);
  // FIXME if wrapping around then "relink" to same link, to reset state at both ends -- raise "syn" flag
}

void update_pip_state(inout headers_t hdr, in bit<32> idx_ns, in bit<32> idx_pip) {
  hdr.fp.state = 0;

  bit<1> syn_next;
  flightplan_pip_syn_next.read(syn_next, idx_pip);
  if (TRUE == syn_next) {
    hdr.fp.state = hdr.fp.state | FPSyn;
    reset_pip_state(idx_pip);
  }

  inc_seqno(hdr, idx_pip);

  bit<1> expecting_ack;
  bit<SEQ_WIDTH> ackreq_interval;
  bit<SEQ_WIDTH> seqno_ackreq_sent;

  flightplan_pip_expecting_ack.read(expecting_ack, idx_pip);
  flightplan_pip_ackreq_interval.read(ackreq_interval, idx_pip);
  flightplan_pip_seqno_ackreq_sent.read(seqno_ackreq_sent, idx_pip);
  if (TRUE == expecting_ack) {
    bit<SEQ_WIDTH> ackreq_interval_exceed_max;
    flightplan_pip_ackreq_interval_exceed_max.read(ackreq_interval_exceed_max, idx_pip);
    if (ackreq_interval_exceed_max > 0 && hdr.fp.seqno - seqno_ackreq_sent > ackreq_interval_exceed_max) {
      relink(1, idx_ns, idx_pip);
      hdr.fp.state = hdr.fp.state | FPSyn;
      reset_pip_state(idx_pip);
      inc_seqno(hdr, idx_pip);
    } else {
      // Keep raising ACK flag in case some packets to downstream are being lost.
      hdr.fp.state = hdr.fp.state | FPAck;
    }
  } else if (ackreq_interval > 0 && hdr.fp.seqno - seqno_ackreq_sent > ackreq_interval) {
    flightplan_pip_seqno_ackreq_sent.write(idx_pip, hdr.fp.seqno);
    flightplan_pip_expecting_ack.write(idx_pip, TRUE);
    hdr.fp.state = hdr.fp.state | FPAck;
  }
}

void check_ack(inout headers_t hdr, in bit<32> idx, out bit<1> result) {
  result = 0;
  if (hdr.fp.state & FPAck > 0) {
    bit<1> expecting_ack;
    flightplan_pip_expecting_ack.read(expecting_ack, idx);
    if (TRUE == expecting_ack) {
      // This is an ACK reply, update PIP state.
      flightplan_pip_expecting_ack.write(idx, FALSE);
      bit<SEQ_WIDTH> seqno;
      flightplan_pip_seqno.read(seqno, idx);
      flightplan_pip_seqno_ackreq_sent.write(idx, seqno);
      hdr.fp.state = FPAck ^ hdr.fp.state;
      result = 1;
    } else {
      // This is an ACK request, reply to it.
      clone(CloneType.I2E, idx);
    }
  }
}

void check_seqno(inout headers_t hdr, in bit<32> idx_ns, in bit<32> idx_pip) {
  if (hdr.fp.state & FPSyn > 0) {
      reset_pip_state(idx_pip);
  } else {
      bit<SEQ_WIDTH> seqno;
      flightplan_pip_seqno.read(seqno, idx_pip);
      if (seqno + 1 != hdr.fp.seqno) {
        bit<SEQ_WIDTH> nak_count;
        flightplan_pip_nak_count.read(nak_count, idx_pip);
        nak_count = nak_count + 1;
        flightplan_pip_nak_count.write(idx_pip, nak_count);

        bit<SEQ_WIDTH> nak_count_max;
        flightplan_pip_nak_count_max.read(nak_count_max, idx_pip);
        if (nak_count_max > 0 && nak_count >= nak_count_max) {
          // Do nothing in this case, we rely on upstream to
          // relink. To be more strict could explicitly keep
          // telling upstream it should relink from this point on.

          // Shutdown handling of this next_segment.
          current_nextseg_state.write(idx_ns, OFF_STATE);
        }

        clone(CloneType.I2E, idx_pip);
      }
  }
  // Update local state, to implicitly re-synch.
  flightplan_pip_seqno.write(idx_pip, hdr.fp.seqno);
  // Also, packet is forwarded as normal. Rely on upper layer to sort out consistency beyond PIP.
}

void check_nak(inout headers_t hdr, in bit<32> idx_ns, in bit<32> idx_pip, out bit<1> invoked) {
  if (hdr.fp.state & FPNak > 0) {
    bit<SEQ_WIDTH> nak_count;
    flightplan_pip_nak_count.read(nak_count, idx_pip);
    nak_count = nak_count + 1;
    flightplan_pip_nak_count.write(idx_pip, nak_count);

    bit<SEQ_WIDTH> nak_count_max;
    flightplan_pip_nak_count_max.read(nak_count_max, idx_pip);
    if (nak_count_max > 0 && nak_count >= nak_count_max) {
      relink(1, idx_ns, idx_pip);
    }

    invoked = 1;
    return;
  }

  invoked = 0;
}
