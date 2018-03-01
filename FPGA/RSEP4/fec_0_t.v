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
input [`FEC_OP_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_OFFSET_WIDTH:0] tuple_in_fec_input_DATA /* unused */ ;
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

wire Tuple_FIFO_wr_en;
wire Tuple_FIFO_rd_en;
wire [`FEC_OP_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_OFFSET_WIDTH:0] Tuple_FIFO_din;
wire [`FEC_OP_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_OFFSET_WIDTH:0] Tuple_FIFO_dout;
wire Tuple_FIFO_empty;
wire Tuple_FIFO_almost_full;

wire Data_FIFO_wr_en;
wire Data_FIFO_rd_en;
wire [70:0] Data_FIFO_din;
wire [70:0] Data_FIFO_dout;
wire Data_FIFO_empty;
wire Data_FIFO_almost_full;

wire Core_start;
wire Core_done;
wire Core_idle;
wire Core_ready;
wire [`FEC_OP_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_OFFSET_WIDTH:0] Core_tuple;
wire Core_tuple_ap_vld;
wire [70:0] Core_data_dout;
wire Core_data_empty_n;
wire Core_data_read;
wire [70:0] Core_parity;
wire Core_parity_ap_vld;
wire Core_parity_ap_ack;

reg Tuple_output;

defparam Tuple_FIFO.WRITE_DATA_WIDTH = `FEC_OP_WIDTH + `FEC_PACKET_INDEX_WIDTH + `FEC_OFFSET_WIDTH + 1; 
defparam Tuple_FIFO.FIFO_WRITE_DEPTH = 512; 
defparam Tuple_FIFO.PROG_FULL_THRESH = 287; 
defparam Tuple_FIFO.PROG_EMPTY_THRESH = 287; 
defparam Tuple_FIFO.READ_MODE = "fwft"; 
defparam Tuple_FIFO.WR_DATA_COUNT_WIDTH = 9; 
defparam Tuple_FIFO.RD_DATA_COUNT_WIDTH = 9; 
defparam Tuple_FIFO.DOUT_RESET_VALUE = "0"; 
defparam Tuple_FIFO.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync Tuple_FIFO (
	.wr_en(Tuple_FIFO_wr_en),
	.din(Tuple_FIFO_din),
	.rd_en(Tuple_FIFO_rd_en),
	.sleep(1'b0),
	.injectsbiterr(),
	.injectdbiterr(),
	.prog_empty(), 
	.dout(Tuple_FIFO_dout), 
	.empty(Tuple_FIFO_empty), 
	.prog_full(Tuple_FIFO_almost_full), 
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

defparam Data_FIFO.WRITE_DATA_WIDTH = 71; 
defparam Data_FIFO.FIFO_WRITE_DEPTH = 512; 
defparam Data_FIFO.PROG_FULL_THRESH = 287; 
defparam Data_FIFO.PROG_EMPTY_THRESH = 287; 
defparam Data_FIFO.READ_MODE = "fwft"; 
defparam Data_FIFO.WR_DATA_COUNT_WIDTH = 9; 
defparam Data_FIFO.RD_DATA_COUNT_WIDTH = 9; 
defparam Data_FIFO.DOUT_RESET_VALUE = "0"; 
defparam Data_FIFO.FIFO_MEMORY_TYPE = "bram"; 

xpm_fifo_sync Data_FIFO (
	.wr_en(Data_FIFO_wr_en),
	.din(Data_FIFO_din),
	.rd_en(Data_FIFO_rd_en),
	.sleep(1'b0),
	.injectsbiterr(),
	.injectdbiterr(),
	.prog_empty(), 
	.dout(Data_FIFO_dout), 
	.empty(Data_FIFO_empty), 
	.prog_full(Data_FIFO_almost_full), 
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

RSE_core Core
(
  .ap_clk(clk_line),
  .ap_rst(rst),
  .ap_start(Core_start),
  .ap_done(Core_done),
  .ap_idle(Core_idle),
  .ap_ready(Core_ready),
  .Tuple(Core_tuple),
  .Tuple_ap_vld(Core_tuple_ap_vld),
  .Data_dout(Core_data_dout),
  .Data_empty_n(Core_data_empty_n),
  .Data_read(Core_data_read),
  .Parity(Core_parity),
  .Parity_ap_vld(Core_parity_ap_vld),
  .Parity_ap_ack(Core_parity_ap_ack)
);

assign Tuple_FIFO_wr_en = tuple_in_fec_input_VALID;
assign Tuple_FIFO_din = tuple_in_fec_input_DATA;
assign Tuple_FIFO_rd_en = ~Tuple_output & ~Tuple_FIFO_empty;

assign Data_FIFO_wr_en = packet_in_packet_in_VAL;
assign Data_FIFO_din = {packet_in_packet_in_SOF, packet_in_packet_in_EOF, packet_in_packet_in_DAT,
                        packet_in_packet_in_CNT, packet_in_packet_in_ERR};
assign Data_FIFO_rd_en = Core_data_read;

assign Core_start = 1;
assign Core_tuple = Tuple_FIFO_dout;
assign Core_tuple_ap_vld = Tuple_FIFO_rd_en;
assign Core_data_dout = Data_FIFO_dout;
assign Core_data_empty_n = ~Data_FIFO_empty;
assign Core_parity_ap_ack = packet_out_packet_out_RDY;

assign packet_in_packet_in_RDY = ~(Tuple_FIFO_almost_full | Data_FIFO_almost_full);

assign {packet_out_packet_out_SOF, packet_out_packet_out_EOF, packet_out_packet_out_DAT,
        packet_out_packet_out_CNT, packet_out_packet_out_ERR} = Core_parity;
assign packet_out_packet_out_VAL = Core_parity_ap_vld;

assign tuple_out_fec_output_VALID = packet_out_packet_out_VAL & packet_out_packet_out_RDY &
                                    packet_out_packet_out_SOF;
assign tuple_out_fec_output_DATA = 0;
assign tuple_out_control_VALID = packet_out_packet_out_VAL & packet_out_packet_out_RDY &
                                 packet_out_packet_out_SOF;
assign tuple_out_control_DATA = 0;

always @( posedge clk_line ) begin
	if ( rst ) begin
		Tuple_output <= 0;
	end
	else  begin
		if ( Tuple_FIFO_rd_en ) begin
			Tuple_output <= 1;
		end
		else if ( Core_done ) begin
			Tuple_output <= 0;
		end
	end
end

endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/02/02 15:59:25
// by Barista HDL generation library, version TRUNK @ 1007984

