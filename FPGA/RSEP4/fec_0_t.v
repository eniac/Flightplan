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
// Xilinx SDNet Compiler version 2017.3, build 2042299
//----------------------------------------------------------------------------
/*

*/

`timescale 1 ps / 1 ps

module fec_0_t (
	clk_line,
	rst,
	tuple_in_fec_input_VALID,
	tuple_in_fec_input_DATA,
	tuple_out_fec_output_VALID,
	tuple_out_fec_output_DATA
);

input clk_line /* unused */ ;
(* polarity = "high" *) input rst /* unused */ ;
input tuple_in_fec_input_VALID /* unused */ ;
input [409:0] tuple_in_fec_input_DATA /* unused */ ;
output tuple_out_fec_output_VALID /* undriven */ ;
output [367:0] tuple_out_fec_output_DATA /* undriven */ ;

wire tuple_out_fec_output_VALID /* undriven */ ;
wire [367:0] tuple_out_fec_output_DATA /* undriven */ ;




/* Tuple format for input: tuple_in_fec_input
 	[409:409]	: stateful_valid_0
	[408:401]	: operation
	[400:369]	: index
	[368:368]	: is_parity
	[367:0]	: packet

*/




/* Tuple format for output: tuple_out_fec_output
 	[367:0]	: result_0

*/

RSE_core Core
(
  .ap_clk(clk_line),
  .ap_rst(rst),
  .ap_start(start),
  .ap_done(done),
  .ap_idle(idle),
  .ap_ready(ready),
  .operation(tuple_in_fec_input[408:401]),
  .index(tuple_in_fec_input[400:369]),
  .is_parity(tuple_in_fec_input[368]),
  .data(tuple_in_fec_input[367:0]),
  .parity(tuple_out_fec_output),
  .parity_ap_vld(tuple_out_fec_output_VALID)
);

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/01/25 19:58:14
// by Barista HDL generation library, version TRUNK @ 1007984

