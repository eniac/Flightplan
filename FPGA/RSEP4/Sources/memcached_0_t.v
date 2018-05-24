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

module memcached_0_t (
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
	tuple_in_CheckCache_fl_VALID,
	tuple_in_CheckCache_fl_DATA,
	tuple_out_CheckCache_fl_VALID,
	tuple_out_CheckCache_fl_DATA,
	tuple_in_hdr_VALID,
	tuple_in_hdr_DATA,
	tuple_out_hdr_VALID,
	tuple_out_hdr_DATA,
	tuple_in_ioports_VALID,
	tuple_in_ioports_DATA,
	tuple_out_ioports_VALID,
	tuple_out_ioports_DATA,
	tuple_in_local_state_VALID,
	tuple_in_local_state_DATA,
	tuple_out_local_state_VALID,
	tuple_out_local_state_DATA,
	tuple_in_Parser_extracts_VALID,
	tuple_in_Parser_extracts_DATA,
	tuple_out_Parser_extracts_VALID,
	tuple_out_Parser_extracts_DATA,
	tuple_in_memcached_input_VALID,
	tuple_in_memcached_input_DATA,
	tuple_out_memcached_output_VALID,
	tuple_out_memcached_output_DATA,
	backpressure_in,
	backpressure_out
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
input [21:0] tuple_in_control_DATA /* unused */ ;
output tuple_out_control_VALID /* undriven */ ;
output [21:0] tuple_out_control_DATA /* undriven */ ;
input tuple_in_CheckCache_fl_VALID /* unused */ ;
input tuple_in_CheckCache_fl_DATA /* unused */ ;
output tuple_out_CheckCache_fl_VALID /* undriven */ ;
output tuple_out_CheckCache_fl_DATA /* undriven */ ;
input tuple_in_hdr_VALID /* unused */ ;
input [371:0] tuple_in_hdr_DATA /* unused */ ;
output tuple_out_hdr_VALID /* undriven */ ;
output [371:0] tuple_out_hdr_DATA /* undriven */ ;
input tuple_in_ioports_VALID /* unused */ ;
input [7:0] tuple_in_ioports_DATA /* unused */ ;
output tuple_out_ioports_VALID /* undriven */ ;
output [7:0] tuple_out_ioports_DATA /* undriven */ ;
input tuple_in_local_state_VALID /* unused */ ;
input [15:0] tuple_in_local_state_DATA /* unused */ ;
output tuple_out_local_state_VALID /* undriven */ ;
output [15:0] tuple_out_local_state_DATA /* undriven */ ;
input tuple_in_Parser_extracts_VALID /* unused */ ;
input [31:0] tuple_in_Parser_extracts_DATA /* unused */ ;
output tuple_out_Parser_extracts_VALID /* undriven */ ;
output [31:0] tuple_out_Parser_extracts_DATA /* undriven */ ;
input tuple_in_memcached_input_VALID /* unused */ ;
input tuple_in_memcached_input_DATA /* unused */ ;
output tuple_out_memcached_output_VALID /* undriven */ ;
output tuple_out_memcached_output_DATA /* undriven */ ;
input backpressure_in ;
output backpressure_out ;

wire packet_in_packet_in_RDY /* undriven */ ;
wire packet_out_packet_out_SOF /* undriven */ ;
wire packet_out_packet_out_EOF /* undriven */ ;
wire packet_out_packet_out_VAL /* undriven */ ;
wire [63:0] packet_out_packet_out_DAT /* undriven */ ;
wire [3:0] packet_out_packet_out_CNT /* undriven */ ;
wire packet_out_packet_out_ERR /* undriven */ ;
wire tuple_out_control_VALID /* undriven */ ;
wire [21:0] tuple_out_control_DATA /* undriven */ ;
wire tuple_out_CheckCache_fl_VALID /* undriven */ ;
wire tuple_out_CheckCache_fl_DATA /* undriven */ ;
wire tuple_out_hdr_VALID /* undriven */ ;
wire [371:0] tuple_out_hdr_DATA /* undriven */ ;
wire tuple_out_ioports_VALID /* undriven */ ;
wire [7:0] tuple_out_ioports_DATA /* undriven */ ;
wire tuple_out_local_state_VALID /* undriven */ ;
wire [15:0] tuple_out_local_state_DATA /* undriven */ ;
wire tuple_out_Parser_extracts_VALID /* undriven */ ;
wire [31:0] tuple_out_Parser_extracts_DATA /* undriven */ ;
wire tuple_out_memcached_output_VALID /* undriven */ ;
wire tuple_out_memcached_output_DATA /* undriven */ ;




/* Tuple format for input: tuple_in_CheckCache_fl
 	[0:0]	: forward_1

*/




/* Tuple format for output: tuple_out_CheckCache_fl
 	[0:0]	: forward_1

*/




/* Tuple format for input: tuple_in_hdr
 	[371:259]	: eth
	[258:226]	: fec
	[225:65]	: ipv4
	[64:0]	: udp

*/




/* Tuple format for output: tuple_out_hdr
 	[371:259]	: eth
	[258:226]	: fec
	[225:65]	: ipv4
	[64:0]	: udp

*/




/* Tuple format for input: tuple_in_ioports
 	[7:4]	: ingress_port
	[3:0]	: egress_port

*/




/* Tuple format for output: tuple_out_ioports
 	[7:4]	: ingress_port
	[3:0]	: egress_port

*/




/* Tuple format for input: tuple_in_local_state
 	[15:0]	: id

*/




/* Tuple format for output: tuple_out_local_state
 	[15:0]	: id

*/




/* Tuple format for input: tuple_in_Parser_extracts
 	[31:0]	: size

*/




/* Tuple format for output: tuple_out_Parser_extracts
 	[31:0]	: size

*/




/* Tuple format for input: tuple_in_memcached_input
 	[0:0]	: stateful_valid

*/




/* Tuple format for output: tuple_out_memcached_output
 	[0:0]	: forward

*/



assign packet_out_packet_out_SOF = packet_in_packet_in_SOF;
assign packet_out_packet_out_EOF = packet_in_packet_in_EOF;
assign packet_out_packet_out_VAL = packet_in_packet_in_VAL;
assign packet_out_packet_out_RDY = packet_in_packet_in_RDY;
assign packet_out_packet_out_DAT = packet_in_packet_in_DAT;
assign packet_out_packet_out_CNT = packet_in_packet_in_CNT;
assign packet_out_packet_out_ERR = packet_in_packet_in_ERR;

assign tuple_out_control_VALID = tuple_in_control_VALID;
assign tuple_out_control_DATA = tuple_in_control_DATA;

assign tuple_out_CheckCache_fl_VALID = tuple_in_CheckCache_fl_VALID;
assign tuple_out_CheckCache_fl_DATA = tuple_in_CheckCache_fl_DATA;

assign tuple_out_hdr_VALID = tuple_in_hdr_VALID;
assign tuple_out_hdr_DATA = tuple_in_hdr_DATA;

assign tuple_out_ioports_VALID = tuple_in_ioports_VALID;
assign tuple_out_ioports_DATA = tuple_in_ioports_DATA;

assign tuple_out_local_state_VALID = tuple_in_local_state_VALID;
assign tuple_out_local_state_DATA = tuple_in_local_state_DATA;

assign tuple_out_Parser_extracts_VALID = tuple_in_Parser_extracts_VALID;
assign tuple_out_Parser_extracts_DATA = tuple_in_Parser_extracts_DATA;

assign tuple_out_memcached_output_VALID = tuple_in_memcached_input_VALID;
assign tuple_out_memcached_output_DATA = tuple_in_memcached_input_DATA;

assign backpressure_out = backpressure_in;

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/05/24 11:53:22
// by Barista HDL generation library, version TRUNK @ 1007984


