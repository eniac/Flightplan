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

#include "v1model.p4"
#include "Configuration.h"

typedef bit<48> MacAddress;

struct booster_metadata_t {
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

struct headers_t {
	eth_h	eth;
	fec_h	fec;
}

#define ETHERTYPE_WHARF 0x081C

extern void fec_decode(in eth_h eth, in fec_h fec, in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h);

parser FecParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd)
{
    state start {
        transition parse_eth;
    }

    state parse_eth {
        pkt.extract(hdr.eth);
        transition select(hdr.eth.type) {
            ETHERTYPE_WHARF : parse_fec;
            default : accept;
        }
    }

    state parse_fec {
        pkt.extract(hdr.fec);
        transition accept;
    }
}

control NullVerifyCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

control FecProcess(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    bit<FEC_K_WIDTH> k = 0;
    bit<FEC_H_WIDTH> h = 0;

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

    action set_k_h(bit<FEC_K_WIDTH> k_in, bit<FEC_H_WIDTH> h_in) {
        k = k_in;
        h = h_in;
    }

    table classify {
        key = {
            hdr.fec.traffic_class : exact;
        }

        actions = { set_k_h; NoAction; }
        default_action = NoAction;

        const entries = {
            0 : set_k_h(5,1);
        }
    }

    apply {
        if (!hdr.eth.isValid()) {
            mark_to_drop();
            return;
        }
        forward.apply();
        if (hdr.fec.isValid()) {

            classify.apply();
            hdr.eth.type = hdr.fec.orig_ethertype;
            fec_decode(hdr.eth, hdr.fec, k, h);

            if (hdr.fec.packet_index >= k) {
                mark_to_drop();
                return;
            }

        }
    }
}

control NullEgress(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    apply {}
}

control NullCompCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

control FecDeparser(packet_out pkt, in headers_t hdr) {
	apply
	{
		pkt.emit(hdr.eth);
	}
}

V1Switch(FecParser(), NullVerifyCheck(), FecProcess(), NullEgress(), NullCompCheck(), FecDeparser()) main;

