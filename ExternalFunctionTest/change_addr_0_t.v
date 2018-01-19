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

module change_addr_0_t (
	clk_line,
	rst,
	tuple_in_change_addr_input_VALID,
	tuple_in_change_addr_input_DATA,
	tuple_out_change_addr_output_VALID,
	tuple_out_change_addr_output_DATA
);

input clk_line /* unused */ ;
(* polarity = "high" *) input rst /* unused */ ;
input tuple_in_change_addr_input_VALID /* unused */ ;
input [48:0] tuple_in_change_addr_input_DATA /* unused */ ;
output tuple_out_change_addr_output_VALID /* undriven */ ;
output [47:0] tuple_out_change_addr_output_DATA /* undriven */ ;

wire tuple_out_change_addr_output_VALID /* undriven */ ;
wire [47:0] tuple_out_change_addr_output_DATA /* undriven */ ;

wire valid;

assign valid = tuple_in_change_addr_input_VALID & tuple_in_change_addr_input_DATA[48:48];

assign tuple_out_change_addr_output_VALID = valid;
assign tuple_out_change_addr_output_DATA = tuple_in_change_addr_input_DATA[47:0] + 1;

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/01/03 14:02:41
// by Barista HDL generation library, version TRUNK @ 1007984

