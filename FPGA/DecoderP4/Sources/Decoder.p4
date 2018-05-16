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

#include "Configuration.h"

@Xilinx_MaxLatency(200)
extern void Decoder(in bit<FEC_K_WIDTH> k,
    in bit<FEC_TRAFFIC_CLASS_WIDTH> traffic_class,
    in bit<FEC_BLOCK_INDEX_WIDTH> block_index,
    in bit<FEC_PACKET_INDEX_WIDTH> packet_index,
    out bit<FEC_K_WIDTH> packet_count);

typedef bit<48> MacAddress;

header eth_h
{
	MacAddress			dst;
	MacAddress			src;
	bit<FEC_ETHER_TYPE_WIDTH>	type;
}

header fec_h
{
	bit<FEC_TRAFFIC_CLASS_WIDTH>	traffic_class;
	bit<FEC_BLOCK_INDEX_WIDTH>	block_index;
	bit<FEC_PACKET_INDEX_WIDTH>	packet_index;
	bit<FEC_ETHER_TYPE_WIDTH>	original_type;
}

struct headers_t {
	eth_h	eth;
	fec_h	fec;
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
parser Parser(packet_in pkt, out headers_t hdr)
{
	state start
	{
		pkt.extract(hdr.eth);
		pkt.extract(hdr.fec);
	        transition accept;
        }
}

control Update(inout headers_t hdr, inout switch_metadata_t ioports)
{
	bit<FEC_K_WIDTH> k;
	bit<FEC_H_WIDTH> h;
	bit<FEC_K_WIDTH> packet_count;

	apply
	{
		if (hdr.eth.type == 0x81C)
		{
			hdr.eth.type = hdr.fec.original_type;

			if (hdr.fec.traffic_class == 0)
			{
				k = 5;
				h = 1;
			}
			else if (hdr.fec.traffic_class == 1)
			{
				k = 50;
				h = 1;
			}
			else
			{
				k = 50;
				h = 5;
			}

		        Decoder(k, hdr.fec.traffic_class, hdr.fec.block_index,
		                hdr.fec.packet_index, packet_count);
		}
	}
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
control Deparser(in headers_t hdr, packet_out pkt) {
	apply
	{
		pkt.emit(hdr.eth);
	}
}

XilinxSwitch(Parser(), Update(), Deparser()) main;

