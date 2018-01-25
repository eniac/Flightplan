; ModuleID = '/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/a.o.2.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@parity_buffer_3 = internal unnamed_addr global i368 0
@parity_buffer_2 = internal unnamed_addr global i368 0
@parity_buffer_1 = internal unnamed_addr global i368 0
@parity_buffer_0 = internal unnamed_addr global i368 0
@fb_pstat = common global [255 x i8] zeroinitializer
@fb_plen = common global [255 x i32] zeroinitializer
@fb_pdata = common global [255 x i8*] zeroinitializer
@fb_e = common global [45 x i8] zeroinitializer
@fb_d = common global [45 x i8] zeroinitializer
@fb_cbi = common global [255 x i8] zeroinitializer
@fb_block_N = common global i8 0
@fb_block_C = common global i8 0
@default = internal constant [8 x i8] c"default\00"
@data_buffer_7 = internal unnamed_addr global i368 0
@data_buffer_6 = internal unnamed_addr global i368 0
@data_buffer_5 = internal unnamed_addr global i368 0
@data_buffer_4 = internal unnamed_addr global i368 0
@data_buffer_3 = internal unnamed_addr global i368 0
@data_buffer_2 = internal unnamed_addr global i368 0
@data_buffer_1 = internal unnamed_addr global i368 0
@data_buffer_0 = internal unnamed_addr global i368 0
@Table_1 = internal unnamed_addr constant [256 x i8] c"\01\02\04\08\10 @\80\1D:t\E8\CD\87\13&L\98-Z\B4u\EA\C9\8F\03\06\0C\180`\C0\9D'N\9C%J\945j\D4\B5w\EE\C1\9F#F\8C\05\0A\14(P\A0]\BAi\D2\B9o\DE\A1_\BEa\C2\99/^\BCe\CA\89\0F\1E<x\F0\FD\E7\D3\BBk\D6\B1\7F\FE\E1\DF\A3[\B6q\E2\D9\AFC\86\11\22D\88\0D\1A4h\D0\BDg\CE\81\1F>|\F8\ED\C7\93;v\EC\C5\973f\CC\85\17.\5C\B8m\DA\A9O\9E!B\84\15*T\A8M\9A)R\A4U\AAI\929r\E4\D5\B7s\E6\D1\BFc\C6\91?~\FC\E5\D7\B3{\F6\F1\FF\E3\DB\ABK\961b\C4\957n\DC\A5W\AEA\82\192d\C8\8D\07\0E\1C8p\E0\DD\A7S\A6Q\A2Y\B2y\F2\F9\EF\C3\9B+V\ACE\8A\09\12$H\90=z\F4\F5\F7\F3\FB\EB\CB\8B\0B\16,X\B0}\FA\E9\CF\83\1B6l\D8\ADG\8E\01", align 16
@Table_r = internal unnamed_addr constant [256 x i8] c"\00\FF\01\19\022\1A\C6\03\DF3\EE\1Bh\C7K\04d\E0\0E4\8D\EF\81\1C\C1i\F8\C8\08Lq\05\8Ae/\E1$\0F!5\93\8E\DA\F0\12\82E\1D\B5\C2}j'\F9\B9\C9\9A\09xM\E4r\A6\06\BF\8Bbf\DD0\FD\E2\98%\B3\10\91\22\886\D0\94\CE\8F\96\DB\BD\F1\D2\13\5C\838F@\1EB\B6\A3\C3H~nk:(T\FA\85\BA=\CA^\9B\9F\0A\15y+N\D4\E5\ACs\F3\A7W\07p\C0\F7\8C\80c\0DgJ\DE\ED1\C5\FE\18\E3\A5\99w&\B8\B4|\11D\92\D9# \89.7?\D1[\95\BC\CF\CD\90\87\97\B2\DC\FC\BEa\F2V\D3\AB\14*]\9E\84<9SGmA\A2\1F-C\D8\B7{\A4v\C4\17I\EC\7F\0Co\F6l\A1;R)\9DU\AA\FB`\86\B1\BB\CC>Z\CBY_\B0\9C\A9\A0Q\0B\F5\16\EBzu,\D7O\AE\D5\E9\E6\E7\AD\E8t\D6\F4\EA\A8PX\AF", align 16
@RSE_core_str = internal unnamed_addr constant [9 x i8] c"RSE_core\00"
@p_str2 = private unnamed_addr constant [12 x i8] c"hls_label_0\00", align 1
@p_str1 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@empty = internal constant [1 x i8] zeroinitializer

declare void @llvm.dbg.value(metadata, i64, metadata) nounwind readnone

define internal fastcc i368 @aesl_mux_load_4i368P(i2 %empty) readonly {
entry_ifconv:
  call void (...)* @_ssdm_op_SpecClockDomain([8 x i8]* @default, [1 x i8]* @empty)
  %tmp = call i2 @_ssdm_op_Read.ap_auto.i2(i2 %empty)
  %parity_buffer_3_load = load i368* @parity_buffer_3, align 16
  %parity_buffer_0_load = load i368* @parity_buffer_0, align 16
  %parity_buffer_1_load = load i368* @parity_buffer_1, align 16
  %parity_buffer_2_load = load i368* @parity_buffer_2, align 16
  %sel_tmp = icmp eq i2 %tmp, 0
  %sel_tmp2 = icmp eq i2 %tmp, 1
  %sel_tmp4 = icmp eq i2 %tmp, -2
  %newSel = select i1 %sel_tmp4, i368 %parity_buffer_2_load, i368 %parity_buffer_1_load
  %or_cond = or i1 %sel_tmp4, %sel_tmp2
  %newSel1 = select i1 %sel_tmp, i368 %parity_buffer_0_load, i368 %parity_buffer_3_load
  %newSel3 = select i1 %or_cond, i368 %newSel, i368 %newSel1
  ret i368 %newSel3
}

define weak void @_ssdm_op_Write.ap_auto.i368P(i368*, i368) {
entry:
  store i368 %1, i368* %0
  ret void
}

define weak void @_ssdm_op_SpecTopModule(...) {
entry:
  ret void
}

define weak i32 @_ssdm_op_SpecRegionEnd(...) {
entry:
  ret i32 0
}

define weak i32 @_ssdm_op_SpecRegionBegin(...) {
entry:
  ret i32 0
}

define weak void @_ssdm_op_SpecPipeline(...) nounwind {
entry:
  ret void
}

define weak i32 @_ssdm_op_SpecLoopTripCount(...) {
entry:
  ret i32 0
}

define weak void @_ssdm_op_SpecClockDomain(...) {
entry:
  ret void
}

define weak void @_ssdm_op_SpecBitsMap(...) {
entry:
  ret void
}

define weak i8 @_ssdm_op_Read.ap_auto.i8(i8) {
entry:
  ret i8 %0
}

define weak i368 @_ssdm_op_Read.ap_auto.i368(i368) {
entry:
  ret i368 %0
}

define weak i32 @_ssdm_op_Read.ap_auto.i32(i32) {
entry:
  ret i32 %0
}

define weak i2 @_ssdm_op_Read.ap_auto.i2(i2) {
entry:
  ret i2 %0
}

declare i8 @_ssdm_op_PartSelect.i8.i368.i32.i32(i368, i32, i32) nounwind readnone

declare i3 @_ssdm_op_PartSelect.i3.i32.i32.i32(i32, i32, i32) nounwind readnone

declare i2 @_ssdm_op_PartSelect.i2.i32.i32.i32(i32, i32, i32) nounwind readnone

define weak i1 @_ssdm_op_BitSelect.i1.i9.i32(i9, i32) nounwind readnone {
entry:
  %empty = trunc i32 %1 to i9
  %empty_2 = shl i9 1, %empty
  %empty_3 = and i9 %0, %empty_2
  %empty_4 = icmp ne i9 %empty_3, 0
  ret i1 %empty_4
}

declare void @_ssdm_SpecMemSelectRead(...)

define void @RSE_core(i8 zeroext %operation, i32 %index, i1 zeroext %is_parity, i368 %data, i368* %parity) nounwind uwtable {
  call void (...)* @_ssdm_op_SpecClockDomain([8 x i8]* @default, [1 x i8]* @empty) nounwind
  call void (...)* @_ssdm_op_SpecBitsMap(i8 %operation) nounwind, !map !80
  call void (...)* @_ssdm_op_SpecBitsMap(i32 %index) nounwind, !map !86
  call void (...)* @_ssdm_op_SpecBitsMap(i1 %is_parity) nounwind, !map !90
  call void (...)* @_ssdm_op_SpecBitsMap(i368 %data) nounwind, !map !94
  call void (...)* @_ssdm_op_SpecBitsMap(i368* %parity) nounwind, !map !98
  call void (...)* @_ssdm_op_SpecTopModule([9 x i8]* @RSE_core_str) nounwind
  %data_read = call i368 @_ssdm_op_Read.ap_auto.i368(i368 %data) nounwind
  %index_read = call i32 @_ssdm_op_Read.ap_auto.i32(i32 %index) nounwind
  %operation_read = call i8 @_ssdm_op_Read.ap_auto.i8(i8 %operation) nounwind
  switch i8 %operation_read, label %.loopexit [
    i8 1, label %1
    i8 2, label %.preheader.preheader
    i8 4, label %4
  ]

.preheader.preheader:                             ; preds = %0
  %data_buffer_0_load = load i368* @data_buffer_0, align 16
  %data_buffer_1_load = load i368* @data_buffer_1, align 16
  %data_buffer_2_load = load i368* @data_buffer_2, align 16
  %data_buffer_3_load = load i368* @data_buffer_3, align 16
  %data_buffer_4_load = load i368* @data_buffer_4, align 16
  %data_buffer_5_load = load i368* @data_buffer_5, align 16
  %data_buffer_6_load = load i368* @data_buffer_6, align 16
  %data_buffer_7_load = load i368* @data_buffer_7, align 16
  br label %.preheader

; <label>:1                                       ; preds = %0
  %tmp_10 = trunc i32 %index_read to i3
  switch i3 %tmp_10, label %branch7 [
    i3 0, label %branch0
    i3 1, label %branch1
    i3 2, label %branch2
    i3 3, label %branch3
    i3 -4, label %branch4
    i3 -3, label %branch5
    i3 -2, label %branch6
  ]

; <label>:2                                       ; preds = %branch7, %branch6, %branch5, %branch4, %branch3, %branch2, %branch1, %branch0
  br label %.loopexit

.preheader:                                       ; preds = %3, %.preheader.preheader
  %i = phi i9 [ %i_1, %3 ], [ 0, %.preheader.preheader ]
  %tmp_3 = icmp ult i9 %i, -144
  br i1 %tmp_3, label %3, label %.loopexit.loopexit

; <label>:3                                       ; preds = %.preheader
  %empty = call i32 (...)* @_ssdm_op_SpecLoopTripCount(i64 46, i64 46, i64 46) nounwind
  %tmp_1 = call i32 (...)* @_ssdm_op_SpecRegionBegin([12 x i8]* @p_str2) nounwind
  call void (...)* @_ssdm_op_SpecPipeline(i32 -1, i32 1, i32 1, i32 0, [1 x i8]* @p_str1) nounwind
  %tmp_4 = zext i9 %i to i368
  %tmp_8 = lshr i368 %data_buffer_0_load, %tmp_4
  %input_0 = trunc i368 %tmp_8 to i8
  %tmp_8_1 = lshr i368 %data_buffer_1_load, %tmp_4
  %input_1 = trunc i368 %tmp_8_1 to i8
  %tmp_8_2 = lshr i368 %data_buffer_2_load, %tmp_4
  %input_2 = trunc i368 %tmp_8_2 to i8
  %tmp_8_3 = lshr i368 %data_buffer_3_load, %tmp_4
  %input_3 = trunc i368 %tmp_8_3 to i8
  %tmp_8_4 = lshr i368 %data_buffer_4_load, %tmp_4
  %input_4 = trunc i368 %tmp_8_4 to i8
  %tmp_8_5 = lshr i368 %data_buffer_5_load, %tmp_4
  %input_5 = trunc i368 %tmp_8_5 to i8
  %tmp_8_6 = lshr i368 %data_buffer_6_load, %tmp_4
  %input_6 = trunc i368 %tmp_8_6 to i8
  %tmp_8_7 = lshr i368 %data_buffer_7_load, %tmp_4
  %input_7 = trunc i368 %tmp_8_7 to i8
  %Y_assign_s = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_0, i8 zeroext 76) nounwind
  %Y_assign = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_1, i8 zeroext 103) nounwind
  %Y_assign_1 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_2, i8 zeroext -107) nounwind
  %Y_assign_2 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_3, i8 zeroext 51) nounwind
  %Y_assign_3 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_4, i8 zeroext -8) nounwind
  %Y_assign_4 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_5, i8 zeroext -86) nounwind
  %Y_assign_5 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_6, i8 zeroext 97) nounwind
  %Y_assign_6 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_7, i8 zeroext 54) nounwind
  %tmp2 = xor i8 %Y_assign, %Y_assign_s
  %tmp3 = xor i8 %Y_assign_1, %Y_assign_2
  %tmp1 = xor i8 %tmp3, %tmp2
  %tmp5 = xor i8 %Y_assign_3, %Y_assign_4
  %tmp6 = xor i8 %Y_assign_5, %Y_assign_6
  %tmp4 = xor i8 %tmp6, %tmp5
  %output_0 = xor i8 %tmp4, %tmp1
  %Y_assign_7 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_0, i8 zeroext -60) nounwind
  %Y_assign_8 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_1, i8 zeroext -94) nounwind
  %Y_assign_9 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_2, i8 zeroext 35) nounwind
  %Y_assign_10 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_3, i8 zeroext -28) nounwind
  %Y_assign_11 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_4, i8 zeroext -21) nounwind
  %Y_assign_12 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_5, i8 zeroext 41) nounwind
  %Y_assign_13 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_6, i8 zeroext 35) nounwind
  %Y_assign_14 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_7, i8 zeroext 47) nounwind
  %tmp8 = xor i8 %Y_assign_8, %Y_assign_7
  %tmp9 = xor i8 %Y_assign_9, %Y_assign_10
  %tmp7 = xor i8 %tmp9, %tmp8
  %tmp11 = xor i8 %Y_assign_11, %Y_assign_12
  %tmp12 = xor i8 %Y_assign_13, %Y_assign_14
  %tmp10 = xor i8 %tmp12, %tmp11
  %output_1 = xor i8 %tmp10, %tmp7
  %Y_assign_15 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_0, i8 zeroext -42) nounwind
  %Y_assign_16 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_1, i8 zeroext 46) nounwind
  %Y_assign_17 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_2, i8 zeroext 79) nounwind
  %Y_assign_18 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_3, i8 zeroext 120) nounwind
  %Y_assign_19 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_4, i8 zeroext 78) nounwind
  %Y_assign_20 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_5, i8 zeroext 110) nounwind
  %Y_assign_21 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_6, i8 zeroext -106) nounwind
  %Y_assign_22 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_7, i8 zeroext 125) nounwind
  %tmp14 = xor i8 %Y_assign_16, %Y_assign_15
  %tmp15 = xor i8 %Y_assign_17, %Y_assign_18
  %tmp13 = xor i8 %tmp15, %tmp14
  %tmp17 = xor i8 %Y_assign_19, %Y_assign_20
  %tmp18 = xor i8 %Y_assign_21, %Y_assign_22
  %tmp16 = xor i8 %tmp18, %tmp17
  %output_2 = xor i8 %tmp16, %tmp13
  %Y_assign_23 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_0, i8 zeroext 95) nounwind
  %Y_assign_24 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_1, i8 zeroext -22) nounwind
  %Y_assign_25 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_2, i8 zeroext -8) nounwind
  %Y_assign_26 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_3, i8 zeroext -82) nounwind
  %Y_assign_27 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_4, i8 zeroext 92) nounwind
  %Y_assign_28 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_5, i8 zeroext -20) nounwind
  %Y_assign_29 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_6, i8 zeroext -43) nounwind
  %Y_assign_30 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %input_7, i8 zeroext 101) nounwind
  %tmp20 = xor i8 %Y_assign_24, %Y_assign_23
  %tmp21 = xor i8 %Y_assign_25, %Y_assign_26
  %tmp19 = xor i8 %tmp21, %tmp20
  %tmp23 = xor i8 %Y_assign_27, %Y_assign_28
  %tmp24 = xor i8 %Y_assign_29, %Y_assign_30
  %tmp22 = xor i8 %tmp24, %tmp23
  %output_3 = xor i8 %tmp22, %tmp19
  %tmp_5 = shl i368 255, %tmp_4
  %tmp_6 = xor i368 %tmp_5, -1
  %parity_buffer_0_load = load i368* @parity_buffer_0, align 16
  %tmp_s = and i368 %parity_buffer_0_load, %tmp_6
  %tmp_2 = zext i8 %output_0 to i368
  %tmp_7 = shl i368 %tmp_2, %tmp_4
  %tmp_9 = or i368 %tmp_7, %tmp_s
  store i368 %tmp_9, i368* @parity_buffer_0, align 16
  %parity_buffer_1_load = load i368* @parity_buffer_1, align 16
  %tmp_10_1 = and i368 %parity_buffer_1_load, %tmp_6
  %tmp_11_1 = zext i8 %output_1 to i368
  %tmp_12_1 = shl i368 %tmp_11_1, %tmp_4
  %tmp_13_1 = or i368 %tmp_12_1, %tmp_10_1
  store i368 %tmp_13_1, i368* @parity_buffer_1, align 16
  %parity_buffer_2_load = load i368* @parity_buffer_2, align 16
  %tmp_10_2 = and i368 %parity_buffer_2_load, %tmp_6
  %tmp_11_2 = zext i8 %output_2 to i368
  %tmp_12_2 = shl i368 %tmp_11_2, %tmp_4
  %tmp_13_2 = or i368 %tmp_12_2, %tmp_10_2
  store i368 %tmp_13_2, i368* @parity_buffer_2, align 16
  %parity_buffer_3_load = load i368* @parity_buffer_3, align 16
  %tmp_10_3 = and i368 %parity_buffer_3_load, %tmp_6
  %tmp_11_3 = zext i8 %output_3 to i368
  %tmp_12_3 = shl i368 %tmp_11_3, %tmp_4
  %tmp_13_3 = or i368 %tmp_12_3, %tmp_10_3
  store i368 %tmp_13_3, i368* @parity_buffer_3, align 16
  %empty_5 = call i32 (...)* @_ssdm_op_SpecRegionEnd([12 x i8]* @p_str2, i32 %tmp_1) nounwind
  %i_1 = add i9 8, %i
  br label %.preheader

; <label>:4                                       ; preds = %0
  %tmp_11 = trunc i32 %index_read to i2
  %tmp = call fastcc i368 @aesl_mux_load_4i368P(i2 %tmp_11) nounwind
  call void @_ssdm_op_Write.ap_auto.i368P(i368* %parity, i368 %tmp) nounwind
  br label %.loopexit

.loopexit.loopexit:                               ; preds = %.preheader
  br label %.loopexit

.loopexit:                                        ; preds = %.loopexit.loopexit, %4, %2, %0
  ret void

branch0:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_0, align 16
  br label %2

branch1:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_1, align 16
  br label %2

branch2:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_2, align 16
  br label %2

branch3:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_3, align 16
  br label %2

branch4:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_4, align 16
  br label %2

branch5:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_5, align 16
  br label %2

branch6:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_6, align 16
  br label %2

branch7:                                          ; preds = %1
  store i368 %data_read, i368* @data_buffer_7, align 16
  br label %2
}

define internal fastcc zeroext i8 @GF_multiply(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable readnone {
_ifconv:
  call void (...)* @_ssdm_op_SpecClockDomain([8 x i8]* @default, [1 x i8]* @empty) nounwind
  %Y_read = call i8 @_ssdm_op_Read.ap_auto.i8(i8 %Y) nounwind
  %X_read = call i8 @_ssdm_op_Read.ap_auto.i8(i8 %X) nounwind
  %tmp = icmp eq i8 %X_read, 0
  %tmp_s = icmp eq i8 %Y_read, 0
  %or_cond = or i1 %tmp, %tmp_s
  %tmp_i = zext i8 %X_read to i64
  %Table_addr = getelementptr inbounds [256 x i8]* @Table_r, i64 0, i64 %tmp_i
  %Table_load = load i8* %Table_addr, align 1
  %tmp_i1 = zext i8 %Y_read to i64
  %Table_addr_1 = getelementptr inbounds [256 x i8]* @Table_r, i64 0, i64 %tmp_i1
  %Table_load_1 = load i8* %Table_addr_1, align 1
  %tmp_i4_cast = zext i8 %Table_load to i9
  %tmp_i_cast = zext i8 %Table_load_1 to i9
  %Sum = add i9 %tmp_i4_cast, %tmp_i_cast
  %tmp_25 = call i1 @_ssdm_op_BitSelect.i1.i9.i32(i9 %Sum, i32 8)
  %tmp_2_i = add i8 %Table_load_1, %Table_load
  %tmp_3_i = add i8 %tmp_2_i, 1
  %X_assign_4 = select i1 %tmp_25, i8 %tmp_3_i, i8 %tmp_2_i
  %tmp_i5 = zext i8 %X_assign_4 to i64
  %Table_1_addr = getelementptr inbounds [256 x i8]* @Table_1, i64 0, i64 %tmp_i5
  %Table_1_load = load i8* %Table_1_addr, align 1
  %tmp_6 = select i1 %or_cond, i8 0, i8 %Table_1_load
  ret i8 %tmp_6
}

!opencl.kernels = !{!0, !7, !13, !19, !25, !25, !29, !35, !19, !35}
!hls.encrypted.func = !{}
!llvm.map.gv = !{!36, !43, !48, !56, !61, !66, !73, !78, !79}

!0 = metadata !{void (i8, i32, i1, i368, i368*)* @RSE_core, metadata !1, metadata !2, metadata !3, metadata !4, metadata !5, metadata !6}
!1 = metadata !{metadata !"kernel_arg_addr_space", i32 0, i32 0, i32 0, i32 0, i32 1}
!2 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!3 = metadata !{metadata !"kernel_arg_type", metadata !"uint8", metadata !"uint32", metadata !"uint1", metadata !"packet_t", metadata !"packet_t*"}
!4 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !"", metadata !"", metadata !"", metadata !""}
!5 = metadata !{metadata !"kernel_arg_name", metadata !"operation", metadata !"index", metadata !"is_parity", metadata !"data", metadata !"parity"}
!6 = metadata !{metadata !"reqd_work_group_size", i32 1, i32 1, i32 1}
!7 = metadata !{null, metadata !8, metadata !9, metadata !10, metadata !11, metadata !12, metadata !6}
!8 = metadata !{metadata !"kernel_arg_addr_space", i32 1, i32 1, i32 0, i32 0}
!9 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!10 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym*", metadata !"fec_sym*", metadata !"int", metadata !"int"}
!11 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !"", metadata !"", metadata !""}
!12 = metadata !{metadata !"kernel_arg_name", metadata !"Data", metadata !"Parity", metadata !"k", metadata !"h"}
!13 = metadata !{i8 (i8, i8)* @GF_multiply, metadata !14, metadata !15, metadata !16, metadata !17, metadata !18, metadata !6}
!14 = metadata !{metadata !"kernel_arg_addr_space", i32 0, i32 0}
!15 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none"}
!16 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym", metadata !"fec_sym"}
!17 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !""}
!18 = metadata !{metadata !"kernel_arg_name", metadata !"X", metadata !"Y"}
!19 = metadata !{null, metadata !20, metadata !21, metadata !22, metadata !23, metadata !24, metadata !6}
!20 = metadata !{metadata !"kernel_arg_addr_space", i32 0}
!21 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none"}
!22 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym"}
!23 = metadata !{metadata !"kernel_arg_type_qual", metadata !""}
!24 = metadata !{metadata !"kernel_arg_name", metadata !"X"}
!25 = metadata !{null, metadata !26, metadata !21, metadata !27, metadata !23, metadata !28, metadata !6}
!26 = metadata !{metadata !"kernel_arg_addr_space", i32 1}
!27 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym*"}
!28 = metadata !{metadata !"kernel_arg_name", metadata !"Table"}
!29 = metadata !{null, metadata !30, metadata !31, metadata !32, metadata !33, metadata !34, metadata !6}
!30 = metadata !{metadata !"kernel_arg_addr_space"}
!31 = metadata !{metadata !"kernel_arg_access_qual"}
!32 = metadata !{metadata !"kernel_arg_type"}
!33 = metadata !{metadata !"kernel_arg_type_qual"}
!34 = metadata !{metadata !"kernel_arg_name"}
!35 = metadata !{null, metadata !14, metadata !15, metadata !16, metadata !17, metadata !18, metadata !6}
!36 = metadata !{metadata !37, [255 x i8]* @fb_pstat}
!37 = metadata !{metadata !38}
!38 = metadata !{i32 0, i32 7, metadata !39}
!39 = metadata !{metadata !40}
!40 = metadata !{metadata !"fb.pstat", metadata !41, metadata !"char", i32 0, i32 7}
!41 = metadata !{metadata !42}
!42 = metadata !{i32 0, i32 254, i32 1}
!43 = metadata !{metadata !44, [255 x i32]* @fb_plen}
!44 = metadata !{metadata !45}
!45 = metadata !{i32 0, i32 31, metadata !46}
!46 = metadata !{metadata !47}
!47 = metadata !{metadata !"fb.plen", metadata !41, metadata !"int", i32 0, i32 31}
!48 = metadata !{metadata !49, null}
!49 = metadata !{metadata !50}
!50 = metadata !{i32 0, i32 7, metadata !51}
!51 = metadata !{metadata !52}
!52 = metadata !{metadata !"fb.e", metadata !53, metadata !"unsigned char", i32 0, i32 7}
!53 = metadata !{metadata !54, metadata !55}
!54 = metadata !{i32 0, i32 8, i32 1}
!55 = metadata !{i32 0, i32 4, i32 1}
!56 = metadata !{metadata !57, null}
!57 = metadata !{metadata !58}
!58 = metadata !{i32 0, i32 7, metadata !59}
!59 = metadata !{metadata !60}
!60 = metadata !{metadata !"fb.d", metadata !53, metadata !"unsigned char", i32 0, i32 7}
!61 = metadata !{metadata !62, [255 x i8]* @fb_cbi}
!62 = metadata !{metadata !63}
!63 = metadata !{i32 0, i32 7, metadata !64}
!64 = metadata !{metadata !65}
!65 = metadata !{metadata !"fb.cbi", metadata !41, metadata !"unsigned char", i32 0, i32 7}
!66 = metadata !{metadata !67, i8* @fb_block_N}
!67 = metadata !{metadata !68}
!68 = metadata !{i32 0, i32 7, metadata !69}
!69 = metadata !{metadata !70}
!70 = metadata !{metadata !"fb.block_N", metadata !71, metadata !"unsigned char", i32 0, i32 7}
!71 = metadata !{metadata !72}
!72 = metadata !{i32 0, i32 0, i32 1}
!73 = metadata !{metadata !74, i8* @fb_block_C}
!74 = metadata !{metadata !75}
!75 = metadata !{i32 0, i32 7, metadata !76}
!76 = metadata !{metadata !77}
!77 = metadata !{metadata !"fb.block_C", metadata !71, metadata !"unsigned char", i32 0, i32 7}
!78 = metadata !{metadata !49, [45 x i8]* @fb_e}
!79 = metadata !{metadata !57, [45 x i8]* @fb_d}
!80 = metadata !{metadata !81}
!81 = metadata !{i32 0, i32 7, metadata !82}
!82 = metadata !{metadata !83}
!83 = metadata !{metadata !"operation", metadata !84, metadata !"uint8", i32 0, i32 7}
!84 = metadata !{metadata !85}
!85 = metadata !{i32 0, i32 0, i32 0}
!86 = metadata !{metadata !87}
!87 = metadata !{i32 0, i32 31, metadata !88}
!88 = metadata !{metadata !89}
!89 = metadata !{metadata !"index", metadata !84, metadata !"uint32", i32 0, i32 31}
!90 = metadata !{metadata !91}
!91 = metadata !{i32 0, i32 0, metadata !92}
!92 = metadata !{metadata !93}
!93 = metadata !{metadata !"is_parity", metadata !84, metadata !"uint1", i32 0, i32 0}
!94 = metadata !{metadata !95}
!95 = metadata !{i32 0, i32 367, metadata !96}
!96 = metadata !{metadata !97}
!97 = metadata !{metadata !"data", metadata !84, metadata !"uint368", i32 0, i32 367}
!98 = metadata !{metadata !99}
!99 = metadata !{i32 0, i32 367, metadata !100}
!100 = metadata !{metadata !101}
!101 = metadata !{metadata !"parity", metadata !71, metadata !"uint368", i32 0, i32 367}
