// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2017.1
// Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

#ifndef _RSE_core_HH_
#define _RSE_core_HH_

#include "systemc.h"
#include "AESL_pkg.h"

#include "aesl_mux_load_4i368P.h"
#include "GF_multiply.h"

namespace ap_rtl {

struct RSE_core : public sc_module {
    // Port declarations 12
    sc_in_clk ap_clk;
    sc_in< sc_logic > ap_rst;
    sc_in< sc_logic > ap_start;
    sc_out< sc_logic > ap_done;
    sc_out< sc_logic > ap_idle;
    sc_out< sc_logic > ap_ready;
    sc_in< sc_lv<8> > operation;
    sc_in< sc_lv<32> > index;
    sc_in< sc_lv<1> > is_parity;
    sc_in< sc_lv<368> > data;
    sc_out< sc_lv<368> > parity;
    sc_out< sc_logic > parity_ap_vld;
    sc_signal< sc_lv<8> > ap_var_for_const0;
    sc_signal< sc_lv<8> > ap_var_for_const1;
    sc_signal< sc_lv<8> > ap_var_for_const2;
    sc_signal< sc_lv<8> > ap_var_for_const3;
    sc_signal< sc_lv<8> > ap_var_for_const4;
    sc_signal< sc_lv<8> > ap_var_for_const5;
    sc_signal< sc_lv<8> > ap_var_for_const6;
    sc_signal< sc_lv<8> > ap_var_for_const7;
    sc_signal< sc_lv<8> > ap_var_for_const8;
    sc_signal< sc_lv<8> > ap_var_for_const9;
    sc_signal< sc_lv<8> > ap_var_for_const10;
    sc_signal< sc_lv<8> > ap_var_for_const11;
    sc_signal< sc_lv<8> > ap_var_for_const12;
    sc_signal< sc_lv<8> > ap_var_for_const13;
    sc_signal< sc_lv<8> > ap_var_for_const14;
    sc_signal< sc_lv<8> > ap_var_for_const15;
    sc_signal< sc_lv<8> > ap_var_for_const16;
    sc_signal< sc_lv<8> > ap_var_for_const17;
    sc_signal< sc_lv<8> > ap_var_for_const18;
    sc_signal< sc_lv<8> > ap_var_for_const19;
    sc_signal< sc_lv<8> > ap_var_for_const20;
    sc_signal< sc_lv<8> > ap_var_for_const21;
    sc_signal< sc_lv<8> > ap_var_for_const22;
    sc_signal< sc_lv<8> > ap_var_for_const23;
    sc_signal< sc_lv<8> > ap_var_for_const24;
    sc_signal< sc_lv<8> > ap_var_for_const25;
    sc_signal< sc_lv<8> > ap_var_for_const26;
    sc_signal< sc_lv<8> > ap_var_for_const27;
    sc_signal< sc_lv<8> > ap_var_for_const28;
    sc_signal< sc_lv<8> > ap_var_for_const29;


    // Module declarations
    RSE_core(sc_module_name name);
    SC_HAS_PROCESS(RSE_core);

    ~RSE_core();

    sc_trace_file* mVcdFile;

    ofstream mHdltvinHandle;
    ofstream mHdltvoutHandle;
    aesl_mux_load_4i368P* tmp_aesl_mux_load_4i368P_fu_208;
    GF_multiply* grp_GF_multiply_fu_222;
    GF_multiply* grp_GF_multiply_fu_233;
    GF_multiply* grp_GF_multiply_fu_244;
    GF_multiply* grp_GF_multiply_fu_255;
    GF_multiply* grp_GF_multiply_fu_266;
    GF_multiply* grp_GF_multiply_fu_277;
    GF_multiply* grp_GF_multiply_fu_288;
    GF_multiply* grp_GF_multiply_fu_299;
    GF_multiply* grp_GF_multiply_fu_310;
    GF_multiply* grp_GF_multiply_fu_321;
    GF_multiply* grp_GF_multiply_fu_332;
    GF_multiply* grp_GF_multiply_fu_343;
    GF_multiply* grp_GF_multiply_fu_354;
    GF_multiply* grp_GF_multiply_fu_365;
    GF_multiply* grp_GF_multiply_fu_376;
    GF_multiply* grp_GF_multiply_fu_387;
    GF_multiply* grp_GF_multiply_fu_398;
    GF_multiply* grp_GF_multiply_fu_409;
    GF_multiply* grp_GF_multiply_fu_420;
    GF_multiply* grp_GF_multiply_fu_431;
    GF_multiply* grp_GF_multiply_fu_442;
    GF_multiply* grp_GF_multiply_fu_453;
    GF_multiply* grp_GF_multiply_fu_464;
    GF_multiply* grp_GF_multiply_fu_475;
    GF_multiply* grp_GF_multiply_fu_486;
    GF_multiply* grp_GF_multiply_fu_497;
    GF_multiply* grp_GF_multiply_fu_508;
    GF_multiply* grp_GF_multiply_fu_519;
    GF_multiply* grp_GF_multiply_fu_530;
    GF_multiply* grp_GF_multiply_fu_541;
    GF_multiply* grp_GF_multiply_fu_552;
    GF_multiply* grp_GF_multiply_fu_563;
    sc_signal< sc_lv<4> > ap_CS_fsm;
    sc_signal< sc_logic > ap_CS_fsm_state1;
    sc_signal< sc_lv<368> > data_buffer_0;
    sc_signal< sc_lv<368> > data_buffer_1;
    sc_signal< sc_lv<368> > data_buffer_2;
    sc_signal< sc_lv<368> > data_buffer_3;
    sc_signal< sc_lv<368> > data_buffer_4;
    sc_signal< sc_lv<368> > data_buffer_5;
    sc_signal< sc_lv<368> > data_buffer_6;
    sc_signal< sc_lv<368> > data_buffer_7;
    sc_signal< sc_lv<368> > parity_buffer_0;
    sc_signal< sc_lv<368> > parity_buffer_1;
    sc_signal< sc_lv<368> > parity_buffer_2;
    sc_signal< sc_lv<368> > parity_buffer_3;
    sc_signal< sc_lv<9> > i_reg_197;
    sc_signal< sc_lv<8> > operation_read_read_fu_184_p2;
    sc_signal< sc_lv<368> > data_buffer_0_load_reg_1058;
    sc_signal< sc_lv<368> > data_buffer_1_load_reg_1063;
    sc_signal< sc_lv<368> > data_buffer_2_load_reg_1068;
    sc_signal< sc_lv<368> > data_buffer_3_load_reg_1073;
    sc_signal< sc_lv<368> > data_buffer_4_load_reg_1078;
    sc_signal< sc_lv<368> > data_buffer_5_load_reg_1083;
    sc_signal< sc_lv<368> > data_buffer_6_load_reg_1088;
    sc_signal< sc_lv<368> > data_buffer_7_load_reg_1093;
    sc_signal< sc_lv<1> > tmp_3_fu_663_p2;
    sc_signal< sc_lv<1> > tmp_3_reg_1101;
    sc_signal< sc_logic > ap_CS_fsm_pp0_stage0;
    sc_signal< bool > ap_block_state2_pp0_stage0_iter0;
    sc_signal< bool > ap_block_state3_pp0_stage0_iter1;
    sc_signal< bool > ap_block_state4_pp0_stage0_iter2;
    sc_signal< bool > ap_block_state5_pp0_stage0_iter3;
    sc_signal< bool > ap_block_pp0_stage0_11001;
    sc_signal< sc_lv<1> > ap_reg_pp0_iter1_tmp_3_reg_1101;
    sc_signal< sc_lv<1> > ap_reg_pp0_iter2_tmp_3_reg_1101;
    sc_signal< sc_lv<368> > tmp_4_fu_669_p1;
    sc_signal< sc_lv<368> > tmp_4_reg_1105;
    sc_signal< sc_lv<368> > ap_reg_pp0_iter1_tmp_4_reg_1105;
    sc_signal< sc_lv<368> > ap_reg_pp0_iter2_tmp_4_reg_1105;
    sc_signal< sc_lv<8> > input_0_fu_678_p1;
    sc_signal< sc_lv<8> > input_0_reg_1114;
    sc_signal< sc_lv<8> > input_1_fu_687_p1;
    sc_signal< sc_lv<8> > input_1_reg_1122;
    sc_signal< sc_lv<8> > input_2_fu_696_p1;
    sc_signal< sc_lv<8> > input_2_reg_1130;
    sc_signal< sc_lv<8> > input_3_fu_705_p1;
    sc_signal< sc_lv<8> > input_3_reg_1138;
    sc_signal< sc_lv<8> > input_4_fu_714_p1;
    sc_signal< sc_lv<8> > input_4_reg_1146;
    sc_signal< sc_lv<8> > input_5_fu_723_p1;
    sc_signal< sc_lv<8> > input_5_reg_1154;
    sc_signal< sc_lv<8> > input_6_fu_732_p1;
    sc_signal< sc_lv<8> > input_6_reg_1162;
    sc_signal< sc_lv<8> > input_7_fu_741_p1;
    sc_signal< sc_lv<8> > input_7_reg_1170;
    sc_signal< sc_lv<9> > i_1_fu_745_p2;
    sc_signal< sc_logic > ap_enable_reg_pp0_iter0;
    sc_signal< bool > ap_block_pp0_stage0_subdone;
    sc_signal< sc_logic > ap_condition_pp0_exit_iter0_state2;
    sc_signal< sc_logic > ap_enable_reg_pp0_iter1;
    sc_signal< sc_logic > ap_enable_reg_pp0_iter2;
    sc_signal< sc_logic > ap_enable_reg_pp0_iter3;
    sc_signal< sc_lv<2> > tmp_aesl_mux_load_4i368P_fu_208_empty;
    sc_signal< sc_lv<368> > tmp_aesl_mux_load_4i368P_fu_208_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_222_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_222_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_222_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_222_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_222_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_233_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_233_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_233_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_233_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_233_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_244_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_244_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_244_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_244_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_244_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_255_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_255_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_255_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_255_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_255_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_266_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_266_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_266_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_266_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_266_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_277_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_277_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_277_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_277_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_277_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_288_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_288_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_288_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_288_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_288_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_299_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_299_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_299_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_299_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_299_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_310_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_310_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_310_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_310_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_310_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_321_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_321_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_321_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_321_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_321_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_332_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_332_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_332_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_332_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_332_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_343_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_343_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_343_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_343_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_343_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_354_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_354_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_354_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_354_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_354_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_365_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_365_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_365_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_365_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_365_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_376_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_376_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_376_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_376_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_376_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_387_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_387_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_387_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_387_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_387_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_398_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_398_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_398_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_398_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_398_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_409_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_409_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_409_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_409_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_409_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_420_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_420_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_420_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_420_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_420_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_431_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_431_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_431_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_431_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_431_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_442_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_442_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_442_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_442_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_442_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_453_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_453_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_453_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_453_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_453_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_464_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_464_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_464_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_464_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_464_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_475_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_475_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_475_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_475_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_475_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_486_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_486_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_486_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_486_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_486_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_497_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_497_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_497_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_497_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_497_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_508_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_508_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_508_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_508_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_508_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_519_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_519_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_519_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_519_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_519_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_530_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_530_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_530_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_530_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_530_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_541_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_541_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_541_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_541_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_541_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_552_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_552_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_552_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_552_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_552_ap_return;
    sc_signal< sc_logic > grp_GF_multiply_fu_563_ap_start;
    sc_signal< sc_logic > grp_GF_multiply_fu_563_ap_done;
    sc_signal< sc_logic > grp_GF_multiply_fu_563_ap_idle;
    sc_signal< sc_logic > grp_GF_multiply_fu_563_ap_ready;
    sc_signal< sc_lv<8> > grp_GF_multiply_fu_563_ap_return;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_222_ap_start;
    sc_signal< bool > ap_block_pp0_stage0;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_233_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_244_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_255_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_266_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_277_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_288_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_299_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_310_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_321_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_332_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_343_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_354_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_365_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_376_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_387_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_398_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_409_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_420_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_431_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_442_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_453_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_464_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_475_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_486_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_497_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_508_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_519_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_530_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_541_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_552_ap_start;
    sc_signal< sc_logic > ap_reg_grp_GF_multiply_fu_563_ap_start;
    sc_signal< sc_lv<3> > tmp_10_fu_611_p1;
    sc_signal< sc_lv<368> > tmp_9_fu_949_p2;
    sc_signal< sc_lv<368> > tmp_13_1_fu_980_p2;
    sc_signal< sc_lv<368> > tmp_13_2_fu_1011_p2;
    sc_signal< sc_lv<368> > tmp_13_3_fu_1042_p2;
    sc_signal< sc_lv<368> > tmp_8_fu_673_p2;
    sc_signal< sc_lv<368> > tmp_8_1_fu_682_p2;
    sc_signal< sc_lv<368> > tmp_8_2_fu_691_p2;
    sc_signal< sc_lv<368> > tmp_8_3_fu_700_p2;
    sc_signal< sc_lv<368> > tmp_8_4_fu_709_p2;
    sc_signal< sc_lv<368> > tmp_8_5_fu_718_p2;
    sc_signal< sc_lv<368> > tmp_8_6_fu_727_p2;
    sc_signal< sc_lv<368> > tmp_8_7_fu_736_p2;
    sc_signal< sc_lv<8> > tmp3_fu_757_p2;
    sc_signal< sc_lv<8> > tmp2_fu_751_p2;
    sc_signal< sc_lv<8> > tmp6_fu_775_p2;
    sc_signal< sc_lv<8> > tmp5_fu_769_p2;
    sc_signal< sc_lv<8> > tmp4_fu_781_p2;
    sc_signal< sc_lv<8> > tmp1_fu_763_p2;
    sc_signal< sc_lv<8> > tmp9_fu_799_p2;
    sc_signal< sc_lv<8> > tmp8_fu_793_p2;
    sc_signal< sc_lv<8> > tmp12_fu_817_p2;
    sc_signal< sc_lv<8> > tmp11_fu_811_p2;
    sc_signal< sc_lv<8> > tmp10_fu_823_p2;
    sc_signal< sc_lv<8> > tmp7_fu_805_p2;
    sc_signal< sc_lv<8> > tmp15_fu_841_p2;
    sc_signal< sc_lv<8> > tmp14_fu_835_p2;
    sc_signal< sc_lv<8> > tmp18_fu_859_p2;
    sc_signal< sc_lv<8> > tmp17_fu_853_p2;
    sc_signal< sc_lv<8> > tmp16_fu_865_p2;
    sc_signal< sc_lv<8> > tmp13_fu_847_p2;
    sc_signal< sc_lv<8> > tmp21_fu_883_p2;
    sc_signal< sc_lv<8> > tmp20_fu_877_p2;
    sc_signal< sc_lv<8> > tmp24_fu_901_p2;
    sc_signal< sc_lv<8> > tmp23_fu_895_p2;
    sc_signal< sc_lv<8> > tmp22_fu_907_p2;
    sc_signal< sc_lv<8> > tmp19_fu_889_p2;
    sc_signal< sc_lv<368> > tmp_5_fu_919_p2;
    sc_signal< sc_lv<368> > tmp_6_fu_924_p2;
    sc_signal< sc_lv<8> > output_0_fu_787_p2;
    sc_signal< sc_lv<368> > tmp_2_fu_940_p1;
    sc_signal< sc_lv<368> > tmp_7_fu_944_p2;
    sc_signal< sc_lv<368> > tmp_s_fu_934_p2;
    sc_signal< sc_lv<8> > output_1_fu_829_p2;
    sc_signal< sc_lv<368> > tmp_11_1_fu_971_p1;
    sc_signal< sc_lv<368> > tmp_12_1_fu_975_p2;
    sc_signal< sc_lv<368> > tmp_10_1_fu_965_p2;
    sc_signal< sc_lv<8> > output_2_fu_871_p2;
    sc_signal< sc_lv<368> > tmp_11_2_fu_1002_p1;
    sc_signal< sc_lv<368> > tmp_12_2_fu_1006_p2;
    sc_signal< sc_lv<368> > tmp_10_2_fu_996_p2;
    sc_signal< sc_lv<8> > output_3_fu_913_p2;
    sc_signal< sc_lv<368> > tmp_11_3_fu_1033_p1;
    sc_signal< sc_lv<368> > tmp_12_3_fu_1037_p2;
    sc_signal< sc_lv<368> > tmp_10_3_fu_1027_p2;
    sc_signal< sc_logic > ap_CS_fsm_state6;
    sc_signal< sc_lv<4> > ap_NS_fsm;
    sc_signal< sc_logic > ap_idle_pp0;
    sc_signal< sc_logic > ap_enable_pp0;
    static const sc_logic ap_const_logic_1;
    static const sc_logic ap_const_logic_0;
    static const sc_lv<4> ap_ST_fsm_state1;
    static const sc_lv<4> ap_ST_fsm_pp0_stage0;
    static const sc_lv<4> ap_ST_fsm_state6;
    static const sc_lv<4> ap_ST_fsm_state7;
    static const sc_lv<32> ap_const_lv32_0;
    static const bool ap_const_boolean_1;
    static const sc_lv<8> ap_const_lv8_2;
    static const sc_lv<32> ap_const_lv32_1;
    static const bool ap_const_boolean_0;
    static const sc_lv<1> ap_const_lv1_1;
    static const sc_lv<1> ap_const_lv1_0;
    static const sc_lv<9> ap_const_lv9_0;
    static const sc_lv<8> ap_const_lv8_4;
    static const sc_lv<8> ap_const_lv8_4C;
    static const sc_lv<8> ap_const_lv8_67;
    static const sc_lv<8> ap_const_lv8_95;
    static const sc_lv<8> ap_const_lv8_33;
    static const sc_lv<8> ap_const_lv8_F8;
    static const sc_lv<8> ap_const_lv8_AA;
    static const sc_lv<8> ap_const_lv8_61;
    static const sc_lv<8> ap_const_lv8_36;
    static const sc_lv<8> ap_const_lv8_C4;
    static const sc_lv<8> ap_const_lv8_A2;
    static const sc_lv<8> ap_const_lv8_23;
    static const sc_lv<8> ap_const_lv8_E4;
    static const sc_lv<8> ap_const_lv8_EB;
    static const sc_lv<8> ap_const_lv8_29;
    static const sc_lv<8> ap_const_lv8_2F;
    static const sc_lv<8> ap_const_lv8_D6;
    static const sc_lv<8> ap_const_lv8_2E;
    static const sc_lv<8> ap_const_lv8_4F;
    static const sc_lv<8> ap_const_lv8_78;
    static const sc_lv<8> ap_const_lv8_4E;
    static const sc_lv<8> ap_const_lv8_6E;
    static const sc_lv<8> ap_const_lv8_96;
    static const sc_lv<8> ap_const_lv8_7D;
    static const sc_lv<8> ap_const_lv8_5F;
    static const sc_lv<8> ap_const_lv8_EA;
    static const sc_lv<8> ap_const_lv8_AE;
    static const sc_lv<8> ap_const_lv8_5C;
    static const sc_lv<8> ap_const_lv8_EC;
    static const sc_lv<8> ap_const_lv8_D5;
    static const sc_lv<8> ap_const_lv8_65;
    static const sc_lv<8> ap_const_lv8_1;
    static const sc_lv<3> ap_const_lv3_0;
    static const sc_lv<3> ap_const_lv3_1;
    static const sc_lv<3> ap_const_lv3_2;
    static const sc_lv<3> ap_const_lv3_3;
    static const sc_lv<3> ap_const_lv3_4;
    static const sc_lv<3> ap_const_lv3_5;
    static const sc_lv<3> ap_const_lv3_6;
    static const sc_lv<3> ap_const_lv3_7;
    static const sc_lv<9> ap_const_lv9_170;
    static const sc_lv<9> ap_const_lv9_8;
    static const sc_lv<368> ap_const_lv368_lc_2;
    static const sc_lv<368> ap_const_lv368_lc_3;
    static const sc_lv<32> ap_const_lv32_2;
    // Thread declarations
    void thread_ap_var_for_const0();
    void thread_ap_var_for_const1();
    void thread_ap_var_for_const2();
    void thread_ap_var_for_const3();
    void thread_ap_var_for_const4();
    void thread_ap_var_for_const5();
    void thread_ap_var_for_const6();
    void thread_ap_var_for_const7();
    void thread_ap_var_for_const8();
    void thread_ap_var_for_const9();
    void thread_ap_var_for_const10();
    void thread_ap_var_for_const11();
    void thread_ap_var_for_const12();
    void thread_ap_var_for_const13();
    void thread_ap_var_for_const14();
    void thread_ap_var_for_const15();
    void thread_ap_var_for_const16();
    void thread_ap_var_for_const17();
    void thread_ap_var_for_const18();
    void thread_ap_var_for_const19();
    void thread_ap_var_for_const20();
    void thread_ap_var_for_const21();
    void thread_ap_var_for_const22();
    void thread_ap_var_for_const23();
    void thread_ap_var_for_const24();
    void thread_ap_var_for_const25();
    void thread_ap_var_for_const26();
    void thread_ap_var_for_const27();
    void thread_ap_var_for_const28();
    void thread_ap_var_for_const29();
    void thread_ap_clk_no_reset_();
    void thread_ap_CS_fsm_pp0_stage0();
    void thread_ap_CS_fsm_state1();
    void thread_ap_CS_fsm_state6();
    void thread_ap_block_pp0_stage0();
    void thread_ap_block_pp0_stage0_11001();
    void thread_ap_block_pp0_stage0_subdone();
    void thread_ap_block_state2_pp0_stage0_iter0();
    void thread_ap_block_state3_pp0_stage0_iter1();
    void thread_ap_block_state4_pp0_stage0_iter2();
    void thread_ap_block_state5_pp0_stage0_iter3();
    void thread_ap_condition_pp0_exit_iter0_state2();
    void thread_ap_done();
    void thread_ap_enable_pp0();
    void thread_ap_idle();
    void thread_ap_idle_pp0();
    void thread_ap_ready();
    void thread_grp_GF_multiply_fu_222_ap_start();
    void thread_grp_GF_multiply_fu_233_ap_start();
    void thread_grp_GF_multiply_fu_244_ap_start();
    void thread_grp_GF_multiply_fu_255_ap_start();
    void thread_grp_GF_multiply_fu_266_ap_start();
    void thread_grp_GF_multiply_fu_277_ap_start();
    void thread_grp_GF_multiply_fu_288_ap_start();
    void thread_grp_GF_multiply_fu_299_ap_start();
    void thread_grp_GF_multiply_fu_310_ap_start();
    void thread_grp_GF_multiply_fu_321_ap_start();
    void thread_grp_GF_multiply_fu_332_ap_start();
    void thread_grp_GF_multiply_fu_343_ap_start();
    void thread_grp_GF_multiply_fu_354_ap_start();
    void thread_grp_GF_multiply_fu_365_ap_start();
    void thread_grp_GF_multiply_fu_376_ap_start();
    void thread_grp_GF_multiply_fu_387_ap_start();
    void thread_grp_GF_multiply_fu_398_ap_start();
    void thread_grp_GF_multiply_fu_409_ap_start();
    void thread_grp_GF_multiply_fu_420_ap_start();
    void thread_grp_GF_multiply_fu_431_ap_start();
    void thread_grp_GF_multiply_fu_442_ap_start();
    void thread_grp_GF_multiply_fu_453_ap_start();
    void thread_grp_GF_multiply_fu_464_ap_start();
    void thread_grp_GF_multiply_fu_475_ap_start();
    void thread_grp_GF_multiply_fu_486_ap_start();
    void thread_grp_GF_multiply_fu_497_ap_start();
    void thread_grp_GF_multiply_fu_508_ap_start();
    void thread_grp_GF_multiply_fu_519_ap_start();
    void thread_grp_GF_multiply_fu_530_ap_start();
    void thread_grp_GF_multiply_fu_541_ap_start();
    void thread_grp_GF_multiply_fu_552_ap_start();
    void thread_grp_GF_multiply_fu_563_ap_start();
    void thread_i_1_fu_745_p2();
    void thread_input_0_fu_678_p1();
    void thread_input_1_fu_687_p1();
    void thread_input_2_fu_696_p1();
    void thread_input_3_fu_705_p1();
    void thread_input_4_fu_714_p1();
    void thread_input_5_fu_723_p1();
    void thread_input_6_fu_732_p1();
    void thread_input_7_fu_741_p1();
    void thread_operation_read_read_fu_184_p2();
    void thread_output_0_fu_787_p2();
    void thread_output_1_fu_829_p2();
    void thread_output_2_fu_871_p2();
    void thread_output_3_fu_913_p2();
    void thread_parity();
    void thread_parity_ap_vld();
    void thread_tmp10_fu_823_p2();
    void thread_tmp11_fu_811_p2();
    void thread_tmp12_fu_817_p2();
    void thread_tmp13_fu_847_p2();
    void thread_tmp14_fu_835_p2();
    void thread_tmp15_fu_841_p2();
    void thread_tmp16_fu_865_p2();
    void thread_tmp17_fu_853_p2();
    void thread_tmp18_fu_859_p2();
    void thread_tmp19_fu_889_p2();
    void thread_tmp1_fu_763_p2();
    void thread_tmp20_fu_877_p2();
    void thread_tmp21_fu_883_p2();
    void thread_tmp22_fu_907_p2();
    void thread_tmp23_fu_895_p2();
    void thread_tmp24_fu_901_p2();
    void thread_tmp2_fu_751_p2();
    void thread_tmp3_fu_757_p2();
    void thread_tmp4_fu_781_p2();
    void thread_tmp5_fu_769_p2();
    void thread_tmp6_fu_775_p2();
    void thread_tmp7_fu_805_p2();
    void thread_tmp8_fu_793_p2();
    void thread_tmp9_fu_799_p2();
    void thread_tmp_10_1_fu_965_p2();
    void thread_tmp_10_2_fu_996_p2();
    void thread_tmp_10_3_fu_1027_p2();
    void thread_tmp_10_fu_611_p1();
    void thread_tmp_11_1_fu_971_p1();
    void thread_tmp_11_2_fu_1002_p1();
    void thread_tmp_11_3_fu_1033_p1();
    void thread_tmp_12_1_fu_975_p2();
    void thread_tmp_12_2_fu_1006_p2();
    void thread_tmp_12_3_fu_1037_p2();
    void thread_tmp_13_1_fu_980_p2();
    void thread_tmp_13_2_fu_1011_p2();
    void thread_tmp_13_3_fu_1042_p2();
    void thread_tmp_2_fu_940_p1();
    void thread_tmp_3_fu_663_p2();
    void thread_tmp_4_fu_669_p1();
    void thread_tmp_5_fu_919_p2();
    void thread_tmp_6_fu_924_p2();
    void thread_tmp_7_fu_944_p2();
    void thread_tmp_8_1_fu_682_p2();
    void thread_tmp_8_2_fu_691_p2();
    void thread_tmp_8_3_fu_700_p2();
    void thread_tmp_8_4_fu_709_p2();
    void thread_tmp_8_5_fu_718_p2();
    void thread_tmp_8_6_fu_727_p2();
    void thread_tmp_8_7_fu_736_p2();
    void thread_tmp_8_fu_673_p2();
    void thread_tmp_9_fu_949_p2();
    void thread_tmp_aesl_mux_load_4i368P_fu_208_empty();
    void thread_tmp_s_fu_934_p2();
    void thread_ap_NS_fsm();
    void thread_hdltv_gen();
};

}

using namespace ap_rtl;

#endif