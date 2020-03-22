/*
Flightplan runtime support -- headerless
Nik Sultana, UPenn, March 2020
*/

    bit<SEGMENT_DESC_SIZE> fp_to_segment = 0;

    action have_hit(bit<1> hit) {}

    action set_offload_port(bit<SEGMENT_DESC_SIZE> to_segment, bit<V1S_WIDTH_PORT_NUMBER> port) {
        fp_to_segment = to_segment;
        meta.egress_spec = port;
    }

    table offload_port_lookup {
        key = {
            meta.ingress_port : exact;
        }
        actions = {
            set_offload_port;
            NoAction;
        }
    }

    table ingress_offload_port_lookup {
        key = {
            meta.ingress_port : exact;
        }
        actions = {
            set_offload_port;
            NoAction;
        }
    }

    table egress_offload_port_lookup {
        key = {
            meta.egress_spec : exact;
        }
        actions = {
            set_offload_port;
            NoAction;
        }
    }

    table egress_terminal_lookup {
        key = {
            meta.ingress_port : exact;
        }
        actions = {
            have_hit;
            NoAction;
        }
    }

    table terminal_lookup {
        key = {
            meta.ingress_port : exact;
        }
        actions = {
            set_offload_port;
            NoAction;
        }
    }
