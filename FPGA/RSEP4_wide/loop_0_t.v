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

module loop_0_t (
	clk_line,
	rst,
	tuple_in_loop_input_VALID,
	tuple_in_loop_input_DATA,
	tuple_out_loop_output_VALID,
	tuple_out_loop_output_DATA
);

input clk_line /* unused */ ;
(* polarity = "high" *) input rst /* unused */ ;
input tuple_in_loop_input_VALID /* unused */ ;
input [64:0] tuple_in_loop_input_DATA /* unused */ ;
output tuple_out_loop_output_VALID /* undriven */ ;
output [31:0] tuple_out_loop_output_DATA /* undriven */ ;

reg tuple_out_loop_output_VALID /* undriven */ ;
reg [31:0] tuple_out_loop_output_DATA /* undriven */ ;




/* Tuple format for input: tuple_in_loop_input
 	[64:64]	: stateful_valid_0
	[63:32]	: addr
	[31:0]	: max

*/




/* Tuple format for output: tuple_out_loop_output
 	[31:0]	: result_0

*/

reg [31:0] regs [99:0];
wire valid;
wire [31:0] addr;
wire [31:0] max;

integer i;

assign valid = tuple_in_loop_input_DATA[64];
assign addr  = tuple_in_loop_input_DATA[63:32];
assign max   = tuple_in_loop_input_DATA[31:0];

always @( posedge clk_line ) begin
	if ( rst ) begin
		for( i = 0; i < 100; i = i + 1 ) begin
        	        regs[i] <= 0;
        	end
	end
	else  begin
		if (valid == 1 && tuple_in_loop_input_VALID == 1) begin
			tuple_out_loop_output_VALID <= 1;
			tuple_out_loop_output_DATA <= regs[addr];
			if (regs[addr] + 1 < max) begin
				regs[addr] <= regs[addr] + 1;
			end
			else  begin
				regs[addr] = 0;						
			end
		end
		else  begin
			tuple_out_loop_output_VALID <= 0;
		end
	end
end

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/01/26 14:43:34
// by Barista HDL generation library, version TRUNK @ 1007984

