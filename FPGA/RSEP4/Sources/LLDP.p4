/*
Traffic classification for Wharf
Nik Sultana, UPenn, April 2018
*/

#include <xilinx.p4>

#if 0
// number of bits used for type-and-proto, concatenated to form key for lookup.
#define TAP_KEY_SIZE 24

// FIXME fudge -- width of port number. Must agree with width of "egress" below.
#define PORT_SIZE 12
// Modes: 0 = read, 1 = write.
@Xilinx_MaxLatency(100)
extern void port_status(in bit<1> mode, in bit<PORT_SIZE> port_number, out bit<1> faulty);
#endif


// FIXME check if setting FEC_TRAFFIC_CLASS_WIDTH==3, while allowing the match to succeed in RTL, strangely doesn't result in the action taking place (to update the fec header).

control Pipeline(inout headers_t hdr, inout switch_metadata_t ctrl) {
    action drop() {
      ctrl.egress_port = 0xF; // FIXME not portable.
    }

    action classify (bit<FEC_TRAFFIC_CLASS_WIDTH> traffic_class) {
      hdr.fec.setValid();
      hdr.fec.traffic_class = traffic_class;
      // NOTE block_index and packet_index will be updated downstream by get_fec_state()
      hdr.fec.block_index = /*FEC_BLOCK_INDEX_WIDTH*/5w0;
      hdr.fec.packet_index = /*FEC_PACKET_INDEX_WIDTH*/8w0;
    }

    action zero_class () {
      classify(0);
    }

    bit<TAP_KEY_SIZE> type_and_proto;

    // NOTE adding this line sends sdnet into tailspin during RTL simulation @Xilinx_ExternallyConnected
    table classification {
      key = {
        type_and_proto : exact; // FIXME ternary might make more sense
      }
      actions = { classify; /*zero_class*/NoAction; }
      size = 64; // FIXME fudge
      default_action = /*zero_class*/NoAction;
/* NOTE not supported by SDNet
      const entries = {
        (0x0800, 17 ) : classify(1);
        (0x0800, 6 )  : classify(2);
        (0x0800, _ )  : classify(3);
        (_, _ )       : classify(4);
      }
*/
    }

    bit<12> egress = 0; // NOTE 12 since to be the least width for exact-match. Ideally its type should be "switch_port_t".
    bit<4/*FIXME arbitrary*/> h = 0;

    action set_egress (switch_port_t port) {
      egress = (bit<12>)port;
    }

    table forward {
      key = {
        hdr.eth.dst : exact;
      }
      actions = { set_egress; NoAction; }
      size = 64; // FIXME fudge
      default_action = NoAction/*FIXME broadcast*/;
    }

    action link_status (bit<4/*FIXME arbitrary*/> status) {
      h = status;
    }

    apply {
      if (!hdr.eth.isValid()) {
        drop(); // FIXME needed?
        return; // FIXME or "exit"?
      }

      if (hdr.lldp_tlv_chassis_id.isValid()) {
        if (hdr.lldp_activate_fec.isValid()) {
          bit<1> faulty;
#if 0
          port_status(1, (bit<PORT_SIZE>/*FIXME can drop the cast?*/)ctrl.ingress_port, faulty);
#endif
          drop();
        }
      } else {
        forward.apply();
        bit<1> faulty;
#if 0
        port_status(0, egress, faulty);
#endif
        ctrl.egress_port = (switch_port_t)egress;

        if (!hdr.ipv4.isValid())
          return;

        if (h > 0) {
//        zero_class();
          type_and_proto = hdr.eth.type ++ hdr.ipv4.proto;
          classification.apply();
          hdr.fec.setValid();

#if 0
          get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index); // FIXME should manage its own timer?
#endif
          // FIXME hand over to Encoder
        }
      }
    }
}


XilinxSwitch(Parser(), Pipeline(), Deparser()) main;

