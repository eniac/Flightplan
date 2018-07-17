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

typedef bit<48> MacAddress;

struct  booster_metadata_t {
}

header eth_h
{
	MacAddress	dst;
	MacAddress	src;
	bit<16>		type;
}
struct headers_t {
	eth_h	eth;
}

// Duplcates the packet with the string `value` (size `width`) in  location `index` of the payload
// Duplicated packet sent to deparser
extern void copy_modified(in bit<8> index, in bit<8> width, in bit<48> value);

parser SampleParser(packet_in pkt, out headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd)
{
    state start {
        transition parse_eth;
    }

    state parse_eth {
        pkt.extract(hdr.eth);
        transition accept;
    }
}

control NullVerifyCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

control SampleProcess(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    bit<8> index = 2;
    bit<8> width = 6;
    bit<48> value = 0xF00F1337F00F;

    action set_egress(bit<9> port) {
        smd.egress_spec = port;
        if (port == 1) {
            value = 0x0FF0BEEF0FF0;
        }
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
        forward.apply();
        // Copy in the modified payload and send to deparser
        copy_modified(index, width, value);
    }
}

control NullEgress(inout headers_t hdr, inout booster_metadata_t meta, inout standard_metadata_t smd) {
    apply {}
}

control NullCompCheck(inout headers_t hdr, inout booster_metadata_t meta) {
    apply {}
}

control SampleDeparser(packet_out pkt, in headers_t hdr) {
	apply
	{
		pkt.emit(hdr.eth);
	}
}

V1Switch(SampleParser(), NullVerifyCheck(), SampleProcess(), NullEgress(), NullCompCheck(), SampleDeparser()) main;

