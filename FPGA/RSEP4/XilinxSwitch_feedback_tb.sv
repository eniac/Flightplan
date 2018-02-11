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

module XilinxSwitch_feedback_tb;


reg clk_line /* undriven */ ;
reg clk_line_rst /* undriven */ ;
wire [0:0] packet_in_packet_in_TVALID ;
wire [0:0] packet_in_packet_in_TREADY ;
wire [63:0] packet_in_packet_in_TDATA ;
wire [7:0] packet_in_packet_in_TKEEP ;
wire [0:0] packet_in_packet_in_TLAST ;
wire [0:0] tuple_in_ioports_VALID ;
wire [7:0] tuple_in_ioports_DATA ;
wire [0:0] enable_processing ;
wire [0:0] packet_out_packet_out_TVALID ;
wire [0:0] packet_out_packet_out_TREADY ;
wire [63:0] packet_out_packet_out_TDATA ;
wire [7:0] packet_out_packet_out_TKEEP ;
wire [0:0] packet_out_packet_out_TLAST ;
wire [0:0] tuple_out_ioports_VALID ;
wire [7:0] tuple_out_ioports_DATA ;
wire [0:0] rse_out_TVALID ;
wire [0:0] rse_out_TREADY ;
wire [63:0] rse_out_TDATA ;
wire [7:0] rse_out_TKEEP ;
wire [0:0] rse_out_TLAST ;
wire [0:0] rse_in_TVALID ;
wire [0:0] rse_in_TREADY ;
wire [63:0] rse_in_TDATA ;
wire [7:0] rse_in_TKEEP ;
wire [0:0] rse_in_TLAST ;
wire [0:0] internal_rst_done /* unused */ ;
reg fw_done /* undriven */ ;
reg stim_file /* undriven */ ;
reg check_file /* undriven */ ;
reg end_sim_after_check /* undriven */ ;
wire stim_eof ;
wire tuple_in_valid ;
wire check_eof ;
wire tuple_out_valid ;
wire packet_out_avail /* unused */ ;
reg [31:0] idleCount ;
reg firstPacketOut ;

// black box
XilinxSwitch
XilinxSwitch_i
(
	.packet_in_packet_in_TVALID	( rse_in_TVALID ),
	.packet_in_packet_in_TREADY	( rse_in_TREADY ),
	.packet_in_packet_in_TDATA	( rse_in_TDATA ),
	.packet_in_packet_in_TKEEP	( rse_in_TKEEP ),
	.packet_in_packet_in_TLAST	( rse_in_TLAST ),
	.tuple_in_ioports_VALID	( tuple_in_ioports_VALID ),
	.tuple_in_ioports_DATA	( tuple_in_ioports_DATA ),
	.enable_processing   	( enable_processing ),
	.packet_out_packet_out_TVALID	( rse_out_TVALID ),
	.packet_out_packet_out_TREADY	( rse_out_TREADY ),
	.packet_out_packet_out_TDATA	( rse_out_TDATA ),
	.packet_out_packet_out_TKEEP	( rse_out_TKEEP ),
	.packet_out_packet_out_TLAST	( rse_out_TLAST ),
	.tuple_out_ioports_VALID	( tuple_out_ioports_VALID ),
	.tuple_out_ioports_DATA	( tuple_out_ioports_DATA ),
	.clk_line_rst        	( clk_line_rst ),
	.clk_line            	( clk_line ),
	.internal_rst_done   	( internal_rst_done )
);

RSEFeedback
RSEFeedback_i
(
	.clk_line            	( clk_line ),
	.clk_line_rst        	( clk_line_rst ),
	.enable_processing   	( enable_processing ),
	.internal_rst_done   	( internal_rst_done ),
	.axis_in_TVALID		( packet_in_packet_in_TVALID ),
	.axis_in_TREADY		( packet_in_packet_in_TREADY ),
	.axis_in_TDATA		( packet_in_packet_in_TDATA ),
	.axis_in_TKEEP		( packet_in_packet_in_TKEEP ),
	.axis_in_TLAST		( packet_in_packet_in_TLAST ),
	.rse_in_TVALID		( rse_out_TVALID ),
	.rse_in_TREADY		( rse_out_TREADY ),
	.rse_in_TDATA		( rse_out_TDATA ),
	.rse_in_TKEEP		( rse_out_TKEEP ),
	.rse_in_TLAST		( rse_out_TLAST ),
	.tuple_in_VALID		( tuple_out_ioports_VALID ),
	.tuple_in_DATA		( tuple_out_ioports_DATA ),
	.axis_out_TVALID	( packet_out_packet_out_TVALID ),
	.axis_out_TREADY	( packet_out_packet_out_TREADY ),
	.axis_out_TDATA		( packet_out_packet_out_TDATA ),
	.axis_out_TKEEP		( packet_out_packet_out_TKEEP ),
	.axis_out_TLAST		( packet_out_packet_out_TLAST ),
	.rse_out_TVALID		( rse_in_TVALID ),
	.rse_out_TREADY		( rse_in_TREADY ),
	.rse_out_TDATA		( rse_in_TDATA ),
	.rse_out_TKEEP		( rse_in_TKEEP ),
	.rse_out_TLAST		( rse_in_TLAST ),
	.tuple_out_VALID	( tuple_in_ioports_VALID ),
	.tuple_out_DATA		( tuple_in_ioports_DATA )
);


assign packet_out_packet_out_TREADY = 1'd1 ;

assign enable_processing = 1'd1 ;

TB_System_feedback_Stim
TB_System_feedback_Stim_i
(
	.tuple_in_ioports    	( ),
	.clk_n               	( clk_line ),
	.rst                 	( clk_line_rst ),
	.fw_done             	( fw_done ),
	.file_done           	( stim_file ),
	.stim_eof            	( stim_eof ),
	.tuple_in_valid      	( ),
	.packet_in_packet_in_TREADY	( packet_in_packet_in_TREADY ),
	.packet_in_packet_in_TVALID	( packet_in_packet_in_TVALID ),
	.packet_in_packet_in_TLAST	( packet_in_packet_in_TLAST ),
	.packet_in_packet_in_TKEEP	( packet_in_packet_in_TKEEP ),
	.packet_in_packet_in_TDATA	( packet_in_packet_in_TDATA )
);

assign tuple_in_ioports_VALID = tuple_in_valid ;

Check
TB_System_Check_i
(
	.packet_out_tready   	( rse_out_TREADY ),
	.packet_out_tvalid   	( rse_out_TVALID ),
	.packet_out_tlast    	( rse_out_TLAST ),
	.packet_out_tkeep    	( rse_out_TKEEP ),
	.packet_out_tdata    	( rse_out_TDATA ),
	.tuple_out_ioports   	( tuple_out_ioports_DATA ),
	.clk_n               	( clk_line ),
	.rst                 	( clk_line_rst ),
	.file_done           	( check_file ),
	.fw_done             	( fw_done ),
	.check_eof           	( check_eof ),
	.tuple_out_valid     	( tuple_out_valid ),
	.packet_out_avail    	( packet_out_avail )
);

assign tuple_out_valid = tuple_out_ioports_VALID ;

always @( posedge clk_line ) begin
	if ( clk_line_rst ) begin
		idleCount <= 0 ;
		firstPacketOut <= 0 ;
	end
	else  begin
		if ( ( packet_out_packet_out_TLAST && packet_out_packet_out_TVALID ) ) begin
			idleCount <= 0 ;
			firstPacketOut <= 1 ;
		end
		else  begin
			if ( firstPacketOut ) begin
				firstPacketOut <= 1 ;
				idleCount <= ( idleCount + 1 ) ;
				if ( ( ( ( ( ( idleCount == 1000 ) && check_file ) && fw_done ) && stim_eof ) && end_sim_after_check ) ) begin
					$display("[%0t]  INFO: stopping simulation after 1000 idle cycles", $time);
					if ( check_eof ) begin
						$display("[%0t]  INFO: all expected data successfully received", $time);
						$display("[%0t]  INFO: TEST PASSED", $time);
					end
					else  begin
						$display("[%0t] ERROR: some expected data not received", $time);
						$display("[%0t] ERROR: TEST FAILED", $time);
					end
					$finish(1);
				end
			end
		end
	end
end



always begin 
  #(3333 / 2) clk_line =  0; 
  #(3333 / 2) clk_line =  1; 
end


initial begin 
clk_line_rst = 1; 
#1000000 clk_line_rst = 0; 
end 



reg [31:0] read_data;
reg [1:0] read_resp;
reg [1:0] bresp;




















initial begin
    fw_done = 0;
    stim_file = 1;
    check_file = 1;
    end_sim_after_check = 1;
    wait(internal_rst_done);
    #10000 
    #1000 fw_done = 1;
end



endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2018/02/07 17:05:27
// by Barista HDL generation library, version TRUNK @ 1007984
