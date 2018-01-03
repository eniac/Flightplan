// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:sdnet:XilinxSwitch:1.0
// IP Revision: 3

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_XilinxSwitch_0_0 (
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

(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_in_packet_in TVALID" *)
input wire [0 : 0] packet_in_packet_in_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_in_packet_in TREADY" *)
output wire [0 : 0] packet_in_packet_in_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_in_packet_in TDATA" *)
input wire [63 : 0] packet_in_packet_in_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_in_packet_in TKEEP" *)
input wire [7 : 0] packet_in_packet_in_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_in_packet_in TLAST" *)
input wire [0 : 0] packet_in_packet_in_TLAST;
input wire [0 : 0] enable_processing;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_out_packet_out TVALID" *)
output wire [0 : 0] packet_out_packet_out_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_out_packet_out TREADY" *)
input wire [0 : 0] packet_out_packet_out_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_out_packet_out TDATA" *)
output wire [63 : 0] packet_out_packet_out_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_out_packet_out TKEEP" *)
output wire [7 : 0] packet_out_packet_out_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 packet_out_packet_out TLAST" *)
output wire [0 : 0] packet_out_packet_out_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 clk_line_rst RST" *)
input wire clk_line_rst;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk_line CLK" *)
input wire clk_line;
output wire [0 : 0] internal_rst_done;

  XilinxSwitch inst (
    .packet_in_packet_in_TVALID(packet_in_packet_in_TVALID),
    .packet_in_packet_in_TREADY(packet_in_packet_in_TREADY),
    .packet_in_packet_in_TDATA(packet_in_packet_in_TDATA),
    .packet_in_packet_in_TKEEP(packet_in_packet_in_TKEEP),
    .packet_in_packet_in_TLAST(packet_in_packet_in_TLAST),
    .enable_processing(enable_processing),
    .packet_out_packet_out_TVALID(packet_out_packet_out_TVALID),
    .packet_out_packet_out_TREADY(packet_out_packet_out_TREADY),
    .packet_out_packet_out_TDATA(packet_out_packet_out_TDATA),
    .packet_out_packet_out_TKEEP(packet_out_packet_out_TKEEP),
    .packet_out_packet_out_TLAST(packet_out_packet_out_TLAST),
    .clk_line_rst(clk_line_rst),
    .clk_line(clk_line),
    .internal_rst_done(internal_rst_done)
  );
endmodule
