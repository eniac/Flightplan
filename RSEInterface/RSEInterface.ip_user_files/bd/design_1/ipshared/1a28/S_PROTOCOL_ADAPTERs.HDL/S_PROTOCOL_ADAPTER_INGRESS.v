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

module S_PROTOCOL_ADAPTER_INGRESS (
	clk_line,
	rst,
	plain_in_init,
	tuple_out_control_VALID,
	tuple_out_control_DATA,
	packet_in_TLAST,
	packet_in_TVALID,
	packet_in_TREADY,
	packet_in_TDATA,
	packet_in_TKEEP,
	packet_out_SOF,
	packet_out_EOF,
	packet_out_VAL,
	packet_out_RDY,
	packet_out_DAT,
	packet_out_ERR,
	packet_out_CNT
);

localparam IDLE = 1 ;
localparam RX_SOF = 2 ;
localparam RX_SOF_EOF = 3 ;
localparam RX_PKT = 4 ;
input clk_line ;
input rst ;
input plain_in_init ;
output tuple_out_control_VALID ;
output [22:0] tuple_out_control_DATA ;
input packet_in_TLAST ;
input packet_in_TVALID ;
output packet_in_TREADY ;
input [63:0] packet_in_TDATA /* unused */ ;
input [7:0] packet_in_TKEEP /* unused */ ;
output packet_out_SOF ;
output packet_out_EOF ;
output packet_out_VAL ;
input packet_out_RDY ;
output [63:0] packet_out_DAT ;
output packet_out_ERR ;
output [3:0] packet_out_CNT ;

reg tuple_out_control_VALID ;
wire [22:0] tuple_out_control_DATA ;
wire packet_in_TREADY ;
wire [63:0] packet_in_TDATA_i /* undriven */ ;
wire [7:0] packet_in_TKEEP_i /* undriven */ ;
reg TLAST_1 ;
reg TVALID_1 ;
reg [63:0] TDATA_1 ;
reg [7:0] TKEEP_1 ;
reg packet_out_SOF ;
reg packet_out_EOF ;
reg packet_out_VAL ;
reg [63:0] packet_out_DAT ;
wire packet_out_ERR ;
reg [3:0] packet_out_CNT ;
reg [2:0] state ;
reg [2:0] nxt_state ;

assign tuple_out_control_DATA = ( plain_in_init ? { 23{1'd0} } : { 23{1'd1} } ) ;

always @( posedge clk_line ) begin
	TLAST_1 <= packet_in_TLAST ;
	TVALID_1 <= ( packet_in_TVALID & packet_out_RDY ) ;
	TDATA_1 <= packet_in_TDATA_i ;
	TKEEP_1 <= packet_in_TKEEP_i ;
end

always @* begin
	nxt_state = state ;
	case ( state )
		IDLE : begin
			if ( TVALID_1 ) begin
				if ( TLAST_1 ) begin
					nxt_state = RX_SOF_EOF ;
				end
				else  begin
					nxt_state = RX_SOF ;
				end
			end
			else  begin
				nxt_state = IDLE ;
			end
		end
		RX_SOF : begin
			if ( TVALID_1 ) begin
				if ( TLAST_1 ) begin
					nxt_state = IDLE ;
				end
				else  begin
					nxt_state = RX_PKT ;
				end
			end
			else  begin
				nxt_state = RX_PKT ;
			end
		end
		RX_SOF_EOF : begin
			if ( TVALID_1 ) begin
				if ( TLAST_1 ) begin
					nxt_state = RX_SOF_EOF ;
				end
				else  begin
					nxt_state = RX_SOF ;
				end
			end
			else  begin
				nxt_state = IDLE ;
			end
		end
		RX_PKT : begin
			if ( TVALID_1 ) begin
				if ( TLAST_1 ) begin
					nxt_state = IDLE ;
				end
				else  begin
					nxt_state = RX_PKT ;
				end
			end
			else  begin
				nxt_state = RX_PKT ;
			end
		end
		default : begin
			nxt_state = IDLE ;
		end
	endcase
end

always @( posedge clk_line ) begin
	if ( rst ) begin
		state <= IDLE ;
	end
	else  begin
		state <= nxt_state ;
	end
end

assign packet_in_TREADY = packet_out_RDY ;

assign packet_out_ERR = 0 ;

always @( posedge clk_line ) begin
	if ( ( ( nxt_state == RX_SOF ) || ( nxt_state == RX_SOF_EOF ) ) ) begin
		packet_out_SOF <= 1'd1 ;
		tuple_out_control_VALID <= 1'd1 ;
	end
	else  begin
		packet_out_SOF <= 1'd0 ;
		tuple_out_control_VALID <= 1'd0 ;
	end
end

always @( posedge clk_line ) begin
	if ( rst ) begin
		packet_out_EOF <= 0 ;
	end
	else  begin
		packet_out_EOF <= TLAST_1 ;
	end
end

always @( posedge clk_line ) begin
	if ( rst ) begin
		packet_out_VAL <= 0 ;
		packet_out_DAT <= 0 ;
		packet_out_CNT <= 0 ;
	end
	else  begin
		packet_out_VAL <= TVALID_1 ;
		packet_out_DAT <= TDATA_1 ;
		packet_out_CNT <= { TKEEP_1[0], ( ~TKEEP_1[0] & ^{ TKEEP_1[4] } ), ( ~TKEEP_1[0] & ^{ TKEEP_1[4], ~TKEEP_1[2], ~TKEEP_1[6] } ), ( ~TKEEP_1[0] & ^{ TKEEP_1[4], ~TKEEP_1[2], ~TKEEP_1[6], TKEEP_1[1], TKEEP_1[5], TKEEP_1[3], TKEEP_1[7] } ) } ;
	end
end



genvar i;
genvar j;
for (i=0; i<8; i=i+1) 
    for (j=0; j<8; j=j+1) 
        assign packet_in_TDATA_i[i*8+j] = packet_in_TDATA[(8-i-1)*8+j]; 
for (i=0; i<8; i=i+1) assign packet_in_TKEEP_i[i] = packet_in_TKEEP[7-i]; 


endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2017/10/23 14:31:56
// by Barista HDL generation library, version TRUNK @ 1007984

