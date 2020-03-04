/*
Flightplan runtime support
Nik Sultana, UPenn, February 2020
*/

         idx_next_segment_COPY.apply(); // NOTE apparently lookups can only appear once in a program, so we replicate the original table.
         bit<SEGMENT_DESC_SIZE> ts_state;
         current_nextseg_state.read(ts_state, idx_ns);
         if (OFF_STATE == ts_state) {
           drop();
           exit;
         }

         if (from_segment_idx_pip.apply().hit) {
           bit<1> invoked = 0;
           check_seqno(hdr, idx_ns, idx_pip);
           check_ack(hdr, idx_pip, invoked);
         } else if (to_segment_idx_pip_COPY.apply().hit) {
           bit<1> invoked = 0;
           check_nak(hdr, idx_ns, idx_pip, invoked);
           if (1 == invoked) {drop(); exit;}
           check_ack(hdr, idx_pip, invoked);
           if (1 == invoked) {drop(); exit;}
         }
