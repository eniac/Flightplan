; ModuleID = '/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/a.g.1.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.fec_block.0 = type { i8, i8, [255 x i8*], [255 x i8], [255 x i32], [255 x i8], [9 x [5 x i8]], [9 x [5 x i8]] }

@parity_buffer = internal global [4 x i368] zeroinitializer, align 16 ; [#uses=3 type=[4 x i368]*]
@fb = common global %struct.fec_block.0 zeroinitializer, align 8 ; [#uses=0 type=%struct.fec_block.0*]
@data_buffer = internal global [8 x i368] zeroinitializer, align 16 ; [#uses=3 type=[8 x i368]*]
@Table.1 = internal unnamed_addr constant [256 x i8] c"\01\02\04\08\10 @\80\1D:t\E8\CD\87\13&L\98-Z\B4u\EA\C9\8F\03\06\0C\180`\C0\9D'N\9C%J\945j\D4\B5w\EE\C1\9F#F\8C\05\0A\14(P\A0]\BAi\D2\B9o\DE\A1_\BEa\C2\99/^\BCe\CA\89\0F\1E<x\F0\FD\E7\D3\BBk\D6\B1\7F\FE\E1\DF\A3[\B6q\E2\D9\AFC\86\11\22D\88\0D\1A4h\D0\BDg\CE\81\1F>|\F8\ED\C7\93;v\EC\C5\973f\CC\85\17.\5C\B8m\DA\A9O\9E!B\84\15*T\A8M\9A)R\A4U\AAI\929r\E4\D5\B7s\E6\D1\BFc\C6\91?~\FC\E5\D7\B3{\F6\F1\FF\E3\DB\ABK\961b\C4\957n\DC\A5W\AEA\82\192d\C8\8D\07\0E\1C8p\E0\DD\A7S\A6Q\A2Y\B2y\F2\F9\EF\C3\9B+V\ACE\8A\09\12$H\90=z\F4\F5\F7\F3\FB\EB\CB\8B\0B\16,X\B0}\FA\E9\CF\83\1B6l\D8\ADG\8E\01", align 16 ; [#uses=1 type=[256 x i8]*]
@Table = internal unnamed_addr constant [256 x i8] c"\00\FF\01\19\022\1A\C6\03\DF3\EE\1Bh\C7K\04d\E0\0E4\8D\EF\81\1C\C1i\F8\C8\08Lq\05\8Ae/\E1$\0F!5\93\8E\DA\F0\12\82E\1D\B5\C2}j'\F9\B9\C9\9A\09xM\E4r\A6\06\BF\8Bbf\DD0\FD\E2\98%\B3\10\91\22\886\D0\94\CE\8F\96\DB\BD\F1\D2\13\5C\838F@\1EB\B6\A3\C3H~nk:(T\FA\85\BA=\CA^\9B\9F\0A\15y+N\D4\E5\ACs\F3\A7W\07p\C0\F7\8C\80c\0DgJ\DE\ED1\C5\FE\18\E3\A5\99w&\B8\B4|\11D\92\D9# \89.7?\D1[\95\BC\CF\CD\90\87\97\B2\DC\FC\BEa\F2V\D3\AB\14*]\9E\84<9SGmA\A2\1F-C\D8\B7{\A4v\C4\17I\EC\7F\0Co\F6l\A1;R)\9DU\AA\FB`\86\B1\BB\CC>Z\CBY_\B0\9C\A9\A0Q\0B\F5\16\EBzu,\D7O\AE\D5\E9\E6\E7\AD\E8t\D6\F4\EA\A8PX\AF", align 16 ; [#uses=1 type=[256 x i8]*]
@RSE_core.str = internal unnamed_addr constant [9 x i8] c"RSE_core\00" ; [#uses=1 type=[9 x i8]*]
@Generator = internal constant [4 x [8 x i8]] [[8 x i8] c"Lg\953\F8\AAa6", [8 x i8] c"\C4\A2#\E4\EB)#/", [8 x i8] c"\D6.OxNn\96}", [8 x i8] c"_\EA\F8\AE\5C\EC\D5e"], align 16 ; [#uses=2 type=[4 x [8 x i8]]*]
@.str3 = private unnamed_addr constant [9 x i8] c"COMPLETE\00", align 1 ; [#uses=1 type=[9 x i8]*]
@.str2 = private unnamed_addr constant [12 x i8] c"hls_label_0\00", align 1 ; [#uses=1 type=[12 x i8]*]
@.str14 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1 ; [#uses=1 type=[1 x i8]*]
@.str1 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1 ; [#uses=1 type=[1 x i8]*]
@.str = private unnamed_addr constant [9 x i8] c"COMPLETE\00", align 1 ; [#uses=1 type=[9 x i8]*]

; [#uses=23]
declare void @llvm.dbg.value(metadata, i64, metadata) nounwind readnone

; [#uses=2]
declare void @llvm.dbg.declare(metadata, metadata) nounwind readnone

; [#uses=1]
declare void @_ssdm_op_SpecTopModule(...)

; [#uses=1]
declare i32 @_ssdm_op_SpecRegionEnd(...)

; [#uses=1]
declare i32 @_ssdm_op_SpecRegionBegin(...)

; [#uses=1]
declare void @_ssdm_op_SpecPipeline(...) nounwind

; [#uses=8]
declare void @_ssdm_SpecKeepArrayLoad(...)

; [#uses=5]
declare void @_ssdm_SpecArrayPartition(...) nounwind

; [#uses=2]
declare void @_ssdm_SpecArrayDimSize(...) nounwind

; [#uses=0]
define void @RSE_core(i8 zeroext %operation, i32 %index, i1 zeroext %is_parity, i368 %data, i368* %parity) nounwind uwtable {
  call void (...)* @_ssdm_op_SpecTopModule([9 x i8]* @RSE_core.str) nounwind
  %input = alloca [8 x i8], align 1               ; [#uses=2 type=[8 x i8]*]
  %output = alloca [4 x i8], align 1              ; [#uses=2 type=[4 x i8]*]
  call void @llvm.dbg.value(metadata !{i8 %operation}, i64 0, metadata !150), !dbg !151 ; [debug line = 24:21] [debug variable = operation]
  call void @llvm.dbg.value(metadata !{i32 %index}, i64 0, metadata !152), !dbg !153 ; [debug line = 24:39] [debug variable = index]
  call void @llvm.dbg.value(metadata !{i1 %is_parity}, i64 0, metadata !154), !dbg !155 ; [debug line = 24:52] [debug variable = is_parity]
  call void @llvm.dbg.value(metadata !{i368 %data}, i64 0, metadata !156), !dbg !157 ; [debug line = 24:72] [debug variable = data]
  call void @llvm.dbg.value(metadata !{i368* %parity}, i64 0, metadata !158), !dbg !159 ; [debug line = 24:89] [debug variable = parity]
  call void (...)* @_ssdm_SpecArrayPartition(i368* getelementptr inbounds ([8 x i368]* @data_buffer, i64 0, i64 0), i32 1, i8* getelementptr inbounds ([9 x i8]* @.str, i64 0, i64 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str1, i64 0, i64 0)) nounwind, !dbg !160 ; [debug line = 26:1]
  call void (...)* @_ssdm_SpecArrayPartition(i368* getelementptr inbounds ([4 x i368]* @parity_buffer, i64 0, i64 0), i32 1, i8* getelementptr inbounds ([9 x i8]* @.str, i64 0, i64 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str1, i64 0, i64 0)) nounwind, !dbg !162 ; [debug line = 27:1]
  %tmp = zext i8 %operation to i32, !dbg !163     ; [#uses=1 type=i32] [debug line = 31:3]
  switch i32 %tmp, label %.loopexit [
    i32 1, label %1
    i32 2, label %.preheader.preheader
    i32 4, label %9
  ], !dbg !163                                    ; [debug line = 31:3]

.preheader.preheader:                             ; preds = %0
  %input.addr = getelementptr inbounds [8 x i8]* %input, i64 0, i64 0, !dbg !164 ; [#uses=1 type=i8*] [debug line = 45:9]
  %output.addr = getelementptr inbounds [4 x i8]* %output, i64 0, i64 0, !dbg !164 ; [#uses=1 type=i8*] [debug line = 45:9]
  br label %.preheader, !dbg !168                 ; [debug line = 38:21]

; <label>:1                                       ; preds = %0
  %tmp.1 = zext i32 %index to i64, !dbg !169      ; [#uses=1 type=i64] [debug line = 34:7]
  %data_buffer.addr = getelementptr inbounds [8 x i368]* @data_buffer, i64 0, i64 %tmp.1, !dbg !169 ; [#uses=1 type=i368*] [debug line = 34:7]
  store i368 %data, i368* %data_buffer.addr, align 16, !dbg !169 ; [debug line = 34:7]
  br label %.loopexit, !dbg !170                  ; [debug line = 35:7]

.preheader:                                       ; preds = %8, %.preheader.preheader
  %i = phi i32 [ %i.1, %8 ], [ 0, %.preheader.preheader ] ; [#uses=3 type=i32]
  %tmp.3 = icmp slt i32 %i, 368, !dbg !168        ; [#uses=1 type=i1] [debug line = 38:21]
  br i1 %tmp.3, label %2, label %.loopexit.loopexit, !dbg !168 ; [debug line = 38:21]

; <label>:2                                       ; preds = %.preheader
  %rbegin = call i32 (...)* @_ssdm_op_SpecRegionBegin(i8* getelementptr inbounds ([12 x i8]* @.str2, i64 0, i64 0)) nounwind, !dbg !171 ; [#uses=1 type=i32] [debug line = 39:8]
  call void (...)* @_ssdm_op_SpecPipeline(i32 -1, i32 1, i32 1, i32 0, i8* getelementptr inbounds ([1 x i8]* @.str1, i64 0, i64 0)) nounwind, !dbg !172 ; [debug line = 40:1]
  call void @llvm.dbg.declare(metadata !{[8 x i8]* %input}, metadata !173), !dbg !175 ; [debug line = 41:10] [debug variable = input]
  %tmp.4 = zext i32 %i to i368, !dbg !176         ; [#uses=3 type=i368] [debug line = 43:11]
  br label %3, !dbg !178                          ; [debug line = 42:23]

; <label>:3                                       ; preds = %4, %2
  %j = phi i32 [ 0, %2 ], [ %j.1, %4 ]            ; [#uses=3 type=i32]
  %exitcond1 = icmp eq i32 %j, 8, !dbg !178       ; [#uses=1 type=i1] [debug line = 42:23]
  br i1 %exitcond1, label %5, label %4, !dbg !178 ; [debug line = 42:23]

; <label>:4                                       ; preds = %3
  %tmp.7 = sext i32 %j to i64, !dbg !176          ; [#uses=2 type=i64] [debug line = 43:11]
  %data_buffer.addr.1 = getelementptr inbounds [8 x i368]* @data_buffer, i64 0, i64 %tmp.7, !dbg !176 ; [#uses=1 type=i368*] [debug line = 43:11]
  %data_buffer.load = load i368* %data_buffer.addr.1, align 16, !dbg !176 ; [#uses=2 type=i368] [debug line = 43:11]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i368 %data_buffer.load) nounwind
  %tmp.8 = lshr i368 %data_buffer.load, %tmp.4, !dbg !176 ; [#uses=1 type=i368] [debug line = 43:11]
  %tmp.9 = trunc i368 %tmp.8 to i8, !dbg !176     ; [#uses=1 type=i8] [debug line = 43:11]
  %input.addr.1 = getelementptr inbounds [8 x i8]* %input, i64 0, i64 %tmp.7, !dbg !176 ; [#uses=1 type=i8*] [debug line = 43:11]
  store i8 %tmp.9, i8* %input.addr.1, align 1, !dbg !176 ; [debug line = 43:11]
  %j.1 = add nsw i32 %j, 1, !dbg !179             ; [#uses=1 type=i32] [debug line = 42:32]
  call void @llvm.dbg.value(metadata !{i32 %j.1}, i64 0, metadata !180), !dbg !179 ; [debug line = 42:32] [debug variable = j]
  br label %3, !dbg !179                          ; [debug line = 42:32]

; <label>:5                                       ; preds = %3
  call void @llvm.dbg.declare(metadata !{[4 x i8]* %output}, metadata !181), !dbg !183 ; [debug line = 44:17] [debug variable = output]
  call fastcc void @Matrix_multiply_HW(i8* %input.addr, i8* %output.addr), !dbg !164 ; [debug line = 45:9]
  %tmp.5 = shl i368 255, %tmp.4, !dbg !184        ; [#uses=1 type=i368] [debug line = 47:11]
  %tmp.6 = xor i368 %tmp.5, -1, !dbg !184         ; [#uses=1 type=i368] [debug line = 47:11]
  br label %6, !dbg !186                          ; [debug line = 46:23]

; <label>:6                                       ; preds = %7, %5
  %j1 = phi i32 [ 0, %5 ], [ %j.2, %7 ]           ; [#uses=3 type=i32]
  %exitcond = icmp eq i32 %j1, 4, !dbg !186       ; [#uses=1 type=i1] [debug line = 46:23]
  br i1 %exitcond, label %8, label %7, !dbg !186  ; [debug line = 46:23]

; <label>:7                                       ; preds = %6
  %tmp.12 = sext i32 %j1 to i64, !dbg !184        ; [#uses=2 type=i64] [debug line = 47:11]
  %parity_buffer.addr.1 = getelementptr inbounds [4 x i368]* @parity_buffer, i64 0, i64 %tmp.12, !dbg !184 ; [#uses=2 type=i368*] [debug line = 47:11]
  %parity_buffer.load.1 = load i368* %parity_buffer.addr.1, align 16, !dbg !184 ; [#uses=2 type=i368] [debug line = 47:11]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i368 %parity_buffer.load.1) nounwind
  %tmp.13 = and i368 %parity_buffer.load.1, %tmp.6, !dbg !184 ; [#uses=1 type=i368] [debug line = 47:11]
  %output.addr.1 = getelementptr inbounds [4 x i8]* %output, i64 0, i64 %tmp.12, !dbg !184 ; [#uses=1 type=i8*] [debug line = 47:11]
  %output.load = load i8* %output.addr.1, align 1, !dbg !184 ; [#uses=2 type=i8] [debug line = 47:11]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i8 %output.load) nounwind
  %tmp.14 = zext i8 %output.load to i368, !dbg !184 ; [#uses=1 type=i368] [debug line = 47:11]
  %tmp.15 = shl i368 %tmp.14, %tmp.4, !dbg !184   ; [#uses=1 type=i368] [debug line = 47:11]
  %tmp.16 = or i368 %tmp.15, %tmp.13, !dbg !184   ; [#uses=1 type=i368] [debug line = 47:11]
  store i368 %tmp.16, i368* %parity_buffer.addr.1, align 16, !dbg !184 ; [debug line = 47:11]
  %j.2 = add nsw i32 %j1, 1, !dbg !187            ; [#uses=1 type=i32] [debug line = 46:32]
  call void @llvm.dbg.value(metadata !{i32 %j.2}, i64 0, metadata !188), !dbg !187 ; [debug line = 46:32] [debug variable = j]
  br label %6, !dbg !187                          ; [debug line = 46:32]

; <label>:8                                       ; preds = %6
  %rend = call i32 (...)* @_ssdm_op_SpecRegionEnd(i8* getelementptr inbounds ([12 x i8]* @.str2, i64 0, i64 0), i32 %rbegin) nounwind, !dbg !189 ; [#uses=0 type=i32] [debug line = 49:7]
  %i.1 = add nsw i32 %i, 8, !dbg !190             ; [#uses=1 type=i32] [debug line = 38:32]
  call void @llvm.dbg.value(metadata !{i32 %i.1}, i64 0, metadata !191), !dbg !190 ; [debug line = 38:32] [debug variable = i]
  br label %.preheader, !dbg !190                 ; [debug line = 38:32]

; <label>:9                                       ; preds = %0
  %tmp.2 = zext i32 %index to i64, !dbg !192      ; [#uses=1 type=i64] [debug line = 53:7]
  %parity_buffer.addr = getelementptr inbounds [4 x i368]* @parity_buffer, i64 0, i64 %tmp.2, !dbg !192 ; [#uses=1 type=i368*] [debug line = 53:7]
  %parity_buffer.load = load i368* %parity_buffer.addr, align 16, !dbg !192 ; [#uses=2 type=i368] [debug line = 53:7]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i368 %parity_buffer.load) nounwind
  store i368 %parity_buffer.load, i368* %parity, align 8, !dbg !192 ; [debug line = 53:7]
  br label %.loopexit, !dbg !193                  ; [debug line = 54:3]

.loopexit.loopexit:                               ; preds = %.preheader
  br label %.loopexit

.loopexit:                                        ; preds = %.loopexit.loopexit, %9, %1, %0
  ret void, !dbg !194                             ; [debug line = 55:1]
}

; [#uses=1]
define internal fastcc zeroext i8 @Modulo_add(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable {
  call void @llvm.dbg.value(metadata !{i8 %X}, i64 0, metadata !195), !dbg !196 ; [debug line = 9:35] [debug variable = X]
  call void @llvm.dbg.value(metadata !{i8 %Y}, i64 0, metadata !197), !dbg !198 ; [debug line = 9:46] [debug variable = Y]
  %tmp = zext i8 %X to i32, !dbg !199             ; [#uses=1 type=i32] [debug line = 11:18]
  %tmp.18 = zext i8 %Y to i32, !dbg !199          ; [#uses=1 type=i32] [debug line = 11:18]
  %Sum = add nsw i32 %tmp.18, %tmp, !dbg !199     ; [#uses=3 type=i32] [debug line = 11:18]
  call void @llvm.dbg.value(metadata !{i32 %Sum}, i64 0, metadata !201), !dbg !199 ; [debug line = 11:18] [debug variable = Sum]
  %tmp.19 = icmp sgt i32 %Sum, 255, !dbg !202     ; [#uses=1 type=i1] [debug line = 12:3]
  %tmp.20 = add nsw i32 %Sum, 1, !dbg !202        ; [#uses=1 type=i32] [debug line = 12:3]
  %Sum.1 = select i1 %tmp.19, i32 %tmp.20, i32 %Sum, !dbg !202 ; [#uses=1 type=i32] [debug line = 12:3]
  call void @llvm.dbg.value(metadata !{i32 %Sum.1}, i64 0, metadata !201), !dbg !202 ; [debug line = 12:3] [debug variable = Sum]
  %tmp.22 = trunc i32 %Sum.1 to i8, !dbg !202     ; [#uses=1 type=i8] [debug line = 12:3]
  ret i8 %tmp.22, !dbg !202                       ; [debug line = 12:3]
}

; [#uses=1]
define internal fastcc void @Matrix_multiply_HW(i8* %Data, i8* %Parity) nounwind uwtable {
  call void @llvm.dbg.value(metadata !{i8* %Data}, i64 0, metadata !203), !dbg !204 ; [debug line = 151:33] [debug variable = Data]
  call void @llvm.dbg.value(metadata !{i8* %Parity}, i64 0, metadata !205), !dbg !206 ; [debug line = 151:144] [debug variable = Parity]
  call void (...)* @_ssdm_SpecArrayDimSize(i8* %Data, i32 8) nounwind, !dbg !207 ; [debug line = 152:2]
  call void (...)* @_ssdm_SpecArrayDimSize(i8* %Parity, i32 4) nounwind, !dbg !209 ; [debug line = 152:102]
  call void (...)* @_ssdm_SpecArrayPartition(i8* %Data, i32 1, i8* getelementptr inbounds ([9 x i8]* @.str3, i64 0, i64 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str14, i64 0, i64 0)) nounwind, !dbg !210 ; [debug line = 153:1]
  call void (...)* @_ssdm_SpecArrayPartition(i8* %Parity, i32 1, i8* getelementptr inbounds ([9 x i8]* @.str3, i64 0, i64 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str14, i64 0, i64 0)) nounwind, !dbg !211 ; [debug line = 154:1]
  call void (...)* @_ssdm_SpecArrayPartition([8 x i8]* getelementptr inbounds ([4 x [8 x i8]]* @Generator, i64 0, i64 0), i32 0, i8* getelementptr inbounds ([9 x i8]* @.str3, i64 0, i64 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str14, i64 0, i64 0)) nounwind, !dbg !212 ; [debug line = 159:1]
  br label %1, !dbg !213                          ; [debug line = 162:17]

; <label>:1                                       ; preds = %._crit_edge, %0
  %i = phi i32 [ 0, %0 ], [ %i.2, %._crit_edge ]  ; [#uses=4 type=i32]
  %exitcond1 = icmp eq i32 %i, 4, !dbg !213       ; [#uses=1 type=i1] [debug line = 162:17]
  br i1 %exitcond1, label %6, label %2, !dbg !213 ; [debug line = 162:17]

; <label>:2                                       ; preds = %1
  %tmp = icmp slt i32 %i, 4, !dbg !215            ; [#uses=1 type=i1] [debug line = 164:5]
  br i1 %tmp, label %.preheader.preheader, label %._crit_edge, !dbg !215 ; [debug line = 164:5]

.preheader.preheader:                             ; preds = %2
  %tmp.23 = sext i32 %i to i64, !dbg !217         ; [#uses=2 type=i64] [debug line = 169:35]
  br label %.preheader, !dbg !220                 ; [debug line = 167:21]

.preheader:                                       ; preds = %._crit_edge2, %.preheader.preheader
  %Result = phi i32 [ %Result.1, %._crit_edge2 ], [ 0, %.preheader.preheader ] ; [#uses=3 type=i32]
  %j = phi i32 [ %j.3, %._crit_edge2 ], [ 0, %.preheader.preheader ] ; [#uses=4 type=i32]
  %exitcond = icmp eq i32 %j, 8, !dbg !220        ; [#uses=1 type=i1] [debug line = 167:21]
  br i1 %exitcond, label %5, label %3, !dbg !220  ; [debug line = 167:21]

; <label>:3                                       ; preds = %.preheader
  %tmp.25 = icmp slt i32 %j, 8, !dbg !221         ; [#uses=1 type=i1] [debug line = 168:9]
  br i1 %tmp.25, label %4, label %._crit_edge2, !dbg !221 ; [debug line = 168:9]

; <label>:4                                       ; preds = %3
  %tmp.27 = trunc i32 %Result to i8, !dbg !222    ; [#uses=1 type=i8] [debug line = 169:20]
  %tmp.28 = sext i32 %j to i64, !dbg !217         ; [#uses=2 type=i64] [debug line = 169:35]
  %Data.addr = getelementptr inbounds i8* %Data, i64 %tmp.28, !dbg !217 ; [#uses=1 type=i8*] [debug line = 169:35]
  %Data.load = load i8* %Data.addr, align 1, !dbg !217 ; [#uses=2 type=i8] [debug line = 169:35]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i8 %Data.load) nounwind
  %Generator.addr = getelementptr inbounds [4 x [8 x i8]]* @Generator, i64 0, i64 %tmp.23, i64 %tmp.28, !dbg !217 ; [#uses=1 type=i8*] [debug line = 169:35]
  %Generator.load = load i8* %Generator.addr, align 1, !dbg !217 ; [#uses=2 type=i8] [debug line = 169:35]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i8 %Generator.load) nounwind
  %tmp.29 = call fastcc zeroext i8 @GF_multiply(i8 zeroext %Data.load, i8 zeroext %Generator.load), !dbg !217 ; [#uses=1 type=i8] [debug line = 169:35]
  %tmp.30 = call fastcc zeroext i8 @GF_add(i8 zeroext %tmp.27, i8 zeroext %tmp.29), !dbg !217 ; [#uses=1 type=i8] [debug line = 169:35]
  %Result.2 = zext i8 %tmp.30 to i32, !dbg !217   ; [#uses=1 type=i32] [debug line = 169:35]
  call void @llvm.dbg.value(metadata !{i32 %Result.2}, i64 0, metadata !223), !dbg !217 ; [debug line = 169:35] [debug variable = Result]
  br label %._crit_edge2, !dbg !217               ; [debug line = 169:35]

._crit_edge2:                                     ; preds = %4, %3
  %Result.1 = phi i32 [ %Result.2, %4 ], [ %Result, %3 ] ; [#uses=1 type=i32]
  %j.3 = add nsw i32 %j, 1, !dbg !224             ; [#uses=1 type=i32] [debug line = 167:124]
  call void @llvm.dbg.value(metadata !{i32 %j.3}, i64 0, metadata !225), !dbg !224 ; [debug line = 167:124] [debug variable = j]
  br label %.preheader, !dbg !224                 ; [debug line = 167:124]

; <label>:5                                       ; preds = %.preheader
  %Result.0.lcssa = phi i32 [ %Result, %.preheader ] ; [#uses=1 type=i32]
  %tmp.24 = trunc i32 %Result.0.lcssa to i8, !dbg !226 ; [#uses=1 type=i8] [debug line = 170:7]
  %Parity.addr = getelementptr inbounds i8* %Parity, i64 %tmp.23, !dbg !226 ; [#uses=1 type=i8*] [debug line = 170:7]
  store i8 %tmp.24, i8* %Parity.addr, align 1, !dbg !226 ; [debug line = 170:7]
  br label %._crit_edge, !dbg !227                ; [debug line = 171:5]

._crit_edge:                                      ; preds = %5, %2
  %i.2 = add nsw i32 %i, 1, !dbg !228             ; [#uses=1 type=i32] [debug line = 162:47]
  call void @llvm.dbg.value(metadata !{i32 %i.2}, i64 0, metadata !229), !dbg !228 ; [debug line = 162:47] [debug variable = i]
  br label %1, !dbg !228                          ; [debug line = 162:47]

; <label>:6                                       ; preds = %1
  ret void, !dbg !230                             ; [debug line = 173:1]
}

; [#uses=1]
define internal fastcc zeroext i8 @GF_multiply(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable {
  call void @llvm.dbg.value(metadata !{i8 %X}, i64 0, metadata !231), !dbg !232 ; [debug line = 38:36] [debug variable = X]
  call void @llvm.dbg.value(metadata !{i8 %Y}, i64 0, metadata !233), !dbg !234 ; [debug line = 38:47] [debug variable = Y]
  %tmp = icmp eq i8 %X, 0, !dbg !235              ; [#uses=1 type=i1] [debug line = 40:3]
  %tmp.33 = icmp eq i8 %Y, 0, !dbg !235           ; [#uses=1 type=i1] [debug line = 40:3]
  %or.cond = or i1 %tmp, %tmp.33, !dbg !235       ; [#uses=1 type=i1] [debug line = 40:3]
  br i1 %or.cond, label %._crit_edge, label %1, !dbg !235 ; [debug line = 40:3]

; <label>:1                                       ; preds = %0
  %tmp.34 = call fastcc zeroext i8 @GF_log(i8 zeroext %X), !dbg !237 ; [#uses=1 type=i8] [debug line = 40:45]
  %tmp.35 = call fastcc zeroext i8 @GF_log(i8 zeroext %Y), !dbg !238 ; [#uses=1 type=i8] [debug line = 40:56]
  %tmp.36 = call fastcc zeroext i8 @Modulo_add(i8 zeroext %tmp.34, i8 zeroext %tmp.35), !dbg !238 ; [#uses=1 type=i8] [debug line = 40:56]
  %tmp.37 = call fastcc zeroext i8 @GF_exp(i8 zeroext %tmp.36), !dbg !238 ; [#uses=1 type=i8] [debug line = 40:56]
  br label %._crit_edge, !dbg !238                ; [debug line = 40:56]

._crit_edge:                                      ; preds = %1, %0
  %tmp.38 = phi i8 [ %tmp.37, %1 ], [ 0, %0 ], !dbg !238 ; [#uses=1 type=i8] [debug line = 40:56]
  ret i8 %tmp.38, !dbg !238                       ; [debug line = 40:56]
}

; [#uses=2]
define internal fastcc zeroext i8 @GF_log(i8 zeroext %X) nounwind uwtable {
  call void @llvm.dbg.value(metadata !{i8 %X}, i64 0, metadata !239), !dbg !240 ; [debug line = 30:31] [debug variable = X]
  %tmp = zext i8 %X to i64, !dbg !241             ; [#uses=1 type=i64] [debug line = 34:3]
  %Table.addr = getelementptr inbounds [256 x i8]* @Table, i64 0, i64 %tmp, !dbg !241 ; [#uses=1 type=i8*] [debug line = 34:3]
  %Table.load = load i8* %Table.addr, align 1, !dbg !241 ; [#uses=2 type=i8] [debug line = 34:3]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i8 %Table.load) nounwind
  ret i8 %Table.load, !dbg !241                   ; [debug line = 34:3]
}

; [#uses=1]
define internal fastcc zeroext i8 @GF_exp(i8 zeroext %X) nounwind uwtable {
  call void @llvm.dbg.value(metadata !{i8 %X}, i64 0, metadata !243), !dbg !244 ; [debug line = 22:31] [debug variable = X]
  %tmp = zext i8 %X to i64, !dbg !245             ; [#uses=1 type=i64] [debug line = 26:3]
  %Table.1.addr = getelementptr inbounds [256 x i8]* @Table.1, i64 0, i64 %tmp, !dbg !245 ; [#uses=1 type=i8*] [debug line = 26:3]
  %Table.1.load = load i8* %Table.1.addr, align 1, !dbg !245 ; [#uses=2 type=i8] [debug line = 26:3]
  call void (...)* @_ssdm_SpecKeepArrayLoad(i8 %Table.1.load) nounwind
  ret i8 %Table.1.load, !dbg !245                 ; [debug line = 26:3]
}

; [#uses=1]
define internal fastcc zeroext i8 @GF_add(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable {
  call void @llvm.dbg.value(metadata !{i8 %X}, i64 0, metadata !247), !dbg !248 ; [debug line = 16:31] [debug variable = X]
  call void @llvm.dbg.value(metadata !{i8 %Y}, i64 0, metadata !249), !dbg !250 ; [debug line = 16:42] [debug variable = Y]
  %tmp = xor i8 %Y, %X, !dbg !251                 ; [#uses=1 type=i8] [debug line = 18:3]
  ret i8 %tmp, !dbg !251                          ; [debug line = 18:3]
}

!llvm.dbg.cu = !{!0, !63}
!opencl.kernels = !{!112, !119, !125, !131, !137, !137, !141, !147, !148, !149}
!hls.encrypted.func = !{}

!0 = metadata !{i32 786449, i32 0, i32 12, metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/RSECore.pragma.2.c", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", metadata !"clang version 3.1 ", i1 true, i1 false, metadata !"", i32 0, metadata !1, metadata !1, metadata !3, metadata !21} ; [ DW_TAG_compile_unit ]
!1 = metadata !{metadata !2}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{metadata !5}
!5 = metadata !{i32 786478, i32 0, metadata !6, metadata !"RSE_core", metadata !"RSE_core", metadata !"", metadata !6, i32 24, metadata !7, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, void (i8, i32, i1, i368, i368*)* @RSE_core, null, null, metadata !19, i32 25} ; [ DW_TAG_subprogram ]
!6 = metadata !{i32 786473, metadata !"RSECore.c", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", null} ; [ DW_TAG_file_type ]
!7 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !8, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!8 = metadata !{null, metadata !9, metadata !11, metadata !13, metadata !15, metadata !18}
!9 = metadata !{i32 786454, null, metadata !"uint8", metadata !6, i32 10, i64 0, i64 0, i64 0, i32 0, metadata !10} ; [ DW_TAG_typedef ]
!10 = metadata !{i32 786468, null, metadata !"uint8", null, i32 0, i64 8, i64 8, i64 0, i32 0, i32 7} ; [ DW_TAG_base_type ]
!11 = metadata !{i32 786454, null, metadata !"uint32", metadata !6, i32 34, i64 0, i64 0, i64 0, i32 0, metadata !12} ; [ DW_TAG_typedef ]
!12 = metadata !{i32 786468, null, metadata !"uint32", null, i32 0, i64 32, i64 32, i64 0, i32 0, i32 7} ; [ DW_TAG_base_type ]
!13 = metadata !{i32 786454, null, metadata !"uint1", metadata !6, i32 3, i64 0, i64 0, i64 0, i32 0, metadata !14} ; [ DW_TAG_typedef ]
!14 = metadata !{i32 786468, null, metadata !"uint1", null, i32 0, i64 1, i64 1, i64 0, i32 0, i32 7} ; [ DW_TAG_base_type ]
!15 = metadata !{i32 786454, null, metadata !"packet_t", metadata !6, i32 17, i64 0, i64 0, i64 0, i32 0, metadata !16} ; [ DW_TAG_typedef ]
!16 = metadata !{i32 786454, null, metadata !"uint368", metadata !6, i32 382, i64 0, i64 0, i64 0, i32 0, metadata !17} ; [ DW_TAG_typedef ]
!17 = metadata !{i32 786468, null, metadata !"uint368", null, i32 0, i64 368, i64 64, i64 0, i32 0, i32 7} ; [ DW_TAG_base_type ]
!18 = metadata !{i32 786447, null, metadata !"", null, i32 0, i64 64, i64 64, i64 0, i32 0, metadata !15} ; [ DW_TAG_pointer_type ]
!19 = metadata !{metadata !20}
!20 = metadata !{i32 786468}                      ; [ DW_TAG_base_type ]
!21 = metadata !{metadata !22}
!22 = metadata !{metadata !23, metadata !50, metadata !54, metadata !58, metadata !61, metadata !62}
!23 = metadata !{i32 786484, i32 0, null, metadata !"fb", metadata !"fb", metadata !"", metadata !24, i32 68, metadata !25, i32 0, i32 1, %struct.fec_block.0* @fb} ; [ DW_TAG_variable ]
!24 = metadata !{i32 786473, metadata !"./rse.h", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", null} ; [ DW_TAG_file_type ]
!25 = metadata !{i32 786451, null, metadata !"fec_block", metadata !24, i32 57, i64 29376, i64 64, i32 0, i32 0, null, metadata !26, i32 0, i32 0} ; [ DW_TAG_structure_type ]
!26 = metadata !{metadata !27, metadata !30, metadata !31, metadata !36, metadata !38, metadata !41, metadata !44, metadata !49}
!27 = metadata !{i32 786445, metadata !25, metadata !"block_C", metadata !24, i32 58, i64 8, i64 8, i64 0, i32 0, metadata !28} ; [ DW_TAG_member ]
!28 = metadata !{i32 786454, null, metadata !"fec_sym", metadata !6, i32 51, i64 0, i64 0, i64 0, i32 0, metadata !29} ; [ DW_TAG_typedef ]
!29 = metadata !{i32 786468, null, metadata !"unsigned char", null, i32 0, i64 8, i64 8, i64 0, i32 0, i32 8} ; [ DW_TAG_base_type ]
!30 = metadata !{i32 786445, metadata !25, metadata !"block_N", metadata !24, i32 59, i64 8, i64 8, i64 8, i32 0, metadata !28} ; [ DW_TAG_member ]
!31 = metadata !{i32 786445, metadata !25, metadata !"pdata", metadata !24, i32 60, i64 16320, i64 64, i64 64, i32 0, metadata !32} ; [ DW_TAG_member ]
!32 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 16320, i64 64, i32 0, i32 0, metadata !33, metadata !34, i32 0, i32 0} ; [ DW_TAG_array_type ]
!33 = metadata !{i32 786447, null, metadata !"", null, i32 0, i64 64, i64 64, i64 0, i32 0, metadata !28} ; [ DW_TAG_pointer_type ]
!34 = metadata !{metadata !35}
!35 = metadata !{i32 786465, i64 0, i64 254}      ; [ DW_TAG_subrange_type ]
!36 = metadata !{i32 786445, metadata !25, metadata !"cbi", metadata !24, i32 61, i64 2040, i64 8, i64 16384, i32 0, metadata !37} ; [ DW_TAG_member ]
!37 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 2040, i64 8, i32 0, i32 0, metadata !28, metadata !34, i32 0, i32 0} ; [ DW_TAG_array_type ]
!38 = metadata !{i32 786445, metadata !25, metadata !"plen", metadata !24, i32 62, i64 8160, i64 32, i64 18432, i32 0, metadata !39} ; [ DW_TAG_member ]
!39 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 8160, i64 32, i32 0, i32 0, metadata !40, metadata !34, i32 0, i32 0} ; [ DW_TAG_array_type ]
!40 = metadata !{i32 786468, null, metadata !"int", null, i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ]
!41 = metadata !{i32 786445, metadata !25, metadata !"pstat", metadata !24, i32 63, i64 2040, i64 8, i64 26592, i32 0, metadata !42} ; [ DW_TAG_member ]
!42 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 2040, i64 8, i32 0, i32 0, metadata !43, metadata !34, i32 0, i32 0} ; [ DW_TAG_array_type ]
!43 = metadata !{i32 786468, null, metadata !"char", null, i32 0, i64 8, i64 8, i64 0, i32 0, i32 6} ; [ DW_TAG_base_type ]
!44 = metadata !{i32 786445, metadata !25, metadata !"d", metadata !24, i32 64, i64 360, i64 8, i64 28632, i32 0, metadata !45} ; [ DW_TAG_member ]
!45 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 360, i64 8, i32 0, i32 0, metadata !28, metadata !46, i32 0, i32 0} ; [ DW_TAG_array_type ]
!46 = metadata !{metadata !47, metadata !48}
!47 = metadata !{i32 786465, i64 0, i64 8}        ; [ DW_TAG_subrange_type ]
!48 = metadata !{i32 786465, i64 0, i64 4}        ; [ DW_TAG_subrange_type ]
!49 = metadata !{i32 786445, metadata !25, metadata !"e", metadata !24, i32 65, i64 360, i64 8, i64 28992, i32 0, metadata !45} ; [ DW_TAG_member ]
!50 = metadata !{i32 786484, i32 0, null, metadata !"data_buffer", metadata !"data_buffer", metadata !"", metadata !6, i32 19, metadata !51, i32 1, i32 1, [8 x i368]* @data_buffer} ; [ DW_TAG_variable ]
!51 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 3072, i64 64, i32 0, i32 0, metadata !15, metadata !52, i32 0, i32 0} ; [ DW_TAG_array_type ]
!52 = metadata !{metadata !53}
!53 = metadata !{i32 786465, i64 0, i64 7}        ; [ DW_TAG_subrange_type ]
!54 = metadata !{i32 786484, i32 0, null, metadata !"parity_buffer", metadata !"parity_buffer", metadata !"", metadata !6, i32 20, metadata !55, i32 1, i32 1, [4 x i368]* @parity_buffer} ; [ DW_TAG_variable ]
!55 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 1536, i64 64, i32 0, i32 0, metadata !15, metadata !56, i32 0, i32 0} ; [ DW_TAG_array_type ]
!56 = metadata !{metadata !57}
!57 = metadata !{i32 786465, i64 0, i64 3}        ; [ DW_TAG_subrange_type ]
!58 = metadata !{i32 786484, i32 0, null, metadata !"_IO_2_1_stdin_", metadata !"_IO_2_1_stdin_", metadata !"", metadata !59, i32 315, metadata !60, i32 0, i32 1, null} ; [ DW_TAG_variable ]
!59 = metadata !{i32 786473, metadata !"/usr/include/libio.h", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", null} ; [ DW_TAG_file_type ]
!60 = metadata !{i32 786451, null, metadata !"_IO_FILE_plus", metadata !59, i32 313, i32 0, i32 0, i32 0, i32 4, null, null, i32 0} ; [ DW_TAG_structure_type ]
!61 = metadata !{i32 786484, i32 0, null, metadata !"_IO_2_1_stdout_", metadata !"_IO_2_1_stdout_", metadata !"", metadata !59, i32 316, metadata !60, i32 0, i32 1, null} ; [ DW_TAG_variable ]
!62 = metadata !{i32 786484, i32 0, null, metadata !"_IO_2_1_stderr_", metadata !"_IO_2_1_stderr_", metadata !"", metadata !59, i32 317, metadata !60, i32 0, i32 1, null} ; [ DW_TAG_variable ]
!63 = metadata !{i32 786449, i32 0, i32 12, metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/Encoder.pragma.2.c", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", metadata !"clang version 3.1 ", i1 true, i1 false, metadata !"", i32 0, metadata !1, metadata !1, metadata !64, metadata !88} ; [ DW_TAG_compile_unit ]
!64 = metadata !{metadata !65}
!65 = metadata !{metadata !66, metadata !72, metadata !75, metadata !78, metadata !81, metadata !82, metadata !85, metadata !86, metadata !87}
!66 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Matrix_multiply_HW", metadata !"Matrix_multiply_HW", metadata !"", metadata !67, i32 151, metadata !68, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, null, null, null, metadata !19, i32 152} ; [ DW_TAG_subprogram ]
!67 = metadata !{i32 786473, metadata !"Encoder.c", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", null} ; [ DW_TAG_file_type ]
!68 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !69, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!69 = metadata !{null, metadata !70, metadata !70, metadata !40, metadata !40}
!70 = metadata !{i32 786447, null, metadata !"", null, i32 0, i64 64, i64 64, i64 0, i32 0, metadata !71} ; [ DW_TAG_pointer_type ]
!71 = metadata !{i32 786454, null, metadata !"fec_sym", metadata !67, i32 51, i64 0, i64 0, i64 0, i32 0, metadata !29} ; [ DW_TAG_typedef ]
!72 = metadata !{i32 786478, i32 0, metadata !67, metadata !"GF_multiply", metadata !"GF_multiply", metadata !"", metadata !67, i32 38, metadata !73, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8, i8)* @GF_multiply, null, null, metadata !19, i32 39} ; [ DW_TAG_subprogram ]
!73 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !74, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!74 = metadata !{metadata !71, metadata !71, metadata !71}
!75 = metadata !{i32 786478, i32 0, metadata !67, metadata !"GF_log", metadata !"GF_log", metadata !"", metadata !67, i32 30, metadata !76, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8)* @GF_log, null, null, metadata !19, i32 31} ; [ DW_TAG_subprogram ]
!76 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !77, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!77 = metadata !{metadata !71, metadata !71}
!78 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Generate_log_table", metadata !"Generate_log_table", metadata !"", metadata !67, i32 88, metadata !79, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, null, null, null, metadata !19, i32 89} ; [ DW_TAG_subprogram ]
!79 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !80, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!80 = metadata !{null, metadata !70}
!81 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Generate_exp_table", metadata !"Generate_exp_table", metadata !"", metadata !67, i32 74, metadata !79, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, null, null, null, metadata !19, i32 75} ; [ DW_TAG_subprogram ]
!82 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Get_primitive_polynomial", metadata !"Get_primitive_polynomial", metadata !"", metadata !67, i32 51, metadata !83, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, null, null, null, metadata !19, i32 52} ; [ DW_TAG_subprogram ]
!83 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !84, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!84 = metadata !{metadata !40}
!85 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Modulo_add", metadata !"Modulo_add", metadata !"", metadata !67, i32 9, metadata !73, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8, i8)* @Modulo_add, null, null, metadata !19, i32 10} ; [ DW_TAG_subprogram ]
!86 = metadata !{i32 786478, i32 0, metadata !67, metadata !"GF_exp", metadata !"GF_exp", metadata !"", metadata !67, i32 22, metadata !76, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8)* @GF_exp, null, null, metadata !19, i32 23} ; [ DW_TAG_subprogram ]
!87 = metadata !{i32 786478, i32 0, metadata !67, metadata !"GF_add", metadata !"GF_add", metadata !"", metadata !67, i32 16, metadata !73, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8, i8)* @GF_add, null, null, metadata !19, i32 17} ; [ DW_TAG_subprogram ]
!88 = metadata !{metadata !89}
!89 = metadata !{metadata !90, metadata !93, metadata !58, metadata !61, metadata !62, metadata !107, metadata !111}
!90 = metadata !{i32 786484, i32 0, metadata !66, metadata !"Generator", metadata !"Generator", metadata !"", metadata !67, i32 156, metadata !91, i32 1, i32 1, [4 x [8 x i8]]* @Generator} ; [ DW_TAG_variable ]
!91 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 256, i64 8, i32 0, i32 0, metadata !71, metadata !92, i32 0, i32 0} ; [ DW_TAG_array_type ]
!92 = metadata !{metadata !57, metadata !53}
!93 = metadata !{i32 786484, i32 0, null, metadata !"fb", metadata !"fb", metadata !"", metadata !24, i32 68, metadata !94, i32 0, i32 1, %struct.fec_block.0* @fb} ; [ DW_TAG_variable ]
!94 = metadata !{i32 786451, null, metadata !"fec_block", metadata !24, i32 57, i64 29376, i64 64, i32 0, i32 0, null, metadata !95, i32 0, i32 0} ; [ DW_TAG_structure_type ]
!95 = metadata !{metadata !96, metadata !97, metadata !98, metadata !100, metadata !102, metadata !103, metadata !104, metadata !106}
!96 = metadata !{i32 786445, metadata !94, metadata !"block_C", metadata !24, i32 58, i64 8, i64 8, i64 0, i32 0, metadata !71} ; [ DW_TAG_member ]
!97 = metadata !{i32 786445, metadata !94, metadata !"block_N", metadata !24, i32 59, i64 8, i64 8, i64 8, i32 0, metadata !71} ; [ DW_TAG_member ]
!98 = metadata !{i32 786445, metadata !94, metadata !"pdata", metadata !24, i32 60, i64 16320, i64 64, i64 64, i32 0, metadata !99} ; [ DW_TAG_member ]
!99 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 16320, i64 64, i32 0, i32 0, metadata !70, metadata !34, i32 0, i32 0} ; [ DW_TAG_array_type ]
!100 = metadata !{i32 786445, metadata !94, metadata !"cbi", metadata !24, i32 61, i64 2040, i64 8, i64 16384, i32 0, metadata !101} ; [ DW_TAG_member ]
!101 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 2040, i64 8, i32 0, i32 0, metadata !71, metadata !34, i32 0, i32 0} ; [ DW_TAG_array_type ]
!102 = metadata !{i32 786445, metadata !94, metadata !"plen", metadata !24, i32 62, i64 8160, i64 32, i64 18432, i32 0, metadata !39} ; [ DW_TAG_member ]
!103 = metadata !{i32 786445, metadata !94, metadata !"pstat", metadata !24, i32 63, i64 2040, i64 8, i64 26592, i32 0, metadata !42} ; [ DW_TAG_member ]
!104 = metadata !{i32 786445, metadata !94, metadata !"d", metadata !24, i32 64, i64 360, i64 8, i64 28632, i32 0, metadata !105} ; [ DW_TAG_member ]
!105 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 360, i64 8, i32 0, i32 0, metadata !71, metadata !46, i32 0, i32 0} ; [ DW_TAG_array_type ]
!106 = metadata !{i32 786445, metadata !94, metadata !"e", metadata !24, i32 65, i64 360, i64 8, i64 28992, i32 0, metadata !105} ; [ DW_TAG_member ]
!107 = metadata !{i32 786484, i32 0, metadata !75, metadata !"Table", metadata !"Table", metadata !"", metadata !67, i32 32, metadata !108, i32 1, i32 1, [256 x i8]* @Table} ; [ DW_TAG_variable ]
!108 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 2048, i64 8, i32 0, i32 0, metadata !71, metadata !109, i32 0, i32 0} ; [ DW_TAG_array_type ]
!109 = metadata !{metadata !110}
!110 = metadata !{i32 786465, i64 0, i64 255}     ; [ DW_TAG_subrange_type ]
!111 = metadata !{i32 786484, i32 0, metadata !86, metadata !"Table", metadata !"Table", metadata !"", metadata !67, i32 24, metadata !108, i32 1, i32 1, [256 x i8]* @Table.1} ; [ DW_TAG_variable ]
!112 = metadata !{void (i8, i32, i1, i368, i368*)* @RSE_core, metadata !113, metadata !114, metadata !115, metadata !116, metadata !117, metadata !118}
!113 = metadata !{metadata !"kernel_arg_addr_space", i32 0, i32 0, i32 0, i32 0, i32 1}
!114 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!115 = metadata !{metadata !"kernel_arg_type", metadata !"uint8", metadata !"uint32", metadata !"uint1", metadata !"packet_t", metadata !"packet_t*"}
!116 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !"", metadata !"", metadata !"", metadata !""}
!117 = metadata !{metadata !"kernel_arg_name", metadata !"operation", metadata !"index", metadata !"is_parity", metadata !"data", metadata !"parity"}
!118 = metadata !{metadata !"reqd_work_group_size", i32 1, i32 1, i32 1}
!119 = metadata !{null, metadata !120, metadata !121, metadata !122, metadata !123, metadata !124, metadata !118}
!120 = metadata !{metadata !"kernel_arg_addr_space", i32 1, i32 1, i32 0, i32 0}
!121 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!122 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym*", metadata !"fec_sym*", metadata !"int", metadata !"int"}
!123 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !"", metadata !"", metadata !""}
!124 = metadata !{metadata !"kernel_arg_name", metadata !"Data", metadata !"Parity", metadata !"k", metadata !"h"}
!125 = metadata !{i8 (i8, i8)* @GF_multiply, metadata !126, metadata !127, metadata !128, metadata !129, metadata !130, metadata !118}
!126 = metadata !{metadata !"kernel_arg_addr_space", i32 0, i32 0}
!127 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none"}
!128 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym", metadata !"fec_sym"}
!129 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !""}
!130 = metadata !{metadata !"kernel_arg_name", metadata !"X", metadata !"Y"}
!131 = metadata !{i8 (i8)* @GF_log, metadata !132, metadata !133, metadata !134, metadata !135, metadata !136, metadata !118}
!132 = metadata !{metadata !"kernel_arg_addr_space", i32 0}
!133 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none"}
!134 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym"}
!135 = metadata !{metadata !"kernel_arg_type_qual", metadata !""}
!136 = metadata !{metadata !"kernel_arg_name", metadata !"X"}
!137 = metadata !{null, metadata !138, metadata !133, metadata !139, metadata !135, metadata !140, metadata !118}
!138 = metadata !{metadata !"kernel_arg_addr_space", i32 1}
!139 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym*"}
!140 = metadata !{metadata !"kernel_arg_name", metadata !"Table"}
!141 = metadata !{null, metadata !142, metadata !143, metadata !144, metadata !145, metadata !146, metadata !118}
!142 = metadata !{metadata !"kernel_arg_addr_space"}
!143 = metadata !{metadata !"kernel_arg_access_qual"}
!144 = metadata !{metadata !"kernel_arg_type"}
!145 = metadata !{metadata !"kernel_arg_type_qual"}
!146 = metadata !{metadata !"kernel_arg_name"}
!147 = metadata !{i8 (i8, i8)* @Modulo_add, metadata !126, metadata !127, metadata !128, metadata !129, metadata !130, metadata !118}
!148 = metadata !{i8 (i8)* @GF_exp, metadata !132, metadata !133, metadata !134, metadata !135, metadata !136, metadata !118}
!149 = metadata !{i8 (i8, i8)* @GF_add, metadata !126, metadata !127, metadata !128, metadata !129, metadata !130, metadata !118}
!150 = metadata !{i32 786689, metadata !5, metadata !"operation", metadata !6, i32 16777240, metadata !9, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!151 = metadata !{i32 24, i32 21, metadata !5, null}
!152 = metadata !{i32 786689, metadata !5, metadata !"index", metadata !6, i32 33554456, metadata !11, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!153 = metadata !{i32 24, i32 39, metadata !5, null}
!154 = metadata !{i32 786689, metadata !5, metadata !"is_parity", metadata !6, i32 50331672, metadata !13, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!155 = metadata !{i32 24, i32 52, metadata !5, null}
!156 = metadata !{i32 786689, metadata !5, metadata !"data", metadata !6, i32 67108888, metadata !15, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!157 = metadata !{i32 24, i32 72, metadata !5, null}
!158 = metadata !{i32 786689, metadata !5, metadata !"parity", metadata !6, i32 83886104, metadata !18, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!159 = metadata !{i32 24, i32 89, metadata !5, null}
!160 = metadata !{i32 26, i32 1, metadata !161, null}
!161 = metadata !{i32 786443, metadata !5, i32 25, i32 1, metadata !6, i32 0} ; [ DW_TAG_lexical_block ]
!162 = metadata !{i32 27, i32 1, metadata !161, null}
!163 = metadata !{i32 31, i32 3, metadata !161, null}
!164 = metadata !{i32 45, i32 9, metadata !165, null}
!165 = metadata !{i32 786443, metadata !166, i32 39, i32 7, metadata !6, i32 3} ; [ DW_TAG_lexical_block ]
!166 = metadata !{i32 786443, metadata !167, i32 38, i32 7, metadata !6, i32 2} ; [ DW_TAG_lexical_block ]
!167 = metadata !{i32 786443, metadata !161, i32 32, i32 3, metadata !6, i32 1} ; [ DW_TAG_lexical_block ]
!168 = metadata !{i32 38, i32 21, metadata !166, null}
!169 = metadata !{i32 34, i32 7, metadata !167, null}
!170 = metadata !{i32 35, i32 7, metadata !167, null}
!171 = metadata !{i32 39, i32 8, metadata !165, null}
!172 = metadata !{i32 40, i32 1, metadata !165, null}
!173 = metadata !{i32 786688, metadata !165, metadata !"input", metadata !6, i32 41, metadata !174, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!174 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 64, i64 8, i32 0, i32 0, metadata !28, metadata !52, i32 0, i32 0} ; [ DW_TAG_array_type ]
!175 = metadata !{i32 41, i32 10, metadata !165, null}
!176 = metadata !{i32 43, i32 11, metadata !177, null}
!177 = metadata !{i32 786443, metadata !165, i32 42, i32 9, metadata !6, i32 4} ; [ DW_TAG_lexical_block ]
!178 = metadata !{i32 42, i32 23, metadata !177, null}
!179 = metadata !{i32 42, i32 32, metadata !177, null}
!180 = metadata !{i32 786688, metadata !177, metadata !"j", metadata !6, i32 42, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!181 = metadata !{i32 786688, metadata !165, metadata !"output", metadata !6, i32 44, metadata !182, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!182 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 32, i64 8, i32 0, i32 0, metadata !28, metadata !56, i32 0, i32 0} ; [ DW_TAG_array_type ]
!183 = metadata !{i32 44, i32 17, metadata !165, null}
!184 = metadata !{i32 47, i32 11, metadata !185, null}
!185 = metadata !{i32 786443, metadata !165, i32 46, i32 9, metadata !6, i32 5} ; [ DW_TAG_lexical_block ]
!186 = metadata !{i32 46, i32 23, metadata !185, null}
!187 = metadata !{i32 46, i32 32, metadata !185, null}
!188 = metadata !{i32 786688, metadata !185, metadata !"j", metadata !6, i32 46, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!189 = metadata !{i32 49, i32 7, metadata !165, null}
!190 = metadata !{i32 38, i32 32, metadata !166, null}
!191 = metadata !{i32 786688, metadata !166, metadata !"i", metadata !6, i32 38, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!192 = metadata !{i32 53, i32 7, metadata !167, null}
!193 = metadata !{i32 54, i32 3, metadata !167, null}
!194 = metadata !{i32 55, i32 1, metadata !161, null}
!195 = metadata !{i32 786689, metadata !85, metadata !"X", metadata !67, i32 16777225, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!196 = metadata !{i32 9, i32 35, metadata !85, null}
!197 = metadata !{i32 786689, metadata !85, metadata !"Y", metadata !67, i32 33554441, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!198 = metadata !{i32 9, i32 46, metadata !85, null}
!199 = metadata !{i32 11, i32 18, metadata !200, null}
!200 = metadata !{i32 786443, metadata !85, i32 10, i32 1, metadata !67, i32 13} ; [ DW_TAG_lexical_block ]
!201 = metadata !{i32 786688, metadata !200, metadata !"Sum", metadata !67, i32 11, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!202 = metadata !{i32 12, i32 3, metadata !200, null}
!203 = metadata !{i32 786689, metadata !66, metadata !"Data", metadata !67, i32 16777367, metadata !70, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!204 = metadata !{i32 151, i32 33, metadata !66, null}
!205 = metadata !{i32 786689, metadata !66, metadata !"Parity", metadata !67, i32 33554583, metadata !70, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!206 = metadata !{i32 151, i32 144, metadata !66, null}
!207 = metadata !{i32 152, i32 2, metadata !208, null}
!208 = metadata !{i32 786443, metadata !66, i32 152, i32 1, metadata !67, i32 0} ; [ DW_TAG_lexical_block ]
!209 = metadata !{i32 152, i32 102, metadata !208, null}
!210 = metadata !{i32 153, i32 1, metadata !208, null}
!211 = metadata !{i32 154, i32 1, metadata !208, null}
!212 = metadata !{i32 159, i32 1, metadata !208, null}
!213 = metadata !{i32 162, i32 17, metadata !214, null}
!214 = metadata !{i32 786443, metadata !208, i32 162, i32 3, metadata !67, i32 1} ; [ DW_TAG_lexical_block ]
!215 = metadata !{i32 164, i32 5, metadata !216, null}
!216 = metadata !{i32 786443, metadata !214, i32 163, i32 3, metadata !67, i32 2} ; [ DW_TAG_lexical_block ]
!217 = metadata !{i32 169, i32 35, metadata !218, null}
!218 = metadata !{i32 786443, metadata !219, i32 167, i32 7, metadata !67, i32 4} ; [ DW_TAG_lexical_block ]
!219 = metadata !{i32 786443, metadata !216, i32 165, i32 5, metadata !67, i32 3} ; [ DW_TAG_lexical_block ]
!220 = metadata !{i32 167, i32 21, metadata !218, null}
!221 = metadata !{i32 168, i32 9, metadata !218, null}
!222 = metadata !{i32 169, i32 20, metadata !218, null}
!223 = metadata !{i32 786688, metadata !219, metadata !"Result", metadata !67, i32 166, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!224 = metadata !{i32 167, i32 124, metadata !218, null}
!225 = metadata !{i32 786688, metadata !218, metadata !"j", metadata !67, i32 167, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!226 = metadata !{i32 170, i32 7, metadata !219, null}
!227 = metadata !{i32 171, i32 5, metadata !219, null}
!228 = metadata !{i32 162, i32 47, metadata !214, null}
!229 = metadata !{i32 786688, metadata !214, metadata !"i", metadata !67, i32 162, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!230 = metadata !{i32 173, i32 1, metadata !208, null}
!231 = metadata !{i32 786689, metadata !72, metadata !"X", metadata !67, i32 16777254, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!232 = metadata !{i32 38, i32 36, metadata !72, null}
!233 = metadata !{i32 786689, metadata !72, metadata !"Y", metadata !67, i32 33554470, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!234 = metadata !{i32 38, i32 47, metadata !72, null}
!235 = metadata !{i32 40, i32 3, metadata !236, null}
!236 = metadata !{i32 786443, metadata !72, i32 39, i32 1, metadata !67, i32 5} ; [ DW_TAG_lexical_block ]
!237 = metadata !{i32 40, i32 45, metadata !236, null}
!238 = metadata !{i32 40, i32 56, metadata !236, null}
!239 = metadata !{i32 786689, metadata !75, metadata !"X", metadata !67, i32 16777246, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!240 = metadata !{i32 30, i32 31, metadata !75, null}
!241 = metadata !{i32 34, i32 3, metadata !242, null}
!242 = metadata !{i32 786443, metadata !75, i32 31, i32 1, metadata !67, i32 6} ; [ DW_TAG_lexical_block ]
!243 = metadata !{i32 786689, metadata !86, metadata !"X", metadata !67, i32 16777238, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!244 = metadata !{i32 22, i32 31, metadata !86, null}
!245 = metadata !{i32 26, i32 3, metadata !246, null}
!246 = metadata !{i32 786443, metadata !86, i32 23, i32 1, metadata !67, i32 14} ; [ DW_TAG_lexical_block ]
!247 = metadata !{i32 786689, metadata !87, metadata !"X", metadata !67, i32 16777232, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!248 = metadata !{i32 16, i32 31, metadata !87, null}
!249 = metadata !{i32 786689, metadata !87, metadata !"Y", metadata !67, i32 33554448, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!250 = metadata !{i32 16, i32 42, metadata !87, null}
!251 = metadata !{i32 18, i32 3, metadata !252, null}
!252 = metadata !{i32 786443, metadata !87, i32 17, i32 1, metadata !67, i32 15} ; [ DW_TAG_lexical_block ]
