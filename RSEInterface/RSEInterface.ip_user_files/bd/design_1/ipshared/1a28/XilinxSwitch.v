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

*/

`timescale 1 ps / 1 ps

module XilinxSwitch (
	packet_in_packet_in_TVALID,
	packet_in_packet_in_TREADY,
	packet_in_packet_in_TDATA,
	packet_in_packet_in_TKEEP,
	packet_in_packet_in_TLAST,
	enable_processing,
	packet_out_packet_out_TVALID,
	packet_out_packet_out_TREADY,
	packet_out_packet_out_TDATA,
	packet_out_packet_out_TKEEP,
	packet_out_packet_out_TLAST,
	clk_line_rst,
	clk_line,
	internal_rst_done
);

input [0:0] packet_in_packet_in_TVALID ;
output [0:0] packet_in_packet_in_TREADY ;
input [63:0] packet_in_packet_in_TDATA ;
input [7:0] packet_in_packet_in_TKEEP ;
input [0:0] packet_in_packet_in_TLAST ;
input [0:0] enable_processing ;
output [0:0] packet_out_packet_out_TVALID ;
input [0:0] packet_out_packet_out_TREADY ;
output [63:0] packet_out_packet_out_TDATA ;
output [7:0] packet_out_packet_out_TKEEP ;
output [0:0] packet_out_packet_out_TLAST ;
(* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *) input clk_line_rst ;
input clk_line ;
output [0:0] internal_rst_done ;

wire [0:0] packet_in_packet_in_TREADY ;
wire [0:0] packet_out_packet_out_TVALID ;
wire [63:0] packet_out_packet_out_TDATA ;
wire [7:0] packet_out_packet_out_TKEEP ;
wire [0:0] packet_out_packet_out_TLAST ;
wire [0:0] S_PROTOCOL_ADAPTER_INGRESS__tuple_out_control_____Parser__tuple_in_control_VALID ;
wire [22:0] S_PROTOCOL_ADAPTER_INGRESS__tuple_out_control_____Parser__tuple_in_control_DATA ;
wire [0:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_SOF ;
wire [0:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_EOF ;
wire [0:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_VAL ;
wire [0:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_RDY /* unused */ ;
wire [63:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_DAT ;
wire [3:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_CNT ;
wire [0:0] S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_ERR ;
wire [0:0] Deparser__tuple_out_control_____S_PROTOCOL_ADAPTER_EGRESS__tuple_in_control_VALID ;
wire [22:0] Deparser__tuple_out_control_____S_PROTOCOL_ADAPTER_EGRESS__tuple_in_control_DATA ;
wire [0:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_SOF ;
wire [0:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_EOF ;
wire [0:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_VAL ;
wire [0:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_RDY ;
wire [63:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_DAT ;
wire [3:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_CNT ;
wire [0:0] Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_ERR ;
wire [0:0] S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TVALID ;
wire [0:0] S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TREADY ;
wire [63:0] S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TDATA ;
wire [7:0] S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TKEEP ;
wire [0:0] S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TLAST ;
wire [0:0] Parser__tuple_out_transition_edges_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE0_VALID ;
wire [31:0] Parser__tuple_out_transition_edges_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE0_DATA ;
wire [0:0] S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE0_____RemoveHeaders__tuple_in_transition_edges_VALID ;
wire [31:0] S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE0_____RemoveHeaders__tuple_in_transition_edges_DATA ;
wire [0:0] Parser__tuple_out_hdr_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE1_VALID ;
wire [820:0] Parser__tuple_out_hdr_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE1_DATA ;
wire [0:0] Parser__tuple_out_control_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE2_VALID ;
wire [22:0] Parser__tuple_out_control_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE2_DATA ;
wire [0:0] S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE2_____RemoveHeaders__tuple_in_control_VALID ;
wire [22:0] S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE2_____RemoveHeaders__tuple_in_control_DATA ;
wire [0:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_SOF ;
wire [0:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_EOF ;
wire [0:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_VAL ;
wire [0:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_RDY ;
wire [63:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_DAT ;
wire [3:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_CNT ;
wire [0:0] Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_ERR ;
wire [0:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_SOF ;
wire [0:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_EOF ;
wire [0:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_VAL ;
wire [0:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_RDY ;
wire [63:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_DAT ;
wire [3:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_CNT ;
wire [0:0] S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_ERR ;
wire [0:0] Forward__tuple_out_hdr_____S_SYNCER_for_Deparser__tuple_in_TUPLE0_VALID ;
wire [820:0] Forward__tuple_out_hdr_____S_SYNCER_for_Deparser__tuple_in_TUPLE0_DATA ;
wire [0:0] S_SYNCER_for_Deparser__tuple_out_TUPLE0_____Deparser__tuple_in_hdr_VALID ;
wire [820:0] S_SYNCER_for_Deparser__tuple_out_TUPLE0_____Deparser__tuple_in_hdr_DATA ;
wire [0:0] RemoveHeaders__tuple_out_control_____S_SYNCER_for_Deparser__tuple_in_TUPLE1_VALID ;
wire [22:0] RemoveHeaders__tuple_out_control_____S_SYNCER_for_Deparser__tuple_in_TUPLE1_DATA ;
wire [0:0] S_SYNCER_for_Deparser__tuple_out_TUPLE1_____Deparser__tuple_in_control_VALID ;
wire [22:0] S_SYNCER_for_Deparser__tuple_out_TUPLE1_____Deparser__tuple_in_control_DATA ;
wire [0:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_SOF ;
wire [0:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_EOF ;
wire [0:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_VAL ;
wire [0:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RDY ;
wire [63:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_DAT ;
wire [3:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_CNT ;
wire [0:0] RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_ERR ;
wire [0:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_SOF ;
wire [0:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_EOF ;
wire [0:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_VAL ;
wire [0:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_RDY ;
wire [63:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_DAT ;
wire [3:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_CNT ;
wire [0:0] S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_ERR ;
wire [0:0] S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE1_____RemoveHeaders__tuple_in_TUPLE0_VALID ;
wire [820:0] S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE1_____RemoveHeaders__tuple_in_TUPLE0_DATA ;
wire [0:0] RemoveHeaders__tuple_out_TUPLE0_____Forward__tuple_in_hdr_VALID ;
wire [820:0] RemoveHeaders__tuple_out_TUPLE0_____Forward__tuple_in_hdr_DATA ;
wire clk_line_init_done ;
wire clk_line_rst_high ;
wire clk_line_rst_low /* unused */ ;
wire [0:0] internal_rst_done ;
wire S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE ;
reg S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_1 ;
reg S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_2 ;
reg S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_3 ;
wire _source_zero_BACKPRESSURE /* unused */ ;
wire S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE ;
reg S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_1 ;
reg S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_2 ;
reg S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_3 ;
wire S_SYNCER_for__OUT______Deparser_BACKPRESSURE ;
reg S_SYNCER_for__OUT______Deparser_BACKPRESSURE_1 ;
reg S_SYNCER_for__OUT______Deparser_BACKPRESSURE_2 ;
reg S_SYNCER_for__OUT______Deparser_BACKPRESSURE_3 ;
wire RemoveHeaders_____S_SYNCER_for_RemoveHeaders_BACKPRESSURE ;
wire Deparser_____S_SYNCER_for_Deparser_BACKPRESSURE ;

// black box
S_RESETTER_line
S_RESET_clk_line
(
	.clk                 	( clk_line ),
	.rst                 	( clk_line_rst ),
	.reset_out_active_high	( clk_line_rst_high ),
	.reset_out_active_low	( clk_line_rst_low ),
	.init_done           	( clk_line_init_done )
);

assign internal_rst_done = clk_line_init_done ;

always @( posedge clk_line ) begin
	if ( clk_line_rst_high ) begin
		S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_1 <= 0 ;
		S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_2 <= 0 ;
		S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_3 <= 0 ;
	end
	else  begin
		S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_1 <= S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE ;
		S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_2 <= S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_1 ;
		S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_3 <= S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_2 ;
	end
end

assign packet_in_packet_in_TREADY = ~S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE_3 ;

assign _source_zero_BACKPRESSURE = 1'd0 ;

always @( posedge clk_line ) begin
	if ( clk_line_rst_high ) begin
		S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_1 <= 0 ;
		S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_2 <= 0 ;
		S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_3 <= 0 ;
	end
	else  begin
		S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_1 <= S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE ;
		S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_2 <= S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_1 ;
		S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_3 <= S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_2 ;
	end
end

always @( posedge clk_line ) begin
	if ( clk_line_rst_high ) begin
		S_SYNCER_for__OUT______Deparser_BACKPRESSURE_1 <= 0 ;
		S_SYNCER_for__OUT______Deparser_BACKPRESSURE_2 <= 0 ;
		S_SYNCER_for__OUT______Deparser_BACKPRESSURE_3 <= 0 ;
	end
	else  begin
		S_SYNCER_for__OUT______Deparser_BACKPRESSURE_1 <= S_SYNCER_for__OUT______Deparser_BACKPRESSURE ;
		S_SYNCER_for__OUT______Deparser_BACKPRESSURE_2 <= S_SYNCER_for__OUT______Deparser_BACKPRESSURE_1 ;
		S_SYNCER_for__OUT______Deparser_BACKPRESSURE_3 <= S_SYNCER_for__OUT______Deparser_BACKPRESSURE_2 ;
	end
end

// black box
Parser_t
Parser
(
	.tuple_in_control_VALID	( S_PROTOCOL_ADAPTER_INGRESS__tuple_out_control_____Parser__tuple_in_control_VALID ),
	.tuple_in_control_DATA	( S_PROTOCOL_ADAPTER_INGRESS__tuple_out_control_____Parser__tuple_in_control_DATA ),
	.packet_in_SOF       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_SOF ),
	.packet_in_EOF       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_EOF ),
	.packet_in_VAL       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_VAL ),
	.packet_in_RDY       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_RDY ),
	.packet_in_DAT       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_DAT ),
	.packet_in_CNT       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_CNT ),
	.packet_in_ERR       	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_ERR ),
	.tuple_out_transition_edges_VALID	( Parser__tuple_out_transition_edges_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE0_VALID ),
	.tuple_out_transition_edges_DATA	( Parser__tuple_out_transition_edges_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE0_DATA ),
	.tuple_out_hdr_VALID 	( Parser__tuple_out_hdr_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE1_VALID ),
	.tuple_out_hdr_DATA  	( Parser__tuple_out_hdr_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE1_DATA ),
	.tuple_out_control_VALID	( Parser__tuple_out_control_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE2_VALID ),
	.tuple_out_control_DATA	( Parser__tuple_out_control_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE2_DATA ),
	.packet_out_SOF      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_SOF ),
	.packet_out_EOF      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_EOF ),
	.packet_out_VAL      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_VAL ),
	.packet_out_RDY      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_RDY ),
	.packet_out_DAT      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_DAT ),
	.packet_out_CNT      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_CNT ),
	.packet_out_ERR      	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_ERR ),
	.clk_line            	( clk_line ),
	.rst                 	( clk_line_rst_high )
);

// black box
RemoveHeaders_t
RemoveHeaders
(
	.tuple_in_transition_edges_VALID	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE0_____RemoveHeaders__tuple_in_transition_edges_VALID ),
	.tuple_in_transition_edges_DATA	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE0_____RemoveHeaders__tuple_in_transition_edges_DATA ),
	.tuple_in_control_VALID	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE2_____RemoveHeaders__tuple_in_control_VALID ),
	.tuple_in_control_DATA	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE2_____RemoveHeaders__tuple_in_control_DATA ),
	.packet_in_SOF       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_SOF ),
	.packet_in_EOF       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_EOF ),
	.packet_in_VAL       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_VAL ),
	.packet_in_RDY       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_RDY ),
	.packet_in_DAT       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_DAT ),
	.packet_in_CNT       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_CNT ),
	.packet_in_ERR       	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_ERR ),
	.tuple_out_control_VALID	( RemoveHeaders__tuple_out_control_____S_SYNCER_for_Deparser__tuple_in_TUPLE1_VALID ),
	.tuple_out_control_DATA	( RemoveHeaders__tuple_out_control_____S_SYNCER_for_Deparser__tuple_in_TUPLE1_DATA ),
	.packet_out_SOF      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_SOF ),
	.packet_out_EOF      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_EOF ),
	.packet_out_VAL      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_VAL ),
	.packet_out_RDY      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RDY ),
	.packet_out_DAT      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_DAT ),
	.packet_out_CNT      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_CNT ),
	.packet_out_ERR      	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_ERR ),
	.tuple_in_TUPLE0_VALID	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE1_____RemoveHeaders__tuple_in_TUPLE0_VALID ),
	.tuple_in_TUPLE0_DATA	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE1_____RemoveHeaders__tuple_in_TUPLE0_DATA ),
	.tuple_out_TUPLE0_VALID	( RemoveHeaders__tuple_out_TUPLE0_____Forward__tuple_in_hdr_VALID ),
	.tuple_out_TUPLE0_DATA	( RemoveHeaders__tuple_out_TUPLE0_____Forward__tuple_in_hdr_DATA ),
	.backpressure_in     	( S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE_3 ),
	.backpressure_out    	( RemoveHeaders_____S_SYNCER_for_RemoveHeaders_BACKPRESSURE ),
	.clk_line            	( clk_line ),
	.rst                 	( clk_line_rst_high )
);

// black box
Forward_t
Forward
(
	.tuple_out_hdr_VALID 	( Forward__tuple_out_hdr_____S_SYNCER_for_Deparser__tuple_in_TUPLE0_VALID ),
	.tuple_out_hdr_DATA  	( Forward__tuple_out_hdr_____S_SYNCER_for_Deparser__tuple_in_TUPLE0_DATA ),
	.tuple_in_hdr_VALID  	( RemoveHeaders__tuple_out_TUPLE0_____Forward__tuple_in_hdr_VALID ),
	.tuple_in_hdr_DATA   	( RemoveHeaders__tuple_out_TUPLE0_____Forward__tuple_in_hdr_DATA ),
	.clk_line            	( clk_line ),
	.rst                 	( clk_line_rst_high )
);

// black box
Deparser_t
Deparser
(
	.tuple_out_control_VALID	( Deparser__tuple_out_control_____S_PROTOCOL_ADAPTER_EGRESS__tuple_in_control_VALID ),
	.tuple_out_control_DATA	( Deparser__tuple_out_control_____S_PROTOCOL_ADAPTER_EGRESS__tuple_in_control_DATA ),
	.packet_out_SOF      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_SOF ),
	.packet_out_EOF      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_EOF ),
	.packet_out_VAL      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_VAL ),
	.packet_out_RDY      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_RDY ),
	.packet_out_DAT      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_DAT ),
	.packet_out_CNT      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_CNT ),
	.packet_out_ERR      	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_ERR ),
	.tuple_in_hdr_VALID  	( S_SYNCER_for_Deparser__tuple_out_TUPLE0_____Deparser__tuple_in_hdr_VALID ),
	.tuple_in_hdr_DATA   	( S_SYNCER_for_Deparser__tuple_out_TUPLE0_____Deparser__tuple_in_hdr_DATA ),
	.tuple_in_control_VALID	( S_SYNCER_for_Deparser__tuple_out_TUPLE1_____Deparser__tuple_in_control_VALID ),
	.tuple_in_control_DATA	( S_SYNCER_for_Deparser__tuple_out_TUPLE1_____Deparser__tuple_in_control_DATA ),
	.packet_in_SOF       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_SOF ),
	.packet_in_EOF       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_EOF ),
	.packet_in_VAL       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_VAL ),
	.packet_in_RDY       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_RDY ),
	.packet_in_DAT       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_DAT ),
	.packet_in_CNT       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_CNT ),
	.packet_in_ERR       	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_ERR ),
	.backpressure_in     	( S_SYNCER_for__OUT______Deparser_BACKPRESSURE_3 ),
	.backpressure_out    	( Deparser_____S_SYNCER_for_Deparser_BACKPRESSURE ),
	.clk_line            	( clk_line ),
	.rst                 	( clk_line_rst_high )
);

// black box
S_PROTOCOL_ADAPTER_INGRESS
S_PROTOCOL_ADAPTER_INGRESS
(
	.packet_in_TVALID    	( packet_in_packet_in_TVALID ),
	.packet_in_TREADY    	(  ),
	.packet_in_TDATA     	( packet_in_packet_in_TDATA ),
	.packet_in_TKEEP     	( packet_in_packet_in_TKEEP ),
	.packet_in_TLAST     	( packet_in_packet_in_TLAST ),
	.tuple_out_control_VALID	( S_PROTOCOL_ADAPTER_INGRESS__tuple_out_control_____Parser__tuple_in_control_VALID ),
	.tuple_out_control_DATA	( S_PROTOCOL_ADAPTER_INGRESS__tuple_out_control_____Parser__tuple_in_control_DATA ),
	.packet_out_SOF      	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_SOF ),
	.packet_out_EOF      	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_EOF ),
	.packet_out_VAL      	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_VAL ),
	.packet_out_RDY      	( packet_in_packet_in_TREADY ),
	.packet_out_DAT      	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_DAT ),
	.packet_out_CNT      	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_CNT ),
	.packet_out_ERR      	( S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_S_PROTOCOL_ADAPTER_INGRESS__packet_out_____Parser__packet_in_ERR ),
	.plain_in_init       	( enable_processing ),
	.clk_line            	( clk_line ),
	.rst                 	( clk_line_rst_high )
);

// black box
S_PROTOCOL_ADAPTER_EGRESS
S_PROTOCOL_ADAPTER_EGRESS
(
	.tuple_in_control_VALID	( Deparser__tuple_out_control_____S_PROTOCOL_ADAPTER_EGRESS__tuple_in_control_VALID ),
	.tuple_in_control_DATA	( Deparser__tuple_out_control_____S_PROTOCOL_ADAPTER_EGRESS__tuple_in_control_DATA ),
	.packet_in_SOF       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_SOF ),
	.packet_in_EOF       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_EOF ),
	.packet_in_VAL       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_VAL ),
	.packet_in_RDY       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_RDY ),
	.packet_in_DAT       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_DAT ),
	.packet_in_CNT       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_CNT ),
	.packet_in_ERR       	( Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_Deparser__packet_out_____S_PROTOCOL_ADAPTER_EGRESS__packet_in_ERR ),
	.packet_out_TVALID   	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TVALID ),
	.packet_out_TREADY   	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TREADY ),
	.packet_out_TDATA    	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TDATA ),
	.packet_out_TKEEP    	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TKEEP ),
	.packet_out_TLAST    	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TLAST ),
	.clk_line            	( clk_line ),
	.rst                 	( clk_line_rst_high )
);

// black box
S_SYNCER_for__OUT_
S_SYNCER_for__OUT_
(
	.packet_in_PACKET0_TVALID	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TVALID ),
	.packet_in_PACKET0_TREADY	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TREADY ),
	.packet_in_PACKET0_TDATA	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TDATA ),
	.packet_in_PACKET0_TKEEP	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TKEEP ),
	.packet_in_PACKET0_TLAST	( S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_S_PROTOCOL_ADAPTER_EGRESS__packet_out_____S_SYNCER_for__OUT___packet_in_PACKET0_TLAST ),
	.packet_out_PACKET0_TVALID	( packet_out_packet_out_TVALID ),
	.packet_out_PACKET0_TREADY	( packet_out_packet_out_TREADY ),
	.packet_out_PACKET0_TDATA	( packet_out_packet_out_TDATA ),
	.packet_out_PACKET0_TKEEP	( packet_out_packet_out_TKEEP ),
	.packet_out_PACKET0_TLAST	( packet_out_packet_out_TLAST ),
	.backpressure_in     	( ~(packet_out_packet_out_TREADY) ),
	.backpressure_out    	( S_SYNCER_for__OUT______Deparser_BACKPRESSURE ),
	.clk_in_0            	( clk_line ),
	.rst_in_0            	( clk_line_rst_high ),
	.clk_out_0           	( clk_line ),
	.rst_out_0           	( clk_line_rst_high )
);

// black box
S_SYNCER_for_RemoveHeaders
S_SYNCER_for_RemoveHeaders
(
	.tuple_in_TUPLE0_VALID	( Parser__tuple_out_transition_edges_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE0_VALID ),
	.tuple_in_TUPLE0_DATA	( Parser__tuple_out_transition_edges_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE0_DATA ),
	.tuple_out_TUPLE0_VALID	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE0_____RemoveHeaders__tuple_in_transition_edges_VALID ),
	.tuple_out_TUPLE0_DATA	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE0_____RemoveHeaders__tuple_in_transition_edges_DATA ),
	.tuple_in_TUPLE1_VALID	( Parser__tuple_out_hdr_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE1_VALID ),
	.tuple_in_TUPLE1_DATA	( Parser__tuple_out_hdr_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE1_DATA ),
	.tuple_in_TUPLE2_VALID	( Parser__tuple_out_control_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE2_VALID ),
	.tuple_in_TUPLE2_DATA	( Parser__tuple_out_control_____S_SYNCER_for_RemoveHeaders__tuple_in_TUPLE2_DATA ),
	.tuple_out_TUPLE2_VALID	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE2_____RemoveHeaders__tuple_in_control_VALID ),
	.tuple_out_TUPLE2_DATA	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE2_____RemoveHeaders__tuple_in_control_DATA ),
	.packet_in_PACKET3_SOF	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_SOF ),
	.packet_in_PACKET3_EOF	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_EOF ),
	.packet_in_PACKET3_VAL	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_VAL ),
	.packet_in_PACKET3_RDY	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_RDY ),
	.packet_in_PACKET3_DAT	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_DAT ),
	.packet_in_PACKET3_CNT	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_CNT ),
	.packet_in_PACKET3_ERR	( Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_Parser__packet_out_____S_SYNCER_for_RemoveHeaders__packet_in_PACKET3_ERR ),
	.packet_out_PACKET3_SOF	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_SOF ),
	.packet_out_PACKET3_EOF	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_EOF ),
	.packet_out_PACKET3_VAL	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_VAL ),
	.packet_out_PACKET3_RDY	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_RDY ),
	.packet_out_PACKET3_DAT	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_DAT ),
	.packet_out_PACKET3_CNT	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_CNT ),
	.packet_out_PACKET3_ERR	( S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_S_SYNCER_for_RemoveHeaders__packet_out_PACKET3_____RemoveHeaders__packet_in_ERR ),
	.tuple_out_TUPLE1_VALID	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE1_____RemoveHeaders__tuple_in_TUPLE0_VALID ),
	.tuple_out_TUPLE1_DATA	( S_SYNCER_for_RemoveHeaders__tuple_out_TUPLE1_____RemoveHeaders__tuple_in_TUPLE0_DATA ),
	.backpressure_in     	( RemoveHeaders_____S_SYNCER_for_RemoveHeaders_BACKPRESSURE ),
	.backpressure_out    	( S_SYNCER_for_RemoveHeaders______IN__BACKPRESSURE ),
	.clk_in_0            	( clk_line ),
	.rst_in_0            	( clk_line_rst_high ),
	.clk_out_0           	( clk_line ),
	.rst_out_0           	( clk_line_rst_high ),
	.clk_in_1            	( clk_line ),
	.rst_in_1            	( clk_line_rst_high ),
	.clk_out_1           	( clk_line ),
	.rst_out_1           	( clk_line_rst_high ),
	.clk_in_2            	( clk_line ),
	.rst_in_2            	( clk_line_rst_high ),
	.clk_out_2           	( clk_line ),
	.rst_out_2           	( clk_line_rst_high ),
	.clk_in_3            	( clk_line ),
	.rst_in_3            	( clk_line_rst_high ),
	.clk_out_3           	( clk_line ),
	.rst_out_3           	( clk_line_rst_high )
);

// black box
S_SYNCER_for_Deparser
S_SYNCER_for_Deparser
(
	.tuple_in_TUPLE0_VALID	( Forward__tuple_out_hdr_____S_SYNCER_for_Deparser__tuple_in_TUPLE0_VALID ),
	.tuple_in_TUPLE0_DATA	( Forward__tuple_out_hdr_____S_SYNCER_for_Deparser__tuple_in_TUPLE0_DATA ),
	.tuple_out_TUPLE0_VALID	( S_SYNCER_for_Deparser__tuple_out_TUPLE0_____Deparser__tuple_in_hdr_VALID ),
	.tuple_out_TUPLE0_DATA	( S_SYNCER_for_Deparser__tuple_out_TUPLE0_____Deparser__tuple_in_hdr_DATA ),
	.tuple_in_TUPLE1_VALID	( RemoveHeaders__tuple_out_control_____S_SYNCER_for_Deparser__tuple_in_TUPLE1_VALID ),
	.tuple_in_TUPLE1_DATA	( RemoveHeaders__tuple_out_control_____S_SYNCER_for_Deparser__tuple_in_TUPLE1_DATA ),
	.tuple_out_TUPLE1_VALID	( S_SYNCER_for_Deparser__tuple_out_TUPLE1_____Deparser__tuple_in_control_VALID ),
	.tuple_out_TUPLE1_DATA	( S_SYNCER_for_Deparser__tuple_out_TUPLE1_____Deparser__tuple_in_control_DATA ),
	.packet_in_PACKET2_SOF	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_SOF ),
	.packet_in_PACKET2_EOF	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_EOF ),
	.packet_in_PACKET2_VAL	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_VAL ),
	.packet_in_PACKET2_RDY	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RDY ),
	.packet_in_PACKET2_DAT	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_DAT ),
	.packet_in_PACKET2_CNT	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_CNT ),
	.packet_in_PACKET2_ERR	( RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_RemoveHeaders__packet_out_____S_SYNCER_for_Deparser__packet_in_PACKET2_ERR ),
	.packet_out_PACKET2_SOF	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_SOF ),
	.packet_out_PACKET2_EOF	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_EOF ),
	.packet_out_PACKET2_VAL	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_VAL ),
	.packet_out_PACKET2_RDY	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_RDY ),
	.packet_out_PACKET2_DAT	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_DAT ),
	.packet_out_PACKET2_CNT	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_CNT ),
	.packet_out_PACKET2_ERR	( S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_S_SYNCER_for_Deparser__packet_out_PACKET2_____Deparser__packet_in_ERR ),
	.backpressure_in     	( Deparser_____S_SYNCER_for_Deparser_BACKPRESSURE ),
	.backpressure_out    	( S_SYNCER_for_Deparser_____RemoveHeaders_BACKPRESSURE ),
	.clk_in_0            	( clk_line ),
	.rst_in_0            	( clk_line_rst_high ),
	.clk_out_0           	( clk_line ),
	.rst_out_0           	( clk_line_rst_high ),
	.clk_in_1            	( clk_line ),
	.rst_in_1            	( clk_line_rst_high ),
	.clk_out_1           	( clk_line ),
	.rst_out_1           	( clk_line_rst_high ),
	.clk_in_2            	( clk_line ),
	.rst_in_2            	( clk_line_rst_high ),
	.clk_out_2           	( clk_line ),
	.rst_out_2           	( clk_line_rst_high )
);


endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2017/10/23 14:31:57
// by Barista HDL generation library, version TRUNK @ 1007984

