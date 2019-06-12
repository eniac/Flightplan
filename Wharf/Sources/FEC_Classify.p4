#include "targets.h"
#include "EmptyBMDefinitions.p4"

control FEC_Classify(inout headers_t hdr, in bit<24> proto_and_port) {
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
