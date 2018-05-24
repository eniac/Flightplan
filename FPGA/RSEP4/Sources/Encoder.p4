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

#include "Memcached_headers.p4"

// We need at least space for one packet or the encoder will deadlock.
@Xilinx_MaxLatency(200)
extern void fec(in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
    out bit<FEC_PACKET_INDEX_WIDTH> packet_index);

typedef bit<48> MacAddress;

header eth_h
{
	MacAddress	dst;
	MacAddress	src;
	bit<16>		type;
}

header fec_h
{
	bit<FEC_TRAFFIC_CLASS_WIDTH>	traffic_class;
	bit<FEC_BLOCK_INDEX_WIDTH>	block_index;
	bit<FEC_PACKET_INDEX_WIDTH>	packet_index;
	bit<16>				original_type;
}

struct headers_t {
	eth_h	eth;
	fec_h	fec;

	ipv4_t	ipv4;
	udp_h	udp;
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
parser Parser(packet_in pkt, out headers_t hdr)
{
	state start
	{
		pkt.extract(hdr.eth);
		transition select(hdr.eth.type) {
			ETHERTYPE_IPV4  : parse_ipv4;
			default : accept;
		}
	}

	state parse_ipv4 {
		pkt.extract(hdr.ipv4);
		transition select(hdr.ipv4.protocol) {
			PROTOCOL_UDP : parse_udp;
			default : accept;
		}
	}

	state parse_udp {
		pkt.extract(hdr.udp);
		transition accept;
	}
}

control Update(inout headers_t hdr, inout switch_metadata_t ioports)
{
	bit<FEC_K_WIDTH>		k;
	bit<FEC_K_WIDTH>		h;

	apply
	{
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

		fec(k, h, hdr.fec.packet_index);
	}
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
control Deparser(in headers_t hdr, packet_out pkt) {
	apply
	{
		pkt.emit(hdr.eth);
		pkt.emit(hdr.fec);

		pkt.emit(hdr.ipv4);
		pkt.emit(hdr.udp);
	}
}

#include "Memcached.p4"

XilinxSwitch(Parser(), CheckCache(), /* FIXME disabled Update(),*/ Deparser()) main;

