#include "targets.h"
#include "Memcached_extern.p4"
#include "FEC.p4"
#include "EmptyBMDefinitions.p4"

#if defined(TARGET_BMV2)

parser BMParser(packet_in pkt, out headers_t hdr,
                inout bmv2_meta_t m, inout metadata_t meta) {
    state start {
        FecParser.apply(pkt, hdr);
        transition accept;
    }
}

control FEC_Classify(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta, in bit<24> proto_and_port) {
    action classify(tclass_t tclass) {
        hdr.fec.setValid();
        hdr.fec.traffic_class = tclass;
    }

    // NOTE adding this line sends sdnet into tailspin during RTL simulation @Xilinx_ExternallyConnected
    table classification {
        key = {
            proto_and_port : exact;
        }

        actions = {classify; NoAction;}
        size = 64; // FIXME fudge
        default_action = classify(0);
    }

    apply {
        classification.apply();
    }
}

control Process(inout headers_t hdr, inout bmv2_meta_t m, inout metadata_t meta) {
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

    bit<24> proto_and_port = 0;
    FEC_Classify() classification;

    apply {
        if (!hdr.eth.isValid()) {
            drop();
        }

        // If we received an FEC update, then update the table.
        bit<1> is_ctrl;
        FECController.apply(hdr, meta, is_ctrl);
        if (is_ctrl == 1) {
            drop();
            return;
        }

        // If lossy link, then FEC decode.
        if (hdr.fec.isValid()) {
            FecClassParams.apply(hdr.fec.traffic_class, k, h);
            hdr.eth.type = hdr.fec.orig_ethertype;
            FEC_DECODE(hdr.fec, k, h);
            if (hdr.fec.packet_index >= k) {
                drop();
            }
            hdr.fec.setInvalid();
        }

        // If multiplexed link, then header decompress.
        // TODO add code

        // If Memcached REQ/RES then pass through the cache.
        bit<1> forward = 0;
        if (hdr.udp.isValid()) {
            if (hdr.udp.dport == 11211 || hdr.udp.sport == 11211) {
                memcached(forward); // FIXME check "forward" output value.
            }
        }

        Forwarder.apply(meta);
        bit<1> faulty = 1;


        // If heading out on a multiplexed link, then header compress.
        // TODO add code

        // If heading out on a lossy link, then FEC encode.
        // TODO: Commenting out next line until lldp packets are tested
        get_port_status(meta.egress_spec, faulty);
        if (faulty == 1) {
            if (hdr.tcp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.tcp.dport;
            } else if (hdr.udp.isValid()) {
                proto_and_port = hdr.ipv4.proto ++ hdr.udp.dport;
            } else {
                proto_and_port = hdr.ipv4.proto ++ (bit<16>)0;
            }

            classification.apply(hdr, m, meta, proto_and_port);
            if (hdr.fec.isValid()) {
                FecClassParams.apply(hdr.fec.traffic_class, k, h);
                get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index);
                hdr.fec.orig_ethertype = hdr.eth.type;
                FEC_ENCODE(hdr.fec, k, h);
                hdr.eth.type = ETHERTYPE_WHARF;
            }
        }
    }
}

V1Switch(BMParser(), NoVerify(), Process(), NoEgress(), NoCheck(), FecDeparser()) main;

#else
#error Currently unsupported target
#endif
