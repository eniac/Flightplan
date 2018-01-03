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
// Xilinx SDNet Compiler version 2017.2.1, build 1997167
//----------------------------------------------------------------------------
/*

 tx latency = 13 (cycles)
 min latency = 75 (cycles)
 max latency = 204 (cycles)

input/output tuple 'control'
	section 4-bit field @ [22:19]
	activeBank 1-bit field @ [18:18]
	offset 14-bit field @ [17:4]
	done 1-bit field @ [3:3]
	errorCode 3-bit field @ [2:0]

input tuple 'transition_edges'
	remove_expr 16-bit field @ [31:16]
	remove_expr_0 8-bit field @ [15:8]
	remove_expr_1 8-bit field @ [7:0]

input/output tuple 'TUPLE0'
	anon 821-bit field @ [820:0]

*/

`timescale 1 ps / 1 ps

module RemoveHeaders_t (
	rst,
	clk_line,
	packet_in_RDY,
	packet_in_VAL,
	packet_in_SOF,
	packet_in_EOF,
	packet_in_ERR,
	packet_in_CNT,
	packet_in_DAT,
	tuple_in_control_VALID,
	tuple_in_control_DATA,
	tuple_in_transition_edges_VALID,
	tuple_in_transition_edges_DATA,
	tuple_in_TUPLE0_VALID,
	tuple_in_TUPLE0_DATA,
	packet_out_RDY,
	packet_out_VAL,
	packet_out_SOF,
	packet_out_EOF,
	packet_out_ERR,
	packet_out_CNT,
	packet_out_DAT,
	tuple_out_control_VALID,
	tuple_out_control_DATA,
	tuple_out_TUPLE0_VALID,
	tuple_out_TUPLE0_DATA,
	backpressure_in,
	backpressure_out
);

input rst ;
input clk_line ;
output packet_in_RDY ;
input packet_in_VAL ;
input packet_in_SOF ;
input packet_in_EOF ;
input packet_in_ERR ;
input [3:0] packet_in_CNT ;
input [63:0] packet_in_DAT ;
input tuple_in_control_VALID ;
input [22:0] tuple_in_control_DATA ;
input tuple_in_transition_edges_VALID /* unused */ ;
input [31:0] tuple_in_transition_edges_DATA ;
input tuple_in_TUPLE0_VALID /* unused */ ;
input [820:0] tuple_in_TUPLE0_DATA ;
input packet_out_RDY /* unused */ ;
output packet_out_VAL ;
output packet_out_SOF ;
output packet_out_EOF ;
output packet_out_ERR ;
output [3:0] packet_out_CNT ;
output [63:0] packet_out_DAT ;
output tuple_out_control_VALID ;
output [22:0] tuple_out_control_DATA ;
output tuple_out_TUPLE0_VALID ;
output [820:0] tuple_out_TUPLE0_DATA ;
input backpressure_in ;
output backpressure_out ;

wire packet_in_RDY ;
wire tuple_in_valid ;
reg [22:0] tuple_in_control_i ;
wire [31:0] tuple_in_transition_edges ;
wire [820:0] tuple_in_TUPLE0 ;
wire packet_out_VAL ;
wire packet_out_SOF ;
wire packet_out_EOF ;
wire packet_out_ERR ;
wire [3:0] packet_out_CNT ;
wire [63:0] packet_out_DAT ;
wire tuple_out_control_VALID ;
wire tuple_out_valid ;
reg [22:0] tuple_out_control_DATA ;
wire [22:0] tuple_out_control_i ;
wire tuple_out_TUPLE0_VALID ;
wire [820:0] tuple_out_TUPLE0_DATA ;
wire [820:0] tuple_out_TUPLE0 ;
wire backpressure_out ;
wire RX_PKT_RDY ;
wire TX_PKT_RDY_i ;

assign tuple_in_valid = tuple_in_control_VALID ;

always @* begin
	tuple_in_control_i = tuple_in_control_DATA ;
	if ( ( ( tuple_in_control_DATA[3] == 0 ) && ( tuple_in_control_DATA[2:0] == 0 ) ) ) begin
		tuple_in_control_i[22:19] = 1 ;
	end
end

assign tuple_in_transition_edges = tuple_in_transition_edges_DATA ;

assign tuple_in_TUPLE0 = tuple_in_TUPLE0_DATA ;

assign tuple_out_control_VALID = tuple_out_valid ;

always @* begin
	tuple_out_control_DATA = tuple_out_control_i ;
	tuple_out_control_DATA[3] = 0 ;
	tuple_out_control_DATA[22:19] = 0 ;
	tuple_out_control_DATA[17:4] = 0 ;
	if ( ( tuple_out_control_i[2:0] == 0 ) ) begin
		if ( ( ( tuple_out_control_i[3] == 0 ) || ( tuple_out_control_i[22:19] != 0 ) ) ) begin
			tuple_out_control_DATA[2:0] = 1 ;
		end
	end
end

assign tuple_out_TUPLE0_VALID = tuple_out_valid ;

assign tuple_out_TUPLE0_DATA = tuple_out_TUPLE0 ;

assign packet_in_RDY = RX_PKT_RDY ;

assign backpressure_out = ~RX_PKT_RDY ;

assign TX_PKT_RDY_i = ~backpressure_in ;

RemoveHeaders_t_Engine
RemoveHeaders_t_inst
(
	.reset               	( rst ),
	.clock               	( clk_line ),
	.RX_TUPLE_VALID      	( tuple_in_valid ),
	.RX_TUPLE_control    	( tuple_in_control_i ),
	.TX_TUPLE_VALID      	( tuple_out_valid ),
	.TX_TUPLE_control    	( tuple_out_control_i ),
	.RX_TUPLE_transition_edges	( tuple_in_transition_edges ),
	.RX_TUPLE_TUPLE0     	( tuple_in_TUPLE0 ),
	.TX_TUPLE_TUPLE0     	( tuple_out_TUPLE0 ),
	.RX_PKT_RDY          	( RX_PKT_RDY ),
	.TX_PKT_RDY          	( TX_PKT_RDY_i ),
	.RX_PKT_VLD          	( packet_in_VAL ),
	.RX_PKT_SOP          	( packet_in_SOF ),
	.RX_PKT_EOP          	( packet_in_EOF ),
	.RX_PKT_ERR          	( packet_in_ERR ),
	.RX_PKT_CNT          	( packet_in_CNT ),
	.RX_PKT_DAT          	( packet_in_DAT ),
	.TX_PKT_VLD          	( packet_out_VAL ),
	.TX_PKT_SOP          	( packet_out_SOF ),
	.TX_PKT_EOP          	( packet_out_EOF ),
	.TX_PKT_ERR          	( packet_out_ERR ),
	.TX_PKT_CNT          	( packet_out_CNT ),
	.TX_PKT_DAT          	( packet_out_DAT )
);


endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2017/10/23 14:31:57
// by Barista HDL generation library, version TRUNK @ 1007984

