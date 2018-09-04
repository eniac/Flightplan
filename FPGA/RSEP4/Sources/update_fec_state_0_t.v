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
//   (c) Copyright 1995-2015 Xilinx, Inc.                                   //
//   All rights reserved.                                                   //
//----------------------------------------------------------------------------
// Xilinx SDNet Compiler version 2017.4, build 2093981
//----------------------------------------------------------------------------
/*

*/

`timescale 1 ps / 1 ps

`include "Configuration.v"

`define TRAFFIC_CLASSES 3
`define INPUT_TUPLE_WIDTH `FEC_TRAFFIC_CLASS_WIDTH + `FEC_K_WIDTH + `FEC_H_WIDTH + 1
`define OUTPUT_TUPLE_WIDTH `FEC_BLOCK_INDEX_WIDTH + `FEC_PACKET_INDEX_WIDTH

module update_fec_state_0_t (
	clk_line,
	rst,
	tuple_in_update_fec_state_input_VALID,
	tuple_in_update_fec_state_input_DATA,
	tuple_out_update_fec_state_output_VALID,
	tuple_out_update_fec_state_output_DATA
);

input clk_line;
(* polarity = "high" *) input rst;
input tuple_in_update_fec_state_input_VALID;
input [`INPUT_TUPLE_WIDTH - 1:0] tuple_in_update_fec_state_input_DATA;
output tuple_out_update_fec_state_output_VALID;
output [`OUTPUT_TUPLE_WIDTH - 1:0] tuple_out_update_fec_state_output_DATA;

wire tuple_out_update_fec_state_output_VALID;
wire [`OUTPUT_TUPLE_WIDTH - 1:0] tuple_out_update_fec_state_output_DATA;

reg [`FEC_BLOCK_INDEX_WIDTH - 1 : 0]  block_indices[`TRAFFIC_CLASSES - 1 : 0];
reg [`FEC_PACKET_INDEX_WIDTH - 1 : 0] packet_indices[`TRAFFIC_CLASSES - 1 : 0];

wire                                    valid;
wire [`FEC_TRAFFIC_CLASS_WIDTH - 1 : 0] traffic_class;
wire [`FEC_K_WIDTH - 1 : 0]             k;
wire [`FEC_H_WIDTH - 1 : 0]             h;

integer i;

assign { valid, traffic_class, k, h } = tuple_in_update_fec_state_input_DATA;

always @( posedge clk_line ) begin
	if ( rst ) begin
		for ( i = 0; i < `TRAFFIC_CLASSES; i = i + 1) begin
			packet_indices[i] <= 0;
			block_indices[i] <= 0;
		end
	end
	else  if ( tuple_in_update_fec_state_input_VALID && valid ) begin
		if ( packet_indices[traffic_class] < k - 1 ) begin
			packet_indices[traffic_class] <= packet_indices[traffic_class] + 1;
		end
		else begin
			packet_indices[traffic_class] <= 0;
			block_indices[traffic_class] <= block_indices[traffic_class] + 1;
		end
	end
end

assign tuple_out_update_fec_state_output_VALID = tuple_in_update_fec_state_input_VALID;
assign tuple_out_update_fec_state_output_DATA = { block_indices[traffic_class], packet_indices[traffic_class] };

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/08/22 14:24:12
// by Barista HDL generation library, version TRUNK @ 1007984

