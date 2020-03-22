/*
Flightplan runtime support
Nik Sultana, UPenn, February 2020
*/

            if (!hdr.fp.isValid()) {
              return;
            } else if (hdr.fp.state & InvalidCodeFlow > 0) {
              drop();
            } else {
              // Hand-over to next segment
              serialise_metadata(hdr, meta);
              idx_next_segment.apply();
              if (to_segment_idx_pip.apply().hit) {
                update_pip_state(hdr, idx_ns, idx_pip);
              } else {
                hdr.fp.seqno = 0;
                hdr.fp.state = 0;
              }

              current_nextseg_state.read(state_buffer, idx_ns);
              // Egress to the offload
              if (OFF_STATE == state_buffer || !offload_port_lookup.apply().hit) {
                hdr.fp.state = hdr.fp.state | NoOffloadPort;
		// NOTE in this case could feedback a NAK/Suitable flag to
		//      upstream to let them know that this dataplane isn't
		//      viable for the continuation of the computation --
		//      either because of a NoOffloadPort (configuration error)
		//      or because the state is currently OFF_STATE (i.e.,
		//      either the state isn't ON, or it got turned OFF because
		//      we ran out of options).
                drop();
              }
            }

            bit<1> drop_outgoing;
            reg_drop_outgoing.read(drop_outgoing, idx_ns);
            if (TRUE == drop_outgoing) {
              drop();
            }
