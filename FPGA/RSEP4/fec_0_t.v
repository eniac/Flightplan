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
	packet_in_packet_in_SOF,
	packet_in_packet_in_EOF,
	packet_in_packet_in_VAL,
	packet_in_packet_in_RDY,
	packet_in_packet_in_DAT,
	packet_in_packet_in_CNT,
	packet_in_packet_in_ERR,
	packet_out_packet_out_SOF,
	packet_out_packet_out_EOF,
	packet_out_packet_out_VAL,
	packet_out_packet_out_RDY,
	packet_out_packet_out_DAT,
	packet_out_packet_out_CNT,
	packet_out_packet_out_ERR,
	tuple_in_control_VALID,
	tuple_in_control_DATA,
	tuple_out_control_VALID,
	tuple_out_control_DATA,
	tuple_in_fec_input_VALID,
	tuple_in_fec_input_DATA,
	tuple_out_fec_output_VALID,
	tuple_out_fec_output_DATA
);

input clk_line /* unused */ ;
(* polarity = "high" *) input rst /* unused */ ;
input packet_in_packet_in_SOF /* unused */ ;
input packet_in_packet_in_EOF /* unused */ ;
input packet_in_packet_in_VAL /* unused */ ;
output packet_in_packet_in_RDY /* undriven */ ;
input [63:0] packet_in_packet_in_DAT /* unused */ ;
input [3:0] packet_in_packet_in_CNT /* unused */ ;
input packet_in_packet_in_ERR /* unused */ ;
output packet_out_packet_out_SOF /* undriven */ ;
output packet_out_packet_out_EOF /* undriven */ ;
output packet_out_packet_out_VAL /* undriven */ ;
input packet_out_packet_out_RDY /* unused */ ;
output [63:0] packet_out_packet_out_DAT /* undriven */ ;
output [3:0] packet_out_packet_out_CNT /* undriven */ ;
output packet_out_packet_out_ERR /* undriven */ ;
input tuple_in_control_VALID /* unused */ ;
input [22:0] tuple_in_control_DATA /* unused */ ;
output tuple_out_control_VALID /* undriven */ ;
output [22:0] tuple_out_control_DATA /* undriven */ ;
input tuple_in_fec_input_VALID /* unused */ ;
input [40:0] tuple_in_fec_input_DATA /* unused */ ;
output tuple_out_fec_output_VALID /* undriven */ ;
output tuple_out_fec_output_DATA /* undriven */ ;

wire packet_in_packet_in_RDY /* undriven */ ;
wire packet_out_packet_out_SOF /* undriven */ ;
wire packet_out_packet_out_EOF /* undriven */ ;
wire packet_out_packet_out_VAL /* undriven */ ;
wire [63:0] packet_out_packet_out_DAT /* undriven */ ;
wire [3:0] packet_out_packet_out_CNT /* undriven */ ;
wire packet_out_packet_out_ERR /* undriven */ ;
wire tuple_out_control_VALID /* undriven */ ;
wire [22:0] tuple_out_control_DATA /* undriven */ ;
wire tuple_out_fec_output_VALID /* undriven */ ;
wire tuple_out_fec_output_DATA /* undriven */ ;

wire Start;
wire Done;
wire Idle;
wire Ready;
wire [70:0] Data;
wire [70:0] Parity;

assign Start = tuple_in_fec_input_VALID & tuple_in_fec_input_DATA[40];
assign Data = {packet_in_packet_in_SOF, packet_in_packet_in_EOF, packet_in_packet_in_DAT,
               packet_in_packet_in_CNT, packet_in_packet_in_ERR};
assign Parity = {packet_out_packet_out_SOF, packet_out_packet_out_EOF, packet_out_packet_out_DAT,
                 packet_out_packet_out_CNT, packet_out_packet_out_ERR};

/* Tuple format for input: tuple_in_fec_input
 	[40:40]	: stateful_valid
	[39:32]	: operation
	[31:0]	: index

*/

/* Tuple format for output: tuple_out_fec_output
 	[0:0]	: result

*/

RSE_core Core
(
  .ap_clk(clk_line),
  .ap_rst(rst),
  .ap_start(Start),
  .ap_done(Done),
  .ap_idle(Idle),
  .ap_ready(Ready),
  .Operation(tuple_in_fec_input_DATA[39:32]),
  .Index(tuple_in_fec_input_DATA[31:0]),
  .Data(Data),
  .Data_ap_vld(packet_in_packet_in_VAL),
  .Data_ap_ack(packet_in_packet_in_RDY),
  .Parity(Parity),
  .Parity_ap_vld(packet_out_packet_out_VAL),
  .Parity_ap_ack(packet_out_packet_out_RDY)
);

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/02/02 15:59:25
// by Barista HDL generation library, version TRUNK @ 1007984

