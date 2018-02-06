//----------------------------------------------------------------------------
//   This file is owned and controlled by Xilinx and must be used solely    //
//   for design, simulation, implementation and creation of design files    //
//   limited to Xilinx devices or technologies. Use with non-Xilinx         //
//   devices or technologies is expressly prohibited and immediately        //
//   terminates your license.                                               //
//                                                                          //
//   XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY   //
//   FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY   //
//   PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE            //
//   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS     //
//   MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY     //
//   CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY      //
//   RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY      //
//   DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE  //
//   IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         //
//   REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        //
//   INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A  //
//   PARTICULAR PURPOSE.                                                    //
//                                                                          //
//   Xilinx products are not intended for use in life support appliances,   //
//   devices, or systems.  Use in such applications are expressly           //
//   prohibited.                                                            //
//                                                                          //
//   (c) Copyright 1995-2016 Xilinx, Inc.                                   //
//   All rights reserved.                                                   //
//----------------------------------------------------------------------------

/*[TODO]
	- length info after encoded pkt
*/

#define STREAM_INTERFACE

#include "xilinx.p4"
#include "extern.p4"

#define FEC_IN_PORT 0x4
#define PACE_IN_PORT 0xE
#define FEEDBACK_IN_PORT 0x3
#define IGNORE_IN_PORT 0xC

#define DROP_E_PORT 0xF
#define FEEDBACK_E_PORT 0xE
#define DUPBACK_E_PORT 0xD

/* 2's power ns per recovery */
#define BURST_RECOVERY_INTV 8
/* points per recovery */
#define BURST_RECOVERY_RATE 10
#define BURST_MAX_POINT 10000

typedef bit<48>     MacAddress;

header veth_h {
    MacAddress          dst;
    MacAddress          src;
    bit<1>             	vx;
    bit<15>             type;
}

/*
header eth_h {
    MacAddress          dst;
    MacAddress          src;
    bit<16>             type;
}
*/

header vid_h {
	bit<24>				id;
}

header payload_h{
	bit<FEC_PAYLOAD_SIZE> data;
}

header encoded_payload_h{
	bit<FEC_PACKET_SIZE> data;
}

/* for passing global states between control blocks
	NOT for forwarding */
header state_h{
	bit<1> dummy;
	bit<1> encoded;
	bit<1> fec_data;
}

struct headers_t {
    veth_h         		veth;
	vid_h 				vid;
//	payload_h			payload;
//	encoded_payload_h	encoded_payload;
	state_h 			state;
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
parser Parser(packet_in pkt, out headers_t hdr) {

    state start {
        pkt.extract(hdr.veth);
        transition select(hdr.veth.vx) {
            0  : extract_payload;
            1  : parse_veth;
            default : accept;
        }
    }

    state parse_veth {
        transition extract_encoded_payload;
    }

	state extract_payload {
//		pkt.extract(hdr.payload);
        transition accept;
	}

	state extract_encoded_payload {
//		pkt.extract(hdr.encoded_payload);
        transition accept;
	}
}

control Forward(inout headers_t hdr, inout switch_metadata_t ioports) {

	bit<32> time;
	bit<24> id_pending;
	bit<1> dummy;
	bit<32> i;
	bit<32> j;
	bit<32> k;
	bit<32> l;
	bit<1> r;

//	bit<FEC_PACKET_SIZE> pkt_in;
//	bit<FEC_PACKET_SIZE> pkt_out;
	bit<32> index;
	bit<32> max;
	bit<32> index_new;
	bit<1> parity;
	bit<32> addr;
	bit<1> do_encode;
	bit<1> do_decode;
	bit<1> do_prepare_encoding;
	bit<1> do_prepare_decoding;
	bit<1> do_get_encoded;
	bit<1> do_get_decoded;

	bit<8> op;

    apply {

		hdr.state.encoded = 0;
		hdr.state.fec_data = 0;
		do_encode = 0;
		do_decode = 0;
		do_prepare_encoding = 0;
		do_prepare_decoding = 0;
		do_get_encoded = 0;
		do_get_decoded = 0;
		parity = 0;
		op = 0;
//		pkt_in = 0;

		addr = 0;
		max = 0;
		if (hdr.veth.vx == 0)
		{
			op = OP_ENCODE_PACKET;
			addr = 1;
			max = FEC_QUEUE_NUMBER;
		}
		else
		{
			op = OP_GET_ENCODED;
			addr = 2;
			max = FEC_PARITY_NUMBER;
		}

		index = loop(addr, max);
		index_new = index;

		if (hdr.veth.vx == 0)
		{
			/* Encode */
			/*
			pkt_in = (bit<FEC_PACKET_SIZE>)hdr.payload.data;
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.dst) << (FEC_PAYLOAD_SIZE+48+16));
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.src) << (FEC_PAYLOAD_SIZE+16));
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.vx) << (FEC_PAYLOAD_SIZE+15));
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.type) << (FEC_PAYLOAD_SIZE));
			*/

			if (index == 0)
				op = op | OP_START_ENCODER;

			hdr.veth.vx = 1;
//			hdr.vid.id = (bit<24>)(hdr.veth.dst) & VID_MASK;
			hdr.vid.id = (bit<24>)index;
			hdr.state.fec_data = 1;
			index_new = index + 1;

			if (index_new >= FEC_QUEUE_NUMBER)
			{
				index_new = 0;
				ioports.egress_port = DUPBACK_E_PORT;
				hdr.veth.vx = 1;
				hdr.state.encoded = 0;
			}
			
		}
		else 
		{
			/* send encoded */
			do_get_encoded = 1;

			index = index + FEC_QUEUE_NUMBER;

			index_new = index + 1;

			if (index_new == FEC_QUEUE_NUMBER + FEC_PARITY_NUMBER)
			{
				index_new = 0;
			}
			else
			{
				ioports.egress_port = DUPBACK_E_PORT;
			}

			hdr.state.encoded = 1;
			hdr.veth.vx = 1;
			hdr.vid.id = (bit<24>)(hdr.veth.dst) & VID_MASK;
//				if (parity == 1)
			{
				hdr.vid.id = hdr.vid.id | PARITY_FLAG;
			}

		}

		hdr.state.dummy = fec(op, index);

		if (op == OP_GET_ENCODED)
		{
//			hdr.encoded_payload.data = pkt_out;
		}
    }
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
control Deparser(in headers_t hdr, packet_out pkt) {
    apply {
        pkt.emit(hdr.veth);

		if (hdr.veth.vx == 1)
		{
			pkt.emit(hdr.vid);
		}

		if (hdr.state.fec_data == 1)
		{
			pkt.emit(hdr.veth);
		}

		if (hdr.state.encoded == 1)
		{
//			pkt.emit(hdr.encoded_payload);
		}
		else
		{
//			pkt.emit(hdr.payload);
		}
    }
}

XilinxSwitch(Parser(), Forward(), Deparser()) main;

