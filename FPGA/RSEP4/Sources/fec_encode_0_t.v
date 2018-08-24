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

`include "Configuration.v"

`define FEC_HDR_WIDTH  `FEC_TRAFFIC_CLASS_WIDTH + `FEC_BLOCK_INDEX_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_ETHER_TYPE_WIDTH

`define TUPLE_CONTROL_WIDTH          22
`define TUPLE_UPDATE_FL_WIDTH        `FEC_K_WIDTH + `FEC_H_WIDTH + 8
`define TUPLE_HDR_WIDTH              `FEC_ETH_HEADER_SIZE + `FEC_HDR_WIDTH + 2
`define TUPLE_IOPORTS_WIDTH          8
`define TUPLE_LOCAL_STATE_WIDTH      16
`define TUPLE_PARSER_EXTRACTS_WIDTH  32
`define TUPLE_ENCODER_INPUT_WIDTH    `FEC_K_WIDTH + `FEC_H_WIDTH + `FEC_HDR_WIDTH + 2
`define TUPLE_ENCODER_OUTPUT_WIDTH   `FEC_PACKET_INDEX_WIDTH

`define INPUT_TUPLES_WIDTH   `TUPLE_CONTROL_WIDTH + `TUPLE_UPDATE_FL_WIDTH + `TUPLE_HDR_WIDTH + `TUPLE_IOPORTS_WIDTH + `TUPLE_LOCAL_STATE_WIDTH + `TUPLE_PARSER_EXTRACTS_WIDTH + `TUPLE_ENCODER_INPUT_WIDTH
`define OUTPUT_TUPLES_WIDTH  `TUPLE_ENCODER_OUTPUT_WIDTH

module fec_encode_0_t (
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
	tuple_in_Update_fl_VALID,
	tuple_in_Update_fl_DATA,
	tuple_out_Update_fl_VALID,
	tuple_out_Update_fl_DATA,
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
	tuple_in_fec_encode_input_VALID,
	tuple_in_fec_encode_input_DATA,
	tuple_out_fec_encode_output_VALID,
	tuple_out_fec_encode_output_DATA,
	backpressure_in,
	backpressure_out
);

input clk_line ;
(* polarity = "high" *) input rst ;
input packet_in_packet_in_SOF ;
input packet_in_packet_in_EOF ;
input packet_in_packet_in_VAL ;
output packet_in_packet_in_RDY ;
input [63:0] packet_in_packet_in_DAT ;
input [3:0] packet_in_packet_in_CNT ;
input packet_in_packet_in_ERR ;
output packet_out_packet_out_SOF ;
output packet_out_packet_out_EOF ;
output packet_out_packet_out_VAL ;
input packet_out_packet_out_RDY ;
output [63:0] packet_out_packet_out_DAT ;
output [3:0] packet_out_packet_out_CNT ;
output packet_out_packet_out_ERR ;
input tuple_in_control_VALID ;
input [`TUPLE_CONTROL_WIDTH - 1:0] tuple_in_control_DATA ;
output tuple_out_control_VALID ;
output [`TUPLE_CONTROL_WIDTH - 1:0] tuple_out_control_DATA ;
input tuple_in_Update_fl_VALID ;
input [`TUPLE_UPDATE_FL_WIDTH - 1:0] tuple_in_Update_fl_DATA ;
output tuple_out_Update_fl_VALID ;
output [`TUPLE_UPDATE_FL_WIDTH - 1:0] tuple_out_Update_fl_DATA ;
input tuple_in_hdr_VALID ;
input [`TUPLE_HDR_WIDTH - 1:0] tuple_in_hdr_DATA ;
output tuple_out_hdr_VALID ;
output [`TUPLE_HDR_WIDTH - 1:0] tuple_out_hdr_DATA ;
input tuple_in_ioports_VALID ;
input [`TUPLE_IOPORTS_WIDTH - 1:0] tuple_in_ioports_DATA ;
output tuple_out_ioports_VALID ;
output [`TUPLE_IOPORTS_WIDTH - 1:0] tuple_out_ioports_DATA ;
input tuple_in_local_state_VALID ;
input [`TUPLE_LOCAL_STATE_WIDTH - 1:0] tuple_in_local_state_DATA ;
output tuple_out_local_state_VALID ;
output [`TUPLE_LOCAL_STATE_WIDTH - 1:0] tuple_out_local_state_DATA ;
input tuple_in_Parser_extracts_VALID ;
input [`TUPLE_PARSER_EXTRACTS_WIDTH - 1:0] tuple_in_Parser_extracts_DATA ;
output tuple_out_Parser_extracts_VALID ;
output [`TUPLE_PARSER_EXTRACTS_WIDTH - 1:0] tuple_out_Parser_extracts_DATA ;
input tuple_in_fec_encode_input_VALID ;
input [`TUPLE_ENCODER_INPUT_WIDTH - 1:0] tuple_in_fec_encode_input_DATA ;
output tuple_out_fec_encode_output_VALID ;
output tuple_out_fec_encode_output_DATA ;
input backpressure_in ;
output backpressure_out ;

wire packet_in_packet_in_RDY ;
wire packet_out_packet_out_SOF ;
wire packet_out_packet_out_EOF ;
wire packet_out_packet_out_VAL ;
wire [63:0] packet_out_packet_out_DAT ;
wire [3:0] packet_out_packet_out_CNT ;
wire packet_out_packet_out_ERR ;
reg tuple_out_control_VALID ;
wire [`TUPLE_CONTROL_WIDTH - 1:0] tuple_out_control_DATA ;
reg tuple_out_Update_fl_VALID ;
wire [`TUPLE_UPDATE_FL_WIDTH - 1:0] tuple_out_Update_fl_DATA ;
reg tuple_out_hdr_VALID ;
wire [`TUPLE_HDR_WIDTH - 1:0] tuple_out_hdr_DATA ;
reg tuple_out_ioports_VALID ;
wire [`TUPLE_IOPORTS_WIDTH - 1:0] tuple_out_ioports_DATA ;
reg tuple_out_local_state_VALID ;
wire [`TUPLE_LOCAL_STATE_WIDTH - 1:0] tuple_out_local_state_DATA ;
reg tuple_out_Parser_extracts_VALID ;
wire [`TUPLE_PARSER_EXTRACTS_WIDTH - 1:0] tuple_out_Parser_extracts_DATA ;
wire tuple_out_fec_encode_output_VALID ;
wire [`TUPLE_ENCODER_OUTPUT_WIDTH - 1:0] tuple_out_fec_encode_output_DATA ;

wire tuple_fifo_wr_en;
reg tuple_fifo_rd_en;
wire [`INPUT_TUPLES_WIDTH - 1:0] tuple_fifo_din;
wire [`INPUT_TUPLES_WIDTH - 1:0] tuple_fifo_dout;
wire tuple_fifo_empty;
wire tuple_fifo_almost_full;

wire packet_fifo_wr_en;
wire packet_fifo_rd_en;
wire [70:0] packet_fifo_din;
wire [70:0] packet_fifo_dout;
wire packet_fifo_empty;
wire packet_fifo_almost_full;

wire core_start;
wire core_done;
wire core_idle;
wire core_ready;
wire [`TUPLE_ENCODER_INPUT_WIDTH - 1:0] core_input_tuple;
reg core_input_tuple_ap_vld;
wire [`OUTPUT_TUPLES_WIDTH - 1:0] core_output_tuple;
wire core_output_tuple_ap_vld;
wire [70:0] core_input_packet_dout;
wire core_input_packet_empty_n;
wire core_input_packet_read;
wire [70:0] core_output_packet;
wire core_output_packet_ap_vld;
wire core_output_packet_ap_ack;

reg [2:0] state;
reg [2:0] next_state;

wire [`FEC_K_WIDTH - 1:0] k;
wire [`FEC_H_WIDTH - 1:0] h;
wire [`FEC_PACKET_INDEX_WIDTH - 1:0] packet_index;

`define STATE_IDLE            0
`define STATE_OUTPUT_TUPLE    1
`define STATE_WAIT_FOR_OUTPUT 2
`define STATE_WAIT_FOR_DONE   3
`define STATE_GENERATE_PACKET 4

defparam tuple_fifo.WRITE_DATA_WIDTH = `INPUT_TUPLES_WIDTH;
defparam tuple_fifo.FIFO_WRITE_DEPTH = 512; 
defparam tuple_fifo.PROG_FULL_THRESH = 287; 
defparam tuple_fifo.PROG_EMPTY_THRESH = 287; 
defparam tuple_fifo.READ_MODE = "std"; 
defparam tuple_fifo.WR_DATA_COUNT_WIDTH = 9; 
defparam tuple_fifo.RD_DATA_COUNT_WIDTH = 9; 
defparam tuple_fifo.DOUT_RESET_VALUE = "0"; 
defparam tuple_fifo.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync tuple_fifo (
	.wr_en(tuple_fifo_wr_en),
	.din(tuple_fifo_din),
	.rd_en(tuple_fifo_rd_en),
	.sleep(1'b0),
	.injectsbiterr(),
	.injectdbiterr(),
	.prog_empty(), 
	.dout(tuple_fifo_dout), 
	.empty(tuple_fifo_empty), 
	.prog_full(tuple_fifo_almost_full), 
	.full(), 
	.rd_data_count(), 
	.wr_data_count(), 
	.wr_rst_busy(), 
	.rd_rst_busy(), 
	.overflow(), 
	.underflow(), 
	.sbiterr(), 
	.dbiterr(), 
	.wr_clk(clk_line), 
	.rst(rst) 
); 

defparam packet_fifo.WRITE_DATA_WIDTH = 71; 
defparam packet_fifo.FIFO_WRITE_DEPTH = 512; 
defparam packet_fifo.PROG_FULL_THRESH = 287; 
defparam packet_fifo.PROG_EMPTY_THRESH = 287; 
defparam packet_fifo.READ_MODE = "fwft"; 
defparam packet_fifo.WR_DATA_COUNT_WIDTH = 9; 
defparam packet_fifo.RD_DATA_COUNT_WIDTH = 9; 
defparam packet_fifo.DOUT_RESET_VALUE = "0"; 
defparam packet_fifo.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync packet_fifo (
	.wr_en(packet_fifo_wr_en),
	.din(packet_fifo_din),
	.rd_en(packet_fifo_rd_en),
	.sleep(1'b0),
	.injectsbiterr(),
	.injectdbiterr(),
	.prog_empty(), 
	.dout(packet_fifo_dout), 
	.empty(packet_fifo_empty), 
	.prog_full(packet_fifo_almost_full), 
	.full(), 
	.rd_data_count(), 
	.wr_data_count(), 
	.wr_rst_busy(), 
	.rd_rst_busy(), 
	.overflow(), 
	.underflow(), 
	.sbiterr(), 
	.dbiterr(), 
	.wr_clk(clk_line), 
	.rst(rst) 
); 

RSE_core core
(
  .ap_clk(clk_line),
  .ap_rst(rst),
  .ap_start(core_start),
  .ap_done(core_done),
  .ap_idle(core_idle),
  .ap_ready(core_ready),
  .Input_tuple(core_input_tuple),
  .Input_tuple_ap_vld(core_input_tuple_ap_vld),
  .Output_tuple_Packet_index(core_output_tuple),
  .Output_tuple_Packet_index_ap_vld(core_output_tuple_ap_vld),
  .Input_packet_dout(core_input_packet_dout),
  .Input_packet_empty_n(core_input_packet_empty_n),
  .Input_packet_read(core_input_packet_read),
  .Output_packet(core_output_packet),
  .Output_packet_ap_vld(core_output_packet_ap_vld),
  .Output_packet_ap_ack(core_output_packet_ap_ack)
);

assign packet_in_packet_in_RDY = packet_out_packet_out_RDY;

assign tuple_fifo_wr_en = tuple_in_fec_encode_input_VALID;
assign tuple_fifo_din = {tuple_in_fec_encode_input_DATA, tuple_in_control_DATA,
                         tuple_in_Update_fl_DATA, tuple_in_hdr_DATA,
                         tuple_in_ioports_DATA, tuple_in_local_state_DATA,
                         tuple_in_Parser_extracts_DATA};
assign packet_fifo_wr_en = packet_in_packet_in_VAL;
assign packet_fifo_din = {packet_in_packet_in_SOF, packet_in_packet_in_EOF, packet_in_packet_in_DAT,
                          packet_in_packet_in_CNT, packet_in_packet_in_ERR};
assign packet_fifo_rd_en = core_input_packet_read;

assign {core_input_tuple, tuple_out_control_DATA, tuple_out_Update_fl_DATA,
        tuple_out_hdr_DATA, tuple_out_ioports_DATA, tuple_out_local_state_DATA,
        tuple_out_Parser_extracts_DATA} = tuple_fifo_dout;

assign core_start = 1;
assign core_input_packet_dout = packet_fifo_dout;
assign core_input_packet_empty_n = ~packet_fifo_empty;
assign core_output_packet_ap_ack = ~backpressure_in;

assign k = core_input_tuple[`FEC_K_WIDTH + `FEC_H_WIDTH - 1:`FEC_H_WIDTH];
assign h = core_input_tuple[`FEC_H_WIDTH - 1:0];
assign packet_index = core_output_tuple;

always @( posedge clk_line ) begin
	if ( rst ) begin
		state <= `STATE_IDLE;
	end
	else  begin
		state <= next_state;
	end
end

always @(state, tuple_fifo_empty, core_done, packet_index, k, h,
         core_output_tuple_ap_vld) begin
	tuple_fifo_rd_en                <= 0;
	core_input_tuple_ap_vld         <= 0;
	tuple_out_control_VALID         <= 0;
	tuple_out_Update_fl_VALID       <= 0;
	tuple_out_hdr_VALID             <= 0;
	tuple_out_ioports_VALID         <= 0;
	tuple_out_local_state_VALID     <= 0;
	tuple_out_Parser_extracts_VALID <= 0;
	next_state                      <= state;

	case ( state )
		`STATE_IDLE : begin
			if ( !tuple_fifo_empty ) begin
				tuple_fifo_rd_en  <= 1;
				next_state        <= `STATE_OUTPUT_TUPLE;
			end
		end

		`STATE_OUTPUT_TUPLE : begin
			core_input_tuple_ap_vld         <= 1;
			tuple_out_control_VALID         <= 1;
			tuple_out_Update_fl_VALID       <= 1;
			tuple_out_hdr_VALID             <= 1;
			tuple_out_ioports_VALID         <= 1;
			tuple_out_local_state_VALID     <= 1;
			tuple_out_Parser_extracts_VALID <= 1;
			next_state                      <= `STATE_WAIT_FOR_OUTPUT;
		end

		`STATE_WAIT_FOR_OUTPUT : begin
			if ( core_output_tuple_ap_vld ) begin
				if ( packet_index >= k - 1 && packet_index < k + h - 1 ) begin
					next_state <= `STATE_GENERATE_PACKET;
				end
				else  begin
					next_state <= `STATE_WAIT_FOR_DONE;
				end
			end
		end

		`STATE_WAIT_FOR_DONE : begin
			if ( core_done ) begin
				next_state <= `STATE_IDLE;
			end
		end

		`STATE_GENERATE_PACKET : begin
			if ( core_done ) begin
				next_state <= `STATE_OUTPUT_TUPLE;
			end
		end
	endcase
end

assign backpressure_out = tuple_fifo_almost_full | packet_fifo_almost_full;

assign {packet_out_packet_out_SOF, packet_out_packet_out_EOF, packet_out_packet_out_DAT,
        packet_out_packet_out_CNT, packet_out_packet_out_ERR} = core_output_packet;
assign packet_out_packet_out_VAL = core_output_packet_ap_vld & ~backpressure_in;

assign tuple_out_fec_encode_output_VALID = core_output_tuple_ap_vld;
assign tuple_out_fec_encode_output_DATA = core_output_tuple;

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/02/02 15:59:25
// by Barista HDL generation library, version TRUNK @ 1007984

