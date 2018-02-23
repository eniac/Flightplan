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

typedef bit<48> MacAddress;

header eth_h
{
	MacAddress	dst;
	MacAddress	src;
	bit<1>		encoded;
	bit<15>		type;
}

header fec_h
{
	bit<1>				parity;
	bit<FEC_BLOCK_INDEX_WIDTH>	block_index;
	bit<FEC_PACKET_INDEX_WIDTH>	packet_index;
}

header x_h
{
	bit<1>	dummy;
}

struct headers_t {
	eth_h	eth;
	fec_h	fec;
	x_h	x;
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)  // in bits
parser Parser(packet_in pkt, out headers_t hdr)
{
	state start
	{
		pkt.extract(hdr.eth);
		transition select(hdr.eth.encoded)
		{
			0       : accept;
			1       : parse_fec;
			default : accept;
	        }
	}

	state parse_fec
	{
		pkt.extract(hdr.fec);
	        transition accept;
	}
}

control Forward(inout headers_t hdr, inout switch_metadata_t ioports)
{
	bit<FEC_PACKET_INDEX_WIDTH>	index;
	bit<FEC_PACKET_INDEX_WIDTH>	max;
	bit<FEC_OFFSET_WIDTH>		payload_offset;
	bit<FEC_REG_ADDR_WIDTH>		reg_addr;
	bit<FEC_OP_WIDTH>		op;

	apply
	{
		op = 0;
		reg_addr = 0;
		max = 0;

		if (hdr.eth.encoded == 0)
		{
			op = FEC_OP_ENCODE_PACKET;
			reg_addr = 0;
			max = FEC_K;
			payload_offset = FEC_ETH_HEADER_SIZE;
		}
		else
		{
			op = FEC_OP_GET_ENCODED;
			reg_addr = 1;
			max = FEC_H;
			payload_offset = FEC_ETH_HEADER_SIZE + FEC_HEADER_SIZE;
		}

		index = loop(reg_addr, max);

		hdr.fec.block_index = 0;
		hdr.fec.packet_index = (bit<FEC_PACKET_INDEX_WIDTH>) index;

		if (hdr.eth.encoded == 0)
		{
			/* Encode */

			if (index == 0)
			{
				op = op | FEC_OP_START_ENCODER;
			}
			
			hdr.fec.parity = 0;
			hdr.eth.encoded = 1;
		}
		else 
		{
			/* send encoded */
			index = index + FEC_K;

			hdr.fec.parity = 1;
		}

		if (index < FEC_H)
		{
			ioports.egress_port = FEC_DUPLICATE_OUTPUT_PORT;
		}
		else
		{
			ioports.egress_port = FEC_REGULAR_OUTPUT_PORT;
		}

		hdr.fec.setValid();

		hdr.x.dummy = fec(op, index, payload_offset);

    }
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)  // in bits
control Deparser(in headers_t hdr, packet_out pkt) {
	apply
	{
		pkt.emit(hdr.eth);
		pkt.emit(hdr.fec);
	}
}

XilinxSwitch(Parser(), Forward(), Deparser()) main;

