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

#include "xilinx.p4"
#include "extern.p4"

#define DUPBACK_E_PORT 0xD

typedef bit<48>     MacAddress;

header veth_h {
    MacAddress          dst;
    MacAddress          src;
    bit<1>             	vx;
    bit<15>             type;
}

header vid_h {
	bit<VTAG_SIZE>			id;
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
	state_h 			state;
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
parser Parser(packet_in pkt, out headers_t hdr) {

    state start {
        pkt.extract(hdr.veth);
        transition select(hdr.veth.vx) {
			0  : accept;
            1  : parse_veth;
            default : accept;
        }
    }

    state parse_veth {
		pkt.extract(hdr.vid);
        transition accept;
    }
}

control Forward(inout headers_t hdr, inout switch_metadata_t ioports) {

	bit<REG_SIZE> index;
	bit<REG_SIZE> max;
	bit<REG_SIZE> index_new;
	bit<REG_SIZE> payload_offset;
	bit<REG_ADDR_SIZE> reg_addr;
	bit<4> op;

    apply {

		hdr.state.encoded = 0;
		hdr.state.fec_data = 0;
		op = 0;

		reg_addr = 0;
		max = 0;
		if (hdr.veth.vx == 0)
		{
			op = OP_ENCODE_PACKET;
			reg_addr = 0;
			max = FEC_QUEUE_NUMBER;
			payload_offset = ETH_HEADER_SIZE;
		}
		else
		{
			op = OP_GET_ENCODED;
			reg_addr = 1;
			max = FEC_PARITY_NUMBER;
			payload_offset = VETH_HEADER_SIZE;
		}

		index = loop(reg_addr, max);
		index_new = index;

		if (hdr.veth.vx == 0)
		{
			/* Encode */
			hdr.veth.vx = 1;
			hdr.vid.id = (bit<VTAG_SIZE>)index;
			hdr.state.fec_data = 1;
			index_new = index + 1;

			if (index == 0)
			{
				op = op | OP_START_ENCODER;
			}

			if (index < FEC_PARITY_NUMBER)
			{
				ioports.egress_port = DUPBACK_E_PORT;
			}
			
		}
		else 
		{
			/* send encoded */
			index = index + FEC_QUEUE_NUMBER;

			index_new = index + 1;

			if (index < FEC_PARITY_NUMBER)
			{
				ioports.egress_port = DUPBACK_E_PORT;
			}

			hdr.state.encoded = 1;
			hdr.veth.vx = 1;
			hdr.vid.id = (bit<VTAG_SIZE>)index;
			hdr.vid.id = hdr.vid.id | PARITY_FLAG;

		}

		hdr.state.dummy = fec(op, index, payload_offset);

    }
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
control Deparser(in headers_t hdr, packet_out pkt) {
    apply {
        pkt.emit(hdr.veth);
		pkt.emit(hdr.vid);
    }
}

XilinxSwitch(Parser(), Forward(), Deparser()) main;

