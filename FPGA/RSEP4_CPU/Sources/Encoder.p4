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
#include "v1model.p4"
#include "Configuration.h"

typedef bit<48> MacAddress;

struct  booster_metadata_t {
}

header eth_h
{
	MacAddress	dst;
	MacAddress	src;
	bit<16>		type;
}

typedef bit<FEC_TRAFFIC_CLASS_WIDTH> TClass;
typedef bit<FEC_BLOCK_INDEX_WIDTH> BIndex;
typedef bit<FEC_PACKET_INDEX_WIDTH> PIndex;

header fec_h
{
    TClass traffic_class;
    BIndex block_index;
    PIndex packet_index;
    bit<16> orig_ethertype;
}

header ipv4_h {
  	bit<4>   version;
  	bit<4>   ihl;
  	bit<8>   tos;
  	bit<16>  len;
  	bit<16>  id;
  	bit<3>   flags;
  	bit<13>  frag;
  	bit<8>   ttl;
  	bit<8>   proto;
  	bit<16>  chksum;
  	bit<32>  src;
  	bit<32>  dst;
}

header tcp_h {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_h {
	bit<16> srcPort;
	bit<16> dstPort;
    bit<16> len;
    bit<16> checksum;
}

header_union protocol_h {
    tcp_h tcp;
    udp_h udp;
}

struct headers_t {
	eth_h	eth;
	fec_h	fec;
    ipv4_h  ipv4;
    protocol_h protocol;
}

#define ETHERTYPE_IPv4 0x0800
#define ETHERTYPE_WHARF 0x081C
#define TCP_PROTOCOL 0x06
#define UDP_PROTOCOL 0x11

extern void get_fec_state(in TClass class, out BIndex block_index, out PIndex packet_index);
extern void fec_encode(in eth_h eth, in ipv4_h ip, in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h);

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
parser FecParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd)
{
    state start {
        transition parse_eth;
    }

    state parse_eth {
        pkt.extract(hdr.eth);
        transition select(hdr.eth.type) {
            ETHERTYPE_IPv4 : parse_ipv4;
            default : accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
        // For now, not worrying about tcp/udp
        /*
        transition select(hdr.ipv4.proto) {
            TCP_PROTOCOL : parse_tcp;
            UDP_PROTOCOL: parse_udp;
            default: accept;
        }
        */
    }

    state parse_tcp {
        pkt.extract(hdr.protocol.tcp);
        transition accept;
    }

    state parse_udp {
        pkt.extract(hdr.protocol.udp);
        transition accept;
    }
}

control NullVerifyCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

control FecProcess(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    bit<FEC_K_WIDTH> k;
    bit<FEC_H_WIDTH> h;
    bit<8> test;

    action drop() {
        mark_to_drop();
    }

    action classify(TClass traffic_class) {
        hdr.fec.setValid();
        hdr.fec.traffic_class = traffic_class;
        k = 5;
        h = 1;
    }

    table classification {
        key = {
            hdr.ipv4.proto : exact;
        }

        actions = { classify; NoAction; }
        default_action = NoAction;

        const entries = {
            TCP_PROTOCOL : classify(0);
            UDP_PROTOCOL : classify(0);
        }
    }

    action set_egress(bit<9> port) {
        smd.egress_spec = port;
    }

    table forward {
        key = {
            smd.ingress_port : exact;
        }
        actions = { set_egress; NoAction; }
        default_action = NoAction;

        const entries = {
            1 : set_egress(2);
            2 : set_egress(1);
        }
    }

    apply {
        if (!hdr.eth.isValid()) {
            mark_to_drop();
            return;
        }
        classification.apply();
        forward.apply();
        if (hdr.fec.isValid()) {
            get_fec_state(hdr.fec.traffic_class, hdr.fec.block_index, hdr.fec.packet_index);
            fec_encode(hdr.eth, hdr.ipv4, hdr.fec, k, h);
            hdr.fec.orig_ethertype = hdr.eth.type;
            hdr.eth.type = ETHERTYPE_WHARF;
            hdr.eth.setValid();
        }
    }
}

control NullEgress(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    apply {}
}

control NullCompCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

@Xilinx_MaxPacketRegion(FEC_MAX_PACKET_SIZE * 8)
control FecDeparser(packet_out pkt, in headers_t hdr) {
	apply
	{
		pkt.emit(hdr.eth);
        pkt.emit(hdr.fec);
        pkt.emit(hdr.ipv4);
        //pkt.emit(hdr.protocol.tcp);
        //pkt.emit(hdr.protocol.udp);
	}
}

V1Switch(FecParser(), NullVerifyCheck(), FecProcess(), NullEgress(), NullCompCheck(), FecDeparser()) main;

