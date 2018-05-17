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

// We need at least space for one packet or the encoder will deadlock.
@Xilinx_MaxLatency(200)
extern void fec(in bit<FEC_K_WIDTH> k, in bit<FEC_H_WIDTH> h,
    out bit<FEC_PACKET_INDEX_WIDTH> packet_index);

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
