// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2017.1
// Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

module aesl_mux_load_4i368P (
        empty,
        parity_buffer_3,
        parity_buffer_0,
        parity_buffer_1,
        parity_buffer_2,
        ap_return
);


input  [1:0] empty;
input  [367:0] parity_buffer_3;
input  [367:0] parity_buffer_0;
input  [367:0] parity_buffer_1;
input  [367:0] parity_buffer_2;
output  [367:0] ap_return;

wire   [0:0] sel_tmp_fu_46_p2;
wire   [0:0] or_cond_fu_72_p2;
wire   [0:0] sel_tmp4_fu_58_p2;
wire   [0:0] sel_tmp2_fu_52_p2;
wire   [367:0] newSel_fu_64_p3;
wire   [367:0] newSel1_fu_78_p3;

assign ap_return = ((or_cond_fu_72_p2[0:0] === 1'b1) ? newSel_fu_64_p3 : newSel1_fu_78_p3);

assign newSel1_fu_78_p3 = ((sel_tmp_fu_46_p2[0:0] === 1'b1) ? parity_buffer_0 : parity_buffer_3);

assign newSel_fu_64_p3 = ((sel_tmp4_fu_58_p2[0:0] === 1'b1) ? parity_buffer_2 : parity_buffer_1);

assign or_cond_fu_72_p2 = (sel_tmp4_fu_58_p2 | sel_tmp2_fu_52_p2);

assign sel_tmp2_fu_52_p2 = ((empty == 2'd1) ? 1'b1 : 1'b0);

assign sel_tmp4_fu_58_p2 = ((empty == 2'd2) ? 1'b1 : 1'b0);

assign sel_tmp_fu_46_p2 = ((empty == 2'd0) ? 1'b1 : 1'b0);

endmodule //aesl_mux_load_4i368P