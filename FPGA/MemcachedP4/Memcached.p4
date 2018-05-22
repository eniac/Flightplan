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
typedef bit<48> MacAddress;
typedef bit<32> Ipv4Address;
header eth_t
{
	MacAddress	dst;
	MacAddress	src;
	bit<16>		EtherType;
}

header ipv4_t{
	bit<4> version;
	bit<4> ihl;
	bit<8> diffserv;
	bit<16> totallen;
	bit<16> identification;
	bit<3> flags;
	bit<13> fragoffset;
	bit<8> ttl;
	bit<8> protocol;
	bit<16> hdrchecksum;
	Ipv4Address srcAddr;
	Ipv4Address dstAddr;	
}
header udp_h{
	bit<16> sport;
	bit<16> dport;
	bit<16> len;
	bit<16> chksum;
}
header mem_h{
	bit<4> command;
}
struct headers_t{
	eth_t	eth;
	ipv4_t	ipv4;
	udp_h	udp;
	mem_h	mem;
}
@Xilinx_MaxPacketRegion(8192)
parser Parser(packet_in pkt, out headers_t hdr){
	state start {
		pkt.extract(hdr.eth);
		transition parse_ipv4;

	}
	state parse_ipv4{
		pkt.extract(hdr.ipv4);
		transition parse_udp;
	}
	state parse_udp{
		pkt.extract(hdr.udp);
		transition accept;
	}


}
control Forward(inout headers_t hdr, inout switch_metadata_t ioports)
{
	apply {
		hdr.mem.command = 15;
		hdr.mem.setValid();
	}
}


@Xilinx_MaxPacketRegion(8192)
control Deparser(in headers_t hdr, packet_out pkt) {
	apply {
		pkt.emit(hdr.eth);
		pkt.emit(hdr.ipv4);
		pkt.emit(hdr.udp);
		pkt.emit(hdr.mem);
	}
} 
XilinxSwitch(Parser(),Forward(),Deparser()) main;
