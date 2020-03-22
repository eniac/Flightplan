/*
Flightplan runtime support -- headerless
Nik Sultana, UPenn, March 2020
*/
    bit<1> computation_ended = FALSE;
    bit<1> computation_continuing = FALSE;
    bit<1> computation_incoming = FALSE;

    bit<SEGMENT_DESC_SIZE> fp_original_to_segment = 0;
    bit<SEGMENT_DESC_SIZE> fp_to_segment = 0;

    action set_offload_port(bit<V1S_WIDTH_PORT_NUMBER> port) {
        meta.egress_spec = port;
    }

    table offload_port_lookup {
        key = {
            fp_to_segment : exact;
        }
        actions = {
            set_offload_port;
            NoAction;
        }
    }
