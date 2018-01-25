// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2017.1
// Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

#ifndef _aesl_mux_load_4i368P_HH_
#define _aesl_mux_load_4i368P_HH_

#include "systemc.h"
#include "AESL_pkg.h"


namespace ap_rtl {

struct aesl_mux_load_4i368P : public sc_module {
    // Port declarations 6
    sc_in< sc_lv<2> > empty;
    sc_in< sc_lv<368> > parity_buffer_3;
    sc_in< sc_lv<368> > parity_buffer_0;
    sc_in< sc_lv<368> > parity_buffer_1;
    sc_in< sc_lv<368> > parity_buffer_2;
    sc_out< sc_lv<368> > ap_return;


    // Module declarations
    aesl_mux_load_4i368P(sc_module_name name);
    SC_HAS_PROCESS(aesl_mux_load_4i368P);

    ~aesl_mux_load_4i368P();

    sc_trace_file* mVcdFile;

    sc_signal< sc_lv<1> > sel_tmp_fu_46_p2;
    sc_signal< sc_lv<1> > or_cond_fu_72_p2;
    sc_signal< sc_lv<1> > sel_tmp4_fu_58_p2;
    sc_signal< sc_lv<1> > sel_tmp2_fu_52_p2;
    sc_signal< sc_lv<368> > newSel_fu_64_p3;
    sc_signal< sc_lv<368> > newSel1_fu_78_p3;
    static const bool ap_const_boolean_1;
    static const sc_lv<1> ap_const_lv1_0;
    static const sc_lv<2> ap_const_lv2_0;
    static const sc_lv<2> ap_const_lv2_1;
    static const sc_lv<2> ap_const_lv2_2;
    static const sc_logic ap_const_logic_1;
    static const sc_logic ap_const_logic_0;
    // Thread declarations
    void thread_ap_return();
    void thread_newSel1_fu_78_p3();
    void thread_newSel_fu_64_p3();
    void thread_or_cond_fu_72_p2();
    void thread_sel_tmp2_fu_52_p2();
    void thread_sel_tmp4_fu_58_p2();
    void thread_sel_tmp_fu_46_p2();
};

}

using namespace ap_rtl;

#endif
