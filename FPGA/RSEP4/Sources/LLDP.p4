/*
Traffic classification for Wharf
Nik Sultana, UPenn, April 2018
*/

#include <xilinx.p4>

// number of bits used for type-and-proto, concatenated to form key for lookup.
#define TAP_KEY_SIZE 24

// FIXME fudge -- width of port number. Must agree with width of "egress" below.
#define PORT_SIZE 12
// Modes: 0 = read, 1 = write.
@Xilinx_MaxLatency(100)
extern void port_status(in bit<1> mode, in bit<PORT_SIZE> port_number, out bit<1> faulty);

@Xilinx_MaxLatency(100) // FIXME fudge
extern void get_fec_state(in bit<FEC_TRAFFIC_CLASS_WIDTH> traffic_class, out bit<FEC_BLOCK_INDEX_WIDTH>	block_index, out bit<FEC_PACKET_INDEX_WIDTH> packet_index);


// FIXME check if setting FEC_TRAFFIC_CLASS_WIDTH==3, while allowing the match to succeed in RTL, strangely doesn't result in the action taking place (to update the fec header).

control Drop(inout headers_t hdr, inout switch_metadata_t ctrl) {
  apply {
    ctrl.egress_port = 0xF; // FIXME not portable.
  }
}

control FECControlPacket(inout headers_t hdr, inout switch_metadata_t ctrl, out bit<1> acted)
{
  Drop() drop;
  apply {
    acted = 0;

    if (hdr.lldp_tlv_chassis_id.isValid()) {
      if (hdr.lldp_activate_fec.isValid()) {
        bit<1> faulty;
        port_status(1, (bit<PORT_SIZE>/*FIXME can drop the cast?*/)ctrl.ingress_port, faulty);
        drop.apply(hdr, ctrl); // FIXME needed?
      }
      acted = 1;
    }
  }
}
