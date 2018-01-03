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

 tx latency = 7 (cycles)
 min latency = 6 (cycles)
 max latency = 6 (cycles)

input/output tuple 'control'
	section 4-bit field @ [22:19]
	activeBank 1-bit field @ [18:18]
	offset 14-bit field @ [17:4]
	done 1-bit field @ [3:3]
	errorCode 3-bit field @ [2:0]

input/output tuple 'hdr'
	ethernet_isValid 1-bit field @ [820:820]
	ethernet_dst 48-bit field @ [819:772]
	ethernet_src 48-bit field @ [771:724]
	ethernet_type 16-bit field @ [723:708]
	ipv4_isValid 1-bit field @ [707:707]
	ipv4_version 4-bit field @ [706:703]
	ipv4_ihl 4-bit field @ [702:699]
	ipv4_tos 8-bit field @ [698:691]
	ipv4_len 16-bit field @ [690:675]
	ipv4_id 16-bit field @ [674:659]
	ipv4_flags 3-bit field @ [658:656]
	ipv4_frag 13-bit field @ [655:643]
	ipv4_ttl 8-bit field @ [642:635]
	ipv4_proto 8-bit field @ [634:627]
	ipv4_chksum 16-bit field @ [626:611]
	ipv4_src 32-bit field @ [610:579]
	ipv4_dst 32-bit field @ [578:547]
	ipv6_isValid 1-bit field @ [546:546]
	ipv6_version 4-bit field @ [545:542]
	ipv6_tc 8-bit field @ [541:534]
	ipv6_fl 20-bit field @ [533:514]
	ipv6_plen 16-bit field @ [513:498]
	ipv6_nh 8-bit field @ [497:490]
	ipv6_hl 8-bit field @ [489:482]
	ipv6_src 128-bit field @ [481:354]
	ipv6_dst 128-bit field @ [353:226]
	tcp_isValid 1-bit field @ [225:225]
	tcp_sport 16-bit field @ [224:209]
	tcp_dport 16-bit field @ [208:193]
	tcp_seq 32-bit field @ [192:161]
	tcp_ack 32-bit field @ [160:129]
	tcp_dataofs 4-bit field @ [128:125]
	tcp_reserved 4-bit field @ [124:121]
	tcp_flags 8-bit field @ [120:113]
	tcp_window 16-bit field @ [112:97]
	tcp_chksum 16-bit field @ [96:81]
	tcp_urgptr 16-bit field @ [80:65]
	udp_isValid 1-bit field @ [64:64]
	udp_sport 16-bit field @ [63:48]
	udp_dport 16-bit field @ [47:32]
	udp_len 16-bit field @ [31:16]
	udp_chksum 16-bit field @ [15:0]

*/

`timescale 1 ps / 1 ps

module Forward_t (
	rst,
	clk_line,
	tuple_in_hdr_VALID,
	tuple_in_hdr_DATA,
	tuple_out_hdr_VALID,
	tuple_out_hdr_DATA
);

input rst ;
input clk_line ;
input tuple_in_hdr_VALID ;
input [820:0] tuple_in_hdr_DATA ;
output tuple_out_hdr_VALID ;
output [820:0] tuple_out_hdr_DATA ;

wire [22:0] tuple_in_control_DATA ;
wire tuple_in_valid ;
reg [22:0] tuple_in_control_i ;
wire [820:0] tuple_in_hdr ;
wire tuple_out_valid ;
wire tuple_out_hdr_VALID ;
wire [820:0] tuple_out_hdr_DATA ;
wire [820:0] tuple_out_hdr ;

assign tuple_in_control_DATA = 0 ;

assign tuple_in_valid = tuple_in_hdr_VALID ;

always @* begin
	tuple_in_control_i = tuple_in_control_DATA ;
	if ( ( ( tuple_in_control_DATA[3] == 0 ) && ( tuple_in_control_DATA[2:0] == 0 ) ) ) begin
		tuple_in_control_i[22:19] = 1 ;
	end
end

assign tuple_in_hdr = tuple_in_hdr_DATA ;

assign tuple_out_hdr_VALID = tuple_out_valid ;

assign tuple_out_hdr_DATA = tuple_out_hdr ;

Forward_t_Engine
Forward_t_inst
(
	.reset               	( rst ),
	.clock               	( clk_line ),
	.RX_TUPLE_VALID      	( tuple_in_valid ),
	.RX_TUPLE_control    	( tuple_in_control_i ),
	.TX_TUPLE_VALID      	( tuple_out_valid ),
	.TX_TUPLE_control    	(  ),
	.RX_TUPLE_hdr        	( tuple_in_hdr ),
	.TX_TUPLE_hdr        	( tuple_out_hdr ),
	.RX_PKT_RDY          	(  ),
	.TX_PKT_RDY          	( 1'd1 ),
	.RX_PKT_VLD          	( tuple_in_valid ),
	.RX_PKT_SOP          	( tuple_in_valid ),
	.RX_PKT_EOP          	( tuple_in_valid ),
	.RX_PKT_ERR          	( 1'b0 ),
	.RX_PKT_CNT          	( 1'b0 ),
	.RX_PKT_DAT          	( 8'b0 ),
	.TX_PKT_VLD          	(  ),
	.TX_PKT_SOP          	(  ),
	.TX_PKT_EOP          	(  ),
	.TX_PKT_ERR          	(  ),
	.TX_PKT_CNT          	(  ),
	.TX_PKT_DAT          	(  )
);


endmodule

// machine-generated file - do NOT modify by hand !
// File created on 2017/10/23 14:31:54
// by Barista HDL generation library, version TRUNK @ 1007984

