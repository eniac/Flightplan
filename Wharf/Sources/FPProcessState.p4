/*
Flightplan runtime support
Nik Sultana, UPenn, February 2020
*/
    bit<32> idx_ns = 0;
    bit<32> idx_pip = 0;
    bit<SEGMENT_DESC_SIZE> state_buffer;

    action set_offload_port(bit<WIDTH_PORT_NUMBER> offload_port) {
        meta.egress_spec = offload_port;
    }

    table offload_port_lookup {
        key = {
            hdr.fp.to_segment : exact;
            state_buffer : exact;
        }
        actions = {
            set_offload_port;
            NoAction;
        }
    }

    action set_idx_next_segment(bit<32> idx) {
        idx_ns = idx;
    }

    table idx_next_segment {
        key = {
            hdr.fp.to_segment : exact;
        }
        actions = {
            set_idx_next_segment;
            NoAction;
        }
    }

    table idx_next_segment_COPY {
        key = {
            hdr.fp.to_segment : exact;
        }
        actions = {
            set_idx_next_segment;
            NoAction;
        }
    }

    action set_idx_pip(bit<32> idx) {
        idx_pip = idx;
    }

    table to_segment_idx_pip {
        key = {
            hdr.fp.to_segment : exact;
        }
        actions = {
            set_idx_pip;
            NoAction;
        }
    }

    table to_segment_idx_pip_COPY {
        key = {
            hdr.fp.to_segment : exact;
        }
        actions = {
            set_idx_pip;
            NoAction;
        }
    }

    table from_segment_idx_pip {
        key = {
            hdr.fp.from_segment : exact;
            hdr.fp.to_segment : exact;
        }
        actions = {
            set_idx_pip;
            NoAction;
        }
    }
