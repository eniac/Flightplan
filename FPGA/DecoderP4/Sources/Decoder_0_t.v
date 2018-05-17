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

`define FEC_HDR_WIDTH `FEC_TRAFFIC_CLASS_WIDTH + `FEC_BLOCK_INDEX_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_ETHER_TYPE_WIDTH

`define TUPLE_CONTROL_WIDTH          23
`define TUPLE_UPDATE_FL_WIDTH        2 * `FEC_K_WIDTH
`define TUPLE_HDR_WIDTH              `FEC_ETH_HEADER_SIZE + `FEC_HDR_WIDTH + 2
`define TUPLE_IOPORTS_WIDTH          8
`define TUPLE_LOCAL_STATE_WIDTH      16
`define TUPLE_PARSER_EXTRACTS_WIDTH  32
`define TUPLE_DECODER_INPUT_WIDTH    1 + `FEC_K_WIDTH + `FEC_TRAFFIC_CLASS_WIDTH + `FEC_BLOCK_INDEX_WIDTH + `FEC_PACKET_INDEX_WIDTH
`define TUPLE_DECODER_OUTPUT_WIDTH   `FEC_K_WIDTH

`define TUPLE_CONTROL_START          0
`define TUPLE_CONTROL_END            `TUPLE_CONTROL_WIDTH - 1
`define TUPLE_UPDATE_FL_START        `TUPLE_CONTROL_END + 1
`define TUPLE_UPDATE_FL_END          `TUPLE_UPDATE_FL_START + `TUPLE_UPDATE_FL_WIDTH - 1
`define TUPLE_HDR_START              `TUPLE_UPDATE_FL_END + 1
`define TUPLE_HDR_END                `TUPLE_HDR_START + `TUPLE_HDR_WIDTH - 1
`define TUPLE_IOPORTS_START          `TUPLE_HDR_END + 1
`define TUPLE_IOPORTS_END            `TUPLE_IOPORTS_START + `TUPLE_IOPORTS_WIDTH - 1
`define TUPLE_LOCAL_STATE_START      `TUPLE_IOPORTS_END + 1
`define TUPLE_LOCAL_STATE_END        `TUPLE_LOCAL_STATE_START + `TUPLE_LOCAL_STATE_WIDTH - 1
`define TUPLE_PARSER_EXTRACTS_START  `TUPLE_LOCAL_STATE_END + 1
`define TUPLE_PARSER_EXTRACTS_END    `TUPLE_PARSER_EXTRACTS_START + `TUPLE_PARSER_EXTRACTS_WIDTH - 1
`define TUPLE_DECODER_OUTPUT_START   `TUPLE_PARSER_EXTRACTS_END + 1
`define TUPLE_DECODER_OUTPUT_END     `TUPLE_DECODER_OUTPUT_START + `TUPLE_DECODER_OUTPUT_WIDTH - 1

`define INPUT_TUPLES_WIDTH   `TUPLE_PARSER_EXTRACTS_END + `TUPLE_DECODER_INPUT_WIDTH + 1
`define OUTPUT_TUPLES_WIDTH  `TUPLE_DECODER_OUTPUT_END + 1

module Decoder_0_t (
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
	tuple_in_Decoder_input_VALID,
	tuple_in_Decoder_input_DATA,
	tuple_out_Decoder_output_VALID,
	tuple_out_Decoder_output_DATA
);

input clk_line;
(* polarity = "high" *) input rst;
input packet_in_packet_in_SOF;
input packet_in_packet_in_EOF;
input packet_in_packet_in_VAL;
output packet_in_packet_in_RDY;
input [`FEC_AXI_BUS_WIDTH - 1:0] packet_in_packet_in_DAT;
input [3:0] packet_in_packet_in_CNT;
input packet_in_packet_in_ERR;
output packet_out_packet_out_SOF;
output packet_out_packet_out_EOF;
output packet_out_packet_out_VAL;
input packet_out_packet_out_RDY;
output [`FEC_AXI_BUS_WIDTH - 1:0] packet_out_packet_out_DAT;
output [3:0] packet_out_packet_out_CNT;
output packet_out_packet_out_ERR;
input tuple_in_control_VALID;
input [`TUPLE_CONTROL_WIDTH - 1:0] tuple_in_control_DATA;
output tuple_out_control_VALID;
output [`TUPLE_CONTROL_WIDTH - 1:0] tuple_out_control_DATA;
input tuple_in_Update_fl_VALID;
input [`TUPLE_UPDATE_FL_WIDTH - 1:0] tuple_in_Update_fl_DATA;
output tuple_out_Update_fl_VALID;
output [`TUPLE_UPDATE_FL_WIDTH - 1:0] tuple_out_Update_fl_DATA;
input tuple_in_hdr_VALID;
input [`TUPLE_HDR_WIDTH - 1:0] tuple_in_hdr_DATA;
output tuple_out_hdr_VALID;
output [`TUPLE_HDR_WIDTH - 1:0] tuple_out_hdr_DATA;
input tuple_in_ioports_VALID;
input [`TUPLE_IOPORTS_WIDTH - 1:0] tuple_in_ioports_DATA;
output tuple_out_ioports_VALID;
output [`TUPLE_IOPORTS_WIDTH - 1:0] tuple_out_ioports_DATA;
input tuple_in_local_state_VALID;
input [`TUPLE_LOCAL_STATE_WIDTH - 1:0] tuple_in_local_state_DATA;
output tuple_out_local_state_VALID;
output [`TUPLE_LOCAL_STATE_WIDTH - 1:0] tuple_out_local_state_DATA;
input tuple_in_Parser_extracts_VALID;
input [`TUPLE_PARSER_EXTRACTS_WIDTH - 1:0] tuple_in_Parser_extracts_DATA;
output tuple_out_Parser_extracts_VALID;
output [`TUPLE_PARSER_EXTRACTS_WIDTH - 1:0] tuple_out_Parser_extracts_DATA;
input tuple_in_Decoder_input_VALID;
input [`TUPLE_DECODER_INPUT_WIDTH - 1:0] tuple_in_Decoder_input_DATA;
output tuple_out_Decoder_output_VALID;
output [`TUPLE_DECODER_OUTPUT_WIDTH - 1:0] tuple_out_Decoder_output_DATA;

wire packet_in_packet_in_RDY;
wire packet_out_packet_out_SOF;
wire packet_out_packet_out_EOF;
wire packet_out_packet_out_VAL;
wire [`FEC_AXI_BUS_WIDTH - 1:0] packet_out_packet_out_DAT;
wire [3:0] packet_out_packet_out_CNT;
wire packet_out_packet_out_ERR;
wire tuple_out_control_VALID;
wire [`TUPLE_CONTROL_WIDTH - 1:0] tuple_out_control_DATA;
wire tuple_out_Update_fl_VALID;
wire [`TUPLE_UPDATE_FL_WIDTH - 1:0] tuple_out_Update_fl_DATA;
wire tuple_out_hdr_VALID;
wire [`TUPLE_HDR_WIDTH - 1:0] tuple_out_hdr_DATA;
wire tuple_out_ioports_VALID;
wire [`TUPLE_IOPORTS_WIDTH - 1:0] tuple_out_ioports_DATA;
wire tuple_out_local_state_VALID;
wire [`TUPLE_LOCAL_STATE_WIDTH - 1:0] tuple_out_local_state_DATA;
wire tuple_out_Parser_extracts_VALID;
wire [`TUPLE_PARSER_EXTRACTS_WIDTH - 1:0] tuple_out_Parser_extracts_DATA;
wire tuple_out_Decoder_output_VALID;
wire [`TUPLE_DECODER_OUTPUT_WIDTH - 1:0] tuple_out_Decoder_output_DATA;

wire dec_ap_clk;
wire dec_ap_rst;
wire dec_ap_start;
wire dec_ap_done;
wire dec_ap_idle;
wire dec_ap_ready;
wire [`INPUT_TUPLES_WIDTH - 1:0] dec_tuple_input_v_dout;
wire dec_tuple_input_v_empty_n;
wire dec_tuple_input_v_read;
wire [`OUTPUT_TUPLES_WIDTH - 1:0] dec_tuple_output_v;
wire dec_tuple_output_v_ap_vld;
wire dec_tuple_output_v_ap_ack;
wire [`FEC_AXI_BUS_WIDTH + 6:0] dec_packet_input_v_dout;
wire dec_packet_input_v_empty_n;
wire dec_packet_input_v_read;
wire [`FEC_AXI_BUS_WIDTH + 6:0] dec_packet_output_v;
wire dec_packet_output_v_ap_vld;
wire dec_packet_output_v_ap_ack;

wire tuple_fifo_wr_en;
reg tuple_fifo_rd_en;
wire [`INPUT_TUPLES_WIDTH - 1:0] tuple_fifo_din;
wire [`INPUT_TUPLES_WIDTH - 1:0] tuple_fifo_dout;
wire tuple_fifo_empty;
wire tuple_fifo_almost_full;

wire packet_fifo_wr_en;
wire packet_fifo_rd_en;
wire [`FEC_AXI_BUS_WIDTH + 6:0] packet_fifo_din;
wire [`FEC_AXI_BUS_WIDTH + 6:0] packet_fifo_dout;
wire packet_fifo_empty;
wire packet_fifo_almost_full;

Decode dec
(
  .ap_clk(dec_ap_clk),
  .ap_rst(dec_ap_rst),
  .ap_start(dec_ap_start),
  .ap_done(dec_ap_done),
  .ap_idle(dec_ap_idle),
  .ap_ready(dec_ap_ready),
  .Tuple_input_V_dout(dec_tuple_input_v_dout),
  .Tuple_input_V_empty_n(dec_tuple_input_v_empty_n),
  .Tuple_input_V_read(dec_tuple_input_v_read),
  .Tuple_output_V(dec_tuple_output_v),
  .Tuple_output_V_ap_vld(dec_tuple_output_v_ap_vld),
  .Tuple_output_V_ap_ack(dec_tuple_output_v_ap_ack),
  .Packet_input_V_dout(dec_packet_input_v_dout),
  .Packet_input_V_empty_n(dec_packet_input_v_empty_n),
  .Packet_input_V_read(dec_packet_input_v_read),
  .Packet_output_V(dec_packet_output_v),
  .Packet_output_V_ap_vld(dec_packet_output_v_ap_vld),
  .Packet_output_V_ap_ack(dec_packet_output_v_ap_ack)
);

assign dec_ap_clk = clk_line;
assign dec_ap_rst = rst;
assign dec_ap_start = 1;
assign dec_tuple_input_v_dout = tuple_fifo_dout;
assign dec_tuple_input_v_empty_n = ~tuple_fifo_empty;
assign dec_tuple_output_v_ap_ack = 1;
assign dec_packet_input_v_dout = packet_fifo_dout;
assign dec_packet_input_v_empty_n = ~packet_fifo_empty;
assign dec_packet_output_v_ap_ack = packet_out_packet_out_RDY;

defparam tuple_fifo.WRITE_DATA_WIDTH = `INPUT_TUPLES_WIDTH;
defparam tuple_fifo.FIFO_WRITE_DEPTH = 512; 
defparam tuple_fifo.PROG_FULL_THRESH = 287; 
defparam tuple_fifo.PROG_EMPTY_THRESH = 287; 
defparam tuple_fifo.READ_MODE = "fwft"; 
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

assign tuple_fifo_wr_en = tuple_in_Decoder_input_VALID;
assign tuple_fifo_din = {tuple_in_Decoder_input_DATA, tuple_in_Parser_extracts_DATA,
                         tuple_in_local_state_DATA, tuple_in_ioports_DATA,
                         tuple_in_hdr_DATA, tuple_in_Update_fl_DATA, tuple_in_control_DATA};

defparam packet_fifo.WRITE_DATA_WIDTH = `FEC_AXI_BUS_WIDTH + 7; 
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

assign packet_fifo_wr_en = packet_in_packet_in_VAL;
assign packet_fifo_din = {packet_in_packet_in_SOF, packet_in_packet_in_EOF, packet_in_packet_in_DAT,
                          packet_in_packet_in_CNT, packet_in_packet_in_ERR};
assign packet_fifo_rd_en = dec_packet_input_v_read;

assign packet_in_packet_in_RDY = packet_fifo_almost_full;

assign {packet_out_packet_out_SOF, packet_out_packet_out_EOF, packet_out_packet_out_DAT,
        packet_out_packet_out_CNT, packet_out_packet_out_ERR} = dec_packet_output_v;
assign packet_out_packet_out_VAL = dec_packet_output_v_ap_vld;

assign tuple_out_Decoder_output_DATA  = tuple_fifo_dout[`TUPLE_DECODER_OUTPUT_END:`TUPLE_DECODER_OUTPUT_START];
assign tuple_out_Parser_extracts_DATA = tuple_fifo_dout[`TUPLE_PARSER_EXTRACTS_END:`TUPLE_PARSER_EXTRACTS_START];
assign tuple_out_local_state_DATA     = tuple_fifo_dout[`TUPLE_LOCAL_STATE_END:`TUPLE_LOCAL_STATE_START];
assign tuple_out_ioports_DATA         = tuple_fifo_dout[`TUPLE_IOPORTS_END:`TUPLE_IOPORTS_START];
assign tuple_out_hdr_DATA             = tuple_fifo_dout[`TUPLE_HDR_END:`TUPLE_HDR_START];
assign tuple_out_Update_fl_DATA       = tuple_fifo_dout[`TUPLE_UPDATE_FL_END:`TUPLE_UPDATE_FL_START];
assign tuple_out_control_DATA         = tuple_fifo_dout[`TUPLE_CONTROL_END:`TUPLE_CONTROL_START];

assign tuple_out_Decoder_output_VALID  = dec_tuple_output_v_ap_vld;
assign tuple_out_Parser_extracts_VALID = dec_tuple_output_v_ap_vld;
assign tuple_out_local_state_VALID     = dec_tuple_output_v_ap_vld;
assign tuple_out_ioports_VALID         = dec_tuple_output_v_ap_vld;
assign tuple_out_hdr_VALID             = dec_tuple_output_v_ap_vld;
assign tuple_out_Update_fl_VALID       = dec_tuple_output_v_ap_vld;
assign tuple_out_control_VALID         = dec_tuple_output_v_ap_vld;

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/05/14 14:25:47
// by Barista HDL generation library, version TRUNK @ 1007984

