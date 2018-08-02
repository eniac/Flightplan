#ifndef LLDP_P4_
#define LLDP_P4_
#include "Parsing.p4"
#include "targets.h"

@Xilinx_MaxLatency(100) // FIXME fudge
extern void set_port_status(in bit<PORT_SIZE> port_number);
@Xilinx_MaxLatency(100) // FIXME fudge
extern void get_port_status(in bit<PORT_SIZE> port_number, out bit<1> faulty);

control FECController(inout headers_t hdr, in metadata_t smd, out bit<1> acted) {

    apply {
        acted = 0;
        if (hdr.lldp_tlv_chassis_id.isValid()) {
            if (hdr.lldp_activate_fec.isValid()) {
                set_port_status(smd.ingress_port);
                mark_to_drop();
            }
            acted = 1;
        }
    }
}

#endif // LLDP_P4_
