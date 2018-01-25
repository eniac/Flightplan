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

typedef bit<48>     MacAddress;
typedef bit<32>     IPv4Address;
typedef bit<128>    IPv6Address;


header ethernet_h {
    MacAddress          dst;
    MacAddress          src;
    bit<16>             type;
}

header ipv4_h {
    bit<4>              version;
    bit<4>              ihl;
    bit<8>              tos;
    bit<16>             len;
    bit<16>             id;
    bit<3>              flags;
    bit<13>             frag;
    bit<8>              ttl;
    bit<8>              proto;
    bit<16>             chksum;
    IPv4Address         src;
    IPv4Address         dst;
}

header ipv6_h {
    bit<4>              version;
    bit<8>              tc;
    bit<20>             fl;
    bit<16>             plen;
    bit<8>              nh;
    bit<8>              hl;
    IPv6Address         src;
    IPv6Address         dst;
}

header tcp_h {
    bit<16>             sport;
    bit<16>             dport;
    bit<32>             seq;
    bit<32>             ack;
    bit<4>              dataofs;
    bit<4>              reserved;
    bit<8>              flags;
    bit<16>             window;
    bit<16>             chksum;
    bit<16>             urgptr;
}

header udp_h {
    bit<16>             sport;
    bit<16>             dport;
    bit<16>             len;
    bit<16>             chksum;
}



struct headers_t {
    ethernet_h          ethernet;
    ipv4_h              ipv4;
    ipv6_h              ipv6;
    tcp_h               tcp;
    udp_h               udp;
}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
parser Parser(packet_in pkt, out headers_t hdr) {

    state start {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.type) {
            0x0800  : parse_ipv4;
            0x86DD  : parse_ipv6;
            default : accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.proto) {
            6       : parse_tcp;
            17      : parse_udp;
            default : accept;
        }
    }

    state parse_ipv6 {
        pkt.extract(hdr.ipv6);
        transition select(hdr.ipv6.nh) {
            6       : parse_tcp;
            17      : parse_udp;
            default : accept;
        }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        transition accept;
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        transition accept;
    }
}

extern void get_const(in bit<4> wtf, out bit<4> num);

control Forward(inout headers_t hdr, inout switch_metadata_t nonsense) {
    action forwardPacket(in bit<4> theversion) {
		hdr.ipv4.version = theversion;
    }

	action dropPacket() {
	}

    apply {
		dropPacket();
    }

}

@Xilinx_MaxPacketRegion(1518*8)  // in bits
control Deparser(in headers_t hdr, packet_out pkt) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.ipv6);
        pkt.emit(hdr.tcp);
        pkt.emit(hdr.udp);
    }
}

XilinxSwitch(Parser(), Forward(), Deparser()) main;
