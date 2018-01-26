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
#include "xilinx.p4"
#include "extern.p4"

#define FEC_IN_PORT 0xF
#define PACE_IN_PORT 0xE
#define FEEDBACK_IN_PORT 0xD
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
	payload_h			payload;
	encoded_payload_h	encoded_payload;
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
//        pkt.extract(hdr.vid);
        transition extract_encoded_payload;
    }

/* [TODO] find a way to do this only when necessary */
	state extract_payload {
		pkt.extract(hdr.payload);
        transition accept;
	}

	state extract_encoded_payload {
		pkt.extract(hdr.encoded_payload);
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

	bit<FEC_PACKET_SIZE> pkt_in;
	bit<FEC_PACKET_SIZE> pkt_out;
	bit<32> index;
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


	action dropPacket() {
		ioports.egress_port = DROP_E_PORT;
	}

	/* 
		FEC for HDL version; with a timer; evacuate when timeout
		assume that there are 2^4 = 16 queues;
	*/
	/*
	#define FEC_QUEUE_SIZE 8
	#define FEC_QUEUE_NUMBER 16

	// Encode
	bit<32> t;
	bit<32> t0;
	bit<4> index;
	bit<4> queue;
	bit<1> do_fec;
	bit<1> evacuated;
	{
		evacuated = 0;
		
		// read
		t = counter();
		queue = (bit<4>)t;
		t0 = readr_timer(queue);
		index = (bit<4>)readr_index(queue);

		// check timeout
		if (t0>0)
		{
			t0 = t0 - 1;
			if (t0 == 0)
			{
				evacuated = 1;
				index = 0;
				t0 = 0;
			}
		}

		// check full
		if (index == FEC_QUEUE_SIZE)
		{
			evacuated = 1;
			index = 0;
			t0 = 0;
		}

		// check do encoding
		if (do_fec)
		{
			index = index + 1;
			ioports.egress_port = DROP_E_PORT;
		}

		writer_timer(queue, t0);
		writer_index(queue, index);
		evacuate(evacuated, queue);
		fec_prepare_encoding(do_fec, fec_hdr.packet, queue, index-1);
	}

	// [TODO] Send encoded packet [?]

	// [TODO] Decode

	// [TODO] Send decoded packet

	*/

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
		pkt_in = 0;

		addr = 0;
		if (ioports.ingress_port == FEC_IN_PORT)
		{
			addr = 1;
		}
		else if (ioports.ingress_port == FEEDBACK_IN_PORT)
		{
			if (hdr.veth.vx == 1)
			{
				addr = 2;
			}
			else
			{
				addr = 3;
			}
		}
		else
		{
			if (hdr.veth.vx == 1)
			{
				addr = 4;
			}
			else
			{
				addr = 5;
			}
		}

		index = readr(addr);
		index_new = index;

		if (ioports.ingress_port == FEC_IN_PORT)
		{
			op = OP_PREPARE_ENCODING;
			/* Encode */
//			do_prepare_encoding = 1;

			pkt_in = (bit<FEC_PACKET_SIZE>)hdr.payload.data;
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.dst) << (FEC_PAYLOAD_SIZE+48+16));
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.src) << (FEC_PAYLOAD_SIZE+16));
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.vx) << (FEC_PAYLOAD_SIZE+15));
			pkt_in = pkt_in | (((bit<FEC_PACKET_SIZE>)hdr.veth.type) << (FEC_PAYLOAD_SIZE));
//			dummy = fec_prepare_encoding(do_prepare_encoding, pkt, index);
//			dummy = fec(op, index, 0, pkt);

//			hdr.state.dummy = dummy;

			hdr.veth.vx = 1;
			hdr.vid.id = (bit<24>)(hdr.veth.dst) & VID_MASK;
			hdr.state.fec_data = 1;
			index_new = index + 1;

			if (index_new >= FEC_QUEUE_NUMBER)
			{
				op = op | OP_ENCODE;

//				do_encode = 1;

//				dummy = fec_encode(do_encode);

//				hdr.state.dummy = dummy;
				index_new = 0;
				ioports.egress_port = DUPBACK_E_PORT;
				hdr.veth.vx = 1;
				hdr.state.encoded = 0;
			}
			
		}
		else if (ioports.ingress_port == FEEDBACK_IN_PORT)
		{
			/* From feedback port, send encoded/decoded packet */
			if (hdr.veth.vx == 1)
			{
				op = OP_GET_ENCODED;
				/* send encoded */
				do_get_encoded = 1;
				if (index == 0)
				{
					index = FEC_QUEUE_NUMBER;
				}

//				hdr.encoded_payload.data = fec_get_encoded(do_get_encoded, index, parity);
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
			else
			{
				op = OP_GET_DECODED;
				/* send decoded */
//				do_get_decoded = 1;
//				pkt = fec_get_decoded(do_get_decoded, index);
//				hdr.payload.data = (bit<FEC_PAYLOAD_SIZE>) pkt;
//				hdr.veth.dst = (bit<48>)(pkt >> (FEC_PAYLOAD_SIZE+48+16));
//				hdr.veth.src = (bit<48>)(pkt >> (FEC_PAYLOAD_SIZE+16));
//				hdr.veth.vx = (bit<1>)(pkt >> (FEC_PAYLOAD_SIZE+15));
//				hdr.veth.type = (bit<15>)(pkt >> (FEC_PAYLOAD_SIZE));
				hdr.state.encoded = 0;

				index_new = index + 1;

				if (index_new == FEC_QUEUE_NUMBER)
				{
					index_new = 0;
				}
				else
				{
					ioports.egress_port = DUPBACK_E_PORT;
				}

			}
		}
		else if (ioports.ingress_port == IGNORE_IN_PORT)
		{
			NoAction();
		}
		else
		{
			if (hdr.veth.vx == 1)
			{
				op = OP_PREPARE_DECODING;
				/* Decode */
//				do_prepare_decoding = 1;

				if ((hdr.vid.id & PARITY_FLAG) == 0)
				{
					parity = 0;
				}
				else
				{
					parity = 1;
				}
				pkt_in = hdr.encoded_payload.data;
//				dummy = fec_prepare_decoding(do_prepare_decoding, pkt, index, parity);
//				hdr.state.dummy = dummy;
				ioports.egress_port = DROP_E_PORT;

				index_new = index + 1;
				if (index_new >= FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER)
				{
					op = op | OP_DECODE;
//					do_decode = 1;
//					dummy = fec_decode(do_decode);
//					hdr.state.dummy = dummy;
					index_new = 0;
					ioports.egress_port = FEEDBACK_E_PORT;
					hdr.veth.vx = 0;
					hdr.state.encoded = 0;
				}
				
			}
			else
			{
				/* simply forward */
				NoAction();
			}
		}

		pkt_out = fec(op, index, parity, pkt_in);


		if (op == OP_GET_ENCODED)
		{
			hdr.encoded_payload.data = pkt_out;
		}

		if (op == OP_GET_DECODED)
		{
			hdr.encoded_payload.data = pkt_out;
			hdr.veth.dst = (bit<48>)(pkt_out >> (FEC_PAYLOAD_SIZE+48+16));
			hdr.veth.src = (bit<48>)(pkt_out >> (FEC_PAYLOAD_SIZE+16));
			hdr.veth.vx = (bit<1>)(pkt_out >> (FEC_PAYLOAD_SIZE+15));
			hdr.veth.type = (bit<15>)(pkt_out >> (FEC_PAYLOAD_SIZE));
		}
			
		dummy = writer(addr, index_new);
		hdr.state.dummy = dummy;
    }
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
control Deparser(in headers_t hdr, packet_out pkt) {
    apply {
        pkt.emit(hdr.veth);

		if (hdr.veth.vx == 1)
		{
//			pkt.emit(hdr.vid);
		}

		if (hdr.state.fec_data == 1)
		{
			pkt.emit(hdr.veth);
		}

		if (hdr.state.encoded == 1)
		{
			pkt.emit(hdr.encoded_payload);
		}
		else
		{
			pkt.emit(hdr.payload);
		}
    }
}

XilinxSwitch(Parser(), Forward(), Deparser()) main;

