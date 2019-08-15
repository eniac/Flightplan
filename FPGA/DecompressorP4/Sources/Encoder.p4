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

#include "hc_headers.p4"
#include "FlightplanHeader.p4"
// We need at least space for one packet or the encoder will deadlock.

typedef bit<48> MacAddress;

header eth_h
{
	MacAddress	dst;
	MacAddress	src;
	bit<16>		type;
}

struct headers_t {
	flightplan_h fph;	
	eth_h	eth;
	ipv4_t	ipv4;
	tcp_h   tcp;
	compressedHeader_h cmp;
	
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
parser Parser(packet_in pkt, out headers_t hdr)
{
        state start
        {
                pkt.extract(hdr.fph);
                transition parse_eth;
        }
	state parse_eth 
	{
		pkt.extract(hdr.eth);
		transition select(hdr.eth.type) {
			ETHERTYPE_IPV4  : parse_ipv4;
			ETHERTYPE_COMPRESS  : parse_cmp;
			default : accept;
		}
	}

	state parse_ipv4 {
		pkt.extract(hdr.ipv4);
		transition select(hdr.ipv4.protocol) {
			PROTOCOL_TCP : parse_tcp;
			default : accept;
		}
	}
	
	state parse_tcp {
		pkt.extract(hdr.tcp);
		transition accept;
	}
	state parse_cmp{
		pkt.extract(hdr.cmp);
		transition accept;
	}

}


@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
control Deparser(in headers_t hdr, packet_out pkt) {
	apply
	{
		pkt.emit(hdr.fph);
		pkt.emit(hdr.eth);
		pkt.emit(hdr.ipv4);
		pkt.emit(hdr.tcp);
	}
}

#include "decompressor.p4"

XilinxSwitch(Parser(), CheckTcp(), Deparser()) main;

