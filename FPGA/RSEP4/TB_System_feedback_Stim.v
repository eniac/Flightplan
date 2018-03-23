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
Stimulus Generation Module
*/

`timescale 1 ps / 1 ps

module TB_System_feedback_Stim (
	file_done,
	fw_done,
	rst,
	clk_n,
	stim_eof,
	tuple_in_valid,
	tuple_in_ioports,
	packet_in_packet_in_TREADY,
	packet_in_packet_in_TVALID,
	packet_in_packet_in_TLAST,
	packet_in_packet_in_TKEEP,
	packet_in_packet_in_TDATA
);

input file_done ;
input fw_done ;
input rst ;
input clk_n ;
output stim_eof ;
output tuple_in_valid ;
output [7:0] tuple_in_ioports ;
input packet_in_packet_in_TREADY ;
output packet_in_packet_in_TVALID ;
output packet_in_packet_in_TLAST ;
output [7:0] packet_in_packet_in_TKEEP ;
output [63:0] packet_in_packet_in_TDATA ;

reg [31:0] fd_tup ;
reg [31:0] fd_pkt ;
reg stim_eof ;
reg tuple_in_valid ;
reg [7:0] tuple_in_ioports ;
reg packet_in_packet_in_TVALID ;
reg packet_in_packet_in_TLAST ;
reg [7:0] packet_in_packet_in_TKEEP ;
reg [63:0] packet_in_packet_in_TDATA ;
reg SOP ;
reg temp_last ;
reg [7:0] temp_keep ;
reg [63:0] temp_data ;
reg [31:0] cycles;

always @( posedge file_done ) begin
	fd_pkt <= $fopen("Packet_feedback_in.axi", "r") ;
	fd_tup <= $fopen("Tuple_in.txt", "r") ;
end

always @( posedge clk_n ) begin
	tuple_in_valid <= 0 ;
	if ( rst ) begin
		SOP <= 1 ;
		stim_eof <= 0 ;
		packet_in_packet_in_TLAST <= 0 ;
		packet_in_packet_in_TKEEP <= 0 ;
		packet_in_packet_in_TVALID <= 0 ;
		packet_in_packet_in_TDATA <= 0 ;
		cycles <= 0;
	end
	else  begin
		if ( ( ( packet_in_packet_in_TREADY && fw_done ) && ~stim_eof ) ) begin
			if ( cycles == 0 ) begin
				if ( ( 32'h3 != $fscanf(fd_pkt, "%x %x %x", temp_last, temp_keep, temp_data) ) ) begin
					stim_eof <= 1 ;
					$display("[%0t]  INFO: finished packet stimulus file", $time);
					packet_in_packet_in_TLAST <= 0 ;
					packet_in_packet_in_TKEEP <= 0 ;
					packet_in_packet_in_TVALID <= 0 ;
					packet_in_packet_in_TDATA <= 0 ;
				end
				else  begin
					packet_in_packet_in_TLAST <= temp_last ;
					packet_in_packet_in_TKEEP <= temp_keep ;
					packet_in_packet_in_TDATA <= temp_data ;
					packet_in_packet_in_TVALID <= 1 ;
					if ( SOP ) begin
						tuple_in_valid <= 1 ;
						if ( ( 32'h1 != $fscanf(fd_tup, "%x ", tuple_in_ioports) ) ) begin
							tuple_in_ioports <= 0 ;
							$display("[%0t] ERROR: error when reading tuple stimulus file", $time);
							$finish(1);
						end
					end
					SOP <= packet_in_packet_in_TLAST ;
					if ( temp_last ) begin
						cycles <= 0;
					end
				end
			end
			else  begin
				cycles <= cycles - 1;
				packet_in_packet_in_TLAST <= 0 ;
				packet_in_packet_in_TKEEP <= 0 ;
				packet_in_packet_in_TVALID <= 0 ;
				packet_in_packet_in_TDATA <= 0 ;
			end
		end
	end
end


endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/01/30 15:49:28
// by Barista HDL generation library, version TRUNK @ 1007984

