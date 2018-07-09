// We need at least space for one packet or the encoder will deadlock.
@Xilinx_MaxLatency(200)
extern void fec(in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
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

		fec(k, h, hdr.fec.packet_index);
	}
}

//XilinxSwitch(Parser(), Update(), Deparser()) main;
