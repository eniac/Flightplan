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
`define INPUT_TUPLES_WIDTH 548 
`define OUTPUT_TUPLES_WIDTH 548 
`define MEM_AXI_BUS_WIDTH 64
module headerCompress_0_t (
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
	tuple_in_CheckTcp_fl_VALID,
	tuple_in_CheckTcp_fl_DATA,
	tuple_out_CheckTcp_fl_VALID,
	tuple_out_CheckTcp_fl_DATA,
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
	tuple_in_headerCompress_input_VALID,
	tuple_in_headerCompress_input_DATA,
	tuple_out_headerCompress_output_VALID,
	tuple_out_headerCompress_output_DATA,
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
input tuple_in_CheckTcp_fl_VALID /* unused */ ;
input tuple_in_CheckTcp_fl_DATA /* unused */ ;
output tuple_out_CheckTcp_fl_VALID /* undriven */ ;
output tuple_out_CheckTcp_fl_DATA /* undriven */ ;
input tuple_in_hdr_VALID /* unused */ ;
input [467:0] tuple_in_hdr_DATA /* unused */ ;
output tuple_out_hdr_VALID /* undriven */ ;
output [467:0] tuple_out_hdr_DATA /* undriven */ ;
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
input tuple_in_headerCompress_input_VALID /* unused */ ;
input tuple_in_headerCompress_input_DATA /* unused */ ;
output tuple_out_headerCompress_output_VALID /* undriven */ ;
output tuple_out_headerCompress_output_DATA /* undriven */ ;
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
wire tuple_out_CheckTcp_fl_VALID /* undriven */ ;
wire tuple_out_CheckTcp_fl_DATA /* undriven */ ;
wire tuple_out_hdr_VALID /* undriven */ ;
wire [467:0] tuple_out_hdr_DATA /* undriven */ ;
wire tuple_out_ioports_VALID /* undriven */ ;
wire [7:0] tuple_out_ioports_DATA /* undriven */ ;
wire tuple_out_local_state_VALID /* undriven */ ;
wire [15:0] tuple_out_local_state_DATA /* undriven */ ;
wire tuple_out_Parser_extracts_VALID /* undriven */ ;
wire [31:0] tuple_out_Parser_extracts_DATA /* undriven */ ;
wire tuple_out_headerCompress_output_VALID /* undriven */ ;
wire tuple_out_headerCompress_output_DATA /* undriven */ ;

wire compress_ap_clk;
wire compress_ap_rst;
wire compress_ap_start;
wire compress_ap_done;
wire compress_ap_idle;
wire compress_ap_ready;
wire [`INPUT_TUPLES_WIDTH - 1:0] compress_tuple_input_v_dout;
wire compress_tuple_input_v_empty_n;
wire compress_tuple_input_v_read;
wire [`OUTPUT_TUPLES_WIDTH - 1:0] compress_tuple_output_v;
wire compress_tuple_output_v_ap_vld;
wire compress_tuple_output_v_ap_ack;
wire [`MEM_AXI_BUS_WIDTH + 6:0] compress_packet_input_v_dout;
wire compress_packet_input_v_empty_n;
wire compress_packet_input_v_read;
wire [`MEM_AXI_BUS_WIDTH + 6:0] compress_packet_output_v;
wire compress_packet_output_v_ap_vld;
wire compress_packet_output_v_ap_ack;

wire tuple_fifo_wr_en;
wire tuple_fifo_rd_en;
wire [`INPUT_TUPLES_WIDTH - 1:0] tuple_fifo_din;
wire [`INPUT_TUPLES_WIDTH - 1:0] tuple_fifo_dout;
wire tuple_fifo_empty;
wire tuple_fifo_almost_full;
wire tuple_fifo_full;

wire packet_fifo_wr_en;
wire packet_fifo_rd_en;
wire [`MEM_AXI_BUS_WIDTH + 6:0] packet_fifo_din;
wire [`MEM_AXI_BUS_WIDTH + 6:0] packet_fifo_dout;
wire packet_fifo_empty;
wire packet_fifo_almost_full;
wire packet_fifo_full;


Compressor compress
(
        .ap_clk(compress_ap_clk),
        .ap_rst(compress_ap_rst),
        .ap_start(compress_ap_start),
        .ap_done(compress_ap_done),
        .ap_idle(compress_ap_idle),
        .ap_ready(compress_ap_ready),
        .Input_tuples_V_dout(compress_tuple_input_v_dout),
        .Input_tuples_V_empty_n(compress_tuple_input_v_empty_n),
        .Input_tuples_V_read(compress_tuple_input_v_read),
        .Output_tuples_V(compress_tuple_output_v),
        .Output_tuples_V_ap_vld(compress_tuple_output_v_ap_vld),
        .Output_tuples_V_ap_ack(compress_tuple_output_v_ap_ack),
        .Packet_input_V_dout(compress_packet_input_v_dout),
        .Packet_input_V_empty_n(compress_packet_input_v_empty_n),
        .Packet_input_V_read(compress_packet_input_v_read),
        .Packet_output_V(compress_packet_output_v),
        .Packet_output_V_ap_vld(compress_packet_output_v_ap_vld),
        .Packet_output_V_ap_ack(compress_packet_output_v_ap_ack)
);

assign compress_ap_clk = clk_line;
assign compress_ap_rst = rst;
assign compress_ap_start = 1;
assign compress_tuple_input_v_dout = tuple_fifo_dout;
assign compress_tuple_input_v_empty_n = ~tuple_fifo_empty;
assign compress_tuple_output_v_ap_ack = 1;
assign compress_packet_input_v_dout = packet_fifo_dout;
assign compress_packet_input_v_empty_n = ~packet_fifo_empty;
assign compress_packet_output_v_ap_ack = ~backpressure_in;

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
        .full(tuple_fifo_full),
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

assign tuple_fifo_wr_en = tuple_in_hdr_VALID;
assign tuple_fifo_din ={tuple_in_headerCompress_input_DATA, tuple_in_Parser_extracts_DATA, tuple_in_local_state_DATA, tuple_in_ioports_DATA, tuple_in_hdr_DATA, tuple_in_CheckTcp_fl_DATA, tuple_in_control_DATA};
assign tuple_fifo_rd_en = compress_tuple_input_v_read;

defparam packet_fifo.WRITE_DATA_WIDTH = `MEM_AXI_BUS_WIDTH + 7;
defparam packet_fifo.FIFO_WRITE_DEPTH = 2048;
defparam packet_fifo.PROG_FULL_THRESH = 1024;
defparam packet_fifo.PROG_EMPTY_THRESH = 1024;
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
        .full(packet_fifo_full),
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
assign packet_fifo_rd_en = compress_packet_input_v_read;

assign packet_in_packet_in_RDY = 1;

assign {packet_out_packet_out_SOF, packet_out_packet_out_EOF, packet_out_packet_out_DAT,
        packet_out_packet_out_CNT, packet_out_packet_out_ERR} = compress_packet_output_v;
assign packet_out_packet_out_VAL = compress_packet_output_v_ap_vld & ~backpressure_in;

assign {tuple_out_headerCompress_output_DATA, tuple_out_Parser_extracts_DATA, 
        tuple_out_local_state_DATA, tuple_out_ioports_DATA, 
        tuple_out_hdr_DATA, tuple_out_CheckTcp_fl_DATA, tuple_out_control_DATA} = compress_tuple_output_v;

assign tuple_out_hdr_VALID = compress_tuple_output_v_ap_vld;
assign tuple_out_control_VALID = compress_tuple_output_v_ap_vld;
assign tuple_out_CheckTcp_fl_VALID = compress_tuple_output_v_ap_vld;
assign tuple_out_ioports_VALID = compress_tuple_output_v_ap_vld;
assign tuple_out_local_state_VALID = compress_tuple_output_v_ap_vld;
assign tuple_out_Parser_extracts_VALID = compress_tuple_output_v_ap_vld;
assign tuple_out_headerCompress_output_VALID = compress_tuple_output_v_ap_vld;
assign backpressure_out = packet_fifo_almost_full;
endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/05/24 11:53:22
// by Barista HDL generation library, version TRUNK @ 1007984


