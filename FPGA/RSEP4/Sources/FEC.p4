// We need at least space for one packet or the encoder will deadlock.
@Xilinx_MaxLatency(200)
extern void fec_encode(in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
    out bit<FEC_PACKET_INDEX_WIDTH> packet_index);

action early_classifier (inout headers_t hdr, out bit<FEC_K_WIDTH> k, out bit<FEC_H_WIDTH> h) {
	if ((hdr.eth.src & 3) == 0)
	{
		hdr.fec.traffic_class = 0;
		k = 5;
		h = 1;
	}
	else if ((hdr.eth.src & 3) == 1)
	{
		hdr.fec.traffic_class = 1;
		k = 50;
		h = 1;
	}
	else
	{
		hdr.fec.traffic_class = 2;
		k = 50;
		h = 5;
	}

	hdr.fec.original_type = hdr.eth.type;
	hdr.fec.block_index = 0;
	hdr.fec.setValid();
	hdr.eth.type = 0x81C;
}

control Update(inout headers_t hdr, inout switch_metadata_t ioports)
{
	bit<FEC_K_WIDTH>		k;
	bit<FEC_H_WIDTH>		h;

	apply
	{
                early_classifier (hdr, k, h);

		fec_encode(k, h, hdr.fec.packet_index);
	}
}

//XilinxSwitch(Parser(), Update(), Deparser()) main;

control Encode(inout headers_t hdr, inout switch_metadata_t ctrl) {
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
      actions = { classify; zero_class/*NoAction*/; }
      size = 64; // FIXME fudge
      default_action = zero_class/*NoAction*/;
/* NOTE not supported by SDNet
      const entries = {
        (0x0800, 17 ) : classify(1);
        (0x0800, 6 )  : classify(2);
        (0x0800, _ )  : classify(3);
        (_, _ )       : classify(4);
      }
*/
    }
    bit<FEC_H_WIDTH> h = 0;

    action link_status (bit<FEC_H_WIDTH> status) {
      h = status;
    }

    apply {
      if (h > 0) {
        type_and_proto = hdr.eth.type ++ hdr.ipv4.proto;
        classification.apply();
        hdr.fec.setValid();

        get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index); // FIXME should manage its own timer

        fec_encode(5/*FIXME const*/, h, hdr.fec.packet_index);
      }
    }
}
