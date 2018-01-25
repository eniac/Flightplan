; ModuleID = '/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/a.o.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.fec_block = type { i8, i8, [255 x i8*], [255 x i8], [255 x i32], [255 x i8], [9 x [5 x i8]], [9 x [5 x i8]] }

@data_buffer = internal global [8 x i368] zeroinitializer, align 16 ; [#uses=3 type=[8 x i368]*]
@.str = private unnamed_addr constant [9 x i8] c"COMPLETE\00", align 1 ; [#uses=1 type=[9 x i8]*]
@.str1 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1 ; [#uses=1 type=[1 x i8]*]
@parity_buffer = internal global [4 x i368] zeroinitializer, align 16 ; [#uses=4 type=[4 x i368]*]
@.str2 = private unnamed_addr constant [12 x i8] c"hls_label_0\00", align 1 ; [#uses=1 type=[12 x i8]*]
@fb = common global %struct.fec_block zeroinitializer, align 8 ; [#uses=0 type=%struct.fec_block*]
@_IO_2_1_stdin_ = external global %struct.fec_block ; [#uses=0 type=%struct.fec_block*]
@_IO_2_1_stdout_ = external global %struct.fec_block ; [#uses=0 type=%struct.fec_block*]
@_IO_2_1_stderr_ = external global %struct.fec_block ; [#uses=0 type=%struct.fec_block*]
@.str3 = private unnamed_addr constant [9 x i8] c"COMPLETE\00", align 1 ; [#uses=1 type=[9 x i8]*]
@.str14 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1 ; [#uses=1 type=[1 x i8]*]
@Matrix_multiply_HW.Generator = internal global [4 x [8 x i8]] [[8 x i8] c"Lg\953\F8\AAa6", [8 x i8] c"\C4\A2#\E4\EB)#/", [8 x i8] c"\D6.OxNn\96}", [8 x i8] c"_\EA\F8\AE\5C\EC\D5e"], align 16 ; [#uses=2 type=[4 x [8 x i8]]*]
@GF_log.Table = internal global [256 x i8] zeroinitializer, align 16 ; [#uses=2 type=[256 x i8]*]
@GF_exp.Table = internal global [256 x i8] zeroinitializer, align 16 ; [#uses=2 type=[256 x i8]*]

; [#uses=0]
define void @RSE_core(i8 zeroext %operation, i32 %index, i1 zeroext %is_parity, i368 %data, i368* %parity) nounwind uwtable {
  %1 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  %2 = alloca i32, align 4                        ; [#uses=3 type=i32*]
  %3 = alloca i1, align 1                         ; [#uses=1 type=i1*]
  %4 = alloca i368, align 8                       ; [#uses=2 type=i368*]
  %5 = alloca i368*, align 8                      ; [#uses=2 type=i368**]
  %k = alloca i32, align 4                        ; [#uses=3 type=i32*]
  %h = alloca i32, align 4                        ; [#uses=3 type=i32*]
  %i = alloca i32, align 4                        ; [#uses=7 type=i32*]
  %input = alloca [8 x i8], align 1               ; [#uses=2 type=[8 x i8]*]
  %j = alloca i32, align 4                        ; [#uses=6 type=i32*]
  %output = alloca [4 x i8], align 1              ; [#uses=2 type=[4 x i8]*]
  %j1 = alloca i32, align 4                       ; [#uses=7 type=i32*]
  store i8 %operation, i8* %1, align 1
  call void @llvm.dbg.declare(metadata !{i8* %1}, metadata !151), !dbg !152 ; [debug line = 24:21] [debug variable = operation]
  store i32 %index, i32* %2, align 4
  call void @llvm.dbg.declare(metadata !{i32* %2}, metadata !153), !dbg !154 ; [debug line = 24:39] [debug variable = index]
  store i1 %is_parity, i1* %3, align 1
  call void @llvm.dbg.declare(metadata !{i1* %3}, metadata !155), !dbg !156 ; [debug line = 24:52] [debug variable = is_parity]
  store i368 %data, i368* %4, align 8
  call void @llvm.dbg.declare(metadata !{i368* %4}, metadata !157), !dbg !158 ; [debug line = 24:72] [debug variable = data]
  store i368* %parity, i368** %5, align 8
  call void @llvm.dbg.declare(metadata !{i368** %5}, metadata !159), !dbg !160 ; [debug line = 24:89] [debug variable = parity]
  call void (...)* @_ssdm_SpecArrayPartition(i368* getelementptr inbounds ([8 x i368]* @data_buffer, i32 0, i32 0), i32 1, i8* getelementptr inbounds ([9 x i8]* @.str, i32 0, i32 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str1, i32 0, i32 0)) nounwind, !dbg !161 ; [debug line = 26:1]
  call void (...)* @_ssdm_SpecArrayPartition(i368* getelementptr inbounds ([4 x i368]* @parity_buffer, i32 0, i32 0), i32 1, i8* getelementptr inbounds ([9 x i8]* @.str, i32 0, i32 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str1, i32 0, i32 0)) nounwind, !dbg !163 ; [debug line = 27:1]
  call void @llvm.dbg.declare(metadata !{i32* %k}, metadata !164), !dbg !165 ; [debug line = 28:6] [debug variable = k]
  store i32 8, i32* %k, align 4, !dbg !166        ; [debug line = 28:105]
  call void @llvm.dbg.declare(metadata !{i32* %h}, metadata !167), !dbg !168 ; [debug line = 29:7] [debug variable = h]
  store i32 4, i32* %h, align 4, !dbg !169        ; [debug line = 29:33]
  %6 = load i8* %1, align 1, !dbg !170            ; [#uses=1 type=i8] [debug line = 31:3]
  %7 = zext i8 %6 to i32, !dbg !170               ; [#uses=1 type=i32] [debug line = 31:3]
  switch i32 %7, label %83 [
    i32 1, label %8
    i32 2, label %13
    i32 4, label %77
  ], !dbg !170                                    ; [debug line = 31:3]

; <label>:8                                       ; preds = %0
  %9 = load i368* %4, align 8, !dbg !171          ; [#uses=1 type=i368] [debug line = 34:7]
  %10 = load i32* %2, align 4, !dbg !171          ; [#uses=1 type=i32] [debug line = 34:7]
  %11 = zext i32 %10 to i64, !dbg !171            ; [#uses=1 type=i64] [debug line = 34:7]
  %12 = getelementptr inbounds [8 x i368]* @data_buffer, i32 0, i64 %11, !dbg !171 ; [#uses=1 type=i368*] [debug line = 34:7]
  store i368 %9, i368* %12, align 8, !dbg !171    ; [debug line = 34:7]
  br label %83, !dbg !173                         ; [debug line = 35:7]

; <label>:13                                      ; preds = %0
  call void @llvm.dbg.declare(metadata !{i32* %i}, metadata !174), !dbg !176 ; [debug line = 38:16] [debug variable = i]
  store i32 0, i32* %i, align 4, !dbg !177        ; [debug line = 38:21]
  br label %14, !dbg !177                         ; [debug line = 38:21]

; <label>:14                                      ; preds = %73, %13
  %15 = load i32* %i, align 4, !dbg !177          ; [#uses=1 type=i32] [debug line = 38:21]
  %16 = icmp slt i32 %15, 368, !dbg !177          ; [#uses=1 type=i1] [debug line = 38:21]
  br i1 %16, label %17, label %76, !dbg !177      ; [debug line = 38:21]

; <label>:17                                      ; preds = %14
  call void (...)* @_ssdm_RegionBegin(i8* getelementptr inbounds ([12 x i8]* @.str2, i32 0, i32 0)) nounwind, !dbg !178 ; [debug line = 39:8]
  call void (...)* @_ssdm_op_SpecPipeline(i32 -1, i32 1, i32 1, i32 0, i8* getelementptr inbounds ([1 x i8]* @.str1, i32 0, i32 0)) nounwind, !dbg !180 ; [debug line = 40:1]
  call void @llvm.dbg.declare(metadata !{[8 x i8]* %input}, metadata !181), !dbg !183 ; [debug line = 41:10] [debug variable = input]
  call void @llvm.dbg.declare(metadata !{i32* %j}, metadata !184), !dbg !186 ; [debug line = 42:18] [debug variable = j]
  store i32 0, i32* %j, align 4, !dbg !187        ; [debug line = 42:23]
  br label %18, !dbg !187                         ; [debug line = 42:23]

; <label>:18                                      ; preds = %35, %17
  %19 = load i32* %j, align 4, !dbg !187          ; [#uses=1 type=i32] [debug line = 42:23]
  %20 = load i32* %k, align 4, !dbg !187          ; [#uses=1 type=i32] [debug line = 42:23]
  %21 = icmp slt i32 %19, %20, !dbg !187          ; [#uses=1 type=i1] [debug line = 42:23]
  br i1 %21, label %22, label %38, !dbg !187      ; [debug line = 42:23]

; <label>:22                                      ; preds = %18
  %23 = load i32* %j, align 4, !dbg !188          ; [#uses=1 type=i32] [debug line = 43:11]
  %24 = sext i32 %23 to i64, !dbg !188            ; [#uses=1 type=i64] [debug line = 43:11]
  %25 = getelementptr inbounds [8 x i368]* @data_buffer, i32 0, i64 %24, !dbg !188 ; [#uses=1 type=i368*] [debug line = 43:11]
  %26 = load i368* %25, align 8, !dbg !188        ; [#uses=1 type=i368] [debug line = 43:11]
  %27 = load i32* %i, align 4, !dbg !188          ; [#uses=1 type=i32] [debug line = 43:11]
  %28 = zext i32 %27 to i368, !dbg !188           ; [#uses=1 type=i368] [debug line = 43:11]
  %29 = lshr i368 %26, %28, !dbg !188             ; [#uses=1 type=i368] [debug line = 43:11]
  %30 = and i368 %29, 255, !dbg !188              ; [#uses=1 type=i368] [debug line = 43:11]
  %31 = trunc i368 %30 to i8, !dbg !188           ; [#uses=1 type=i8] [debug line = 43:11]
  %32 = load i32* %j, align 4, !dbg !188          ; [#uses=1 type=i32] [debug line = 43:11]
  %33 = sext i32 %32 to i64, !dbg !188            ; [#uses=1 type=i64] [debug line = 43:11]
  %34 = getelementptr inbounds [8 x i8]* %input, i32 0, i64 %33, !dbg !188 ; [#uses=1 type=i8*] [debug line = 43:11]
  store i8 %31, i8* %34, align 1, !dbg !188       ; [debug line = 43:11]
  br label %35, !dbg !188                         ; [debug line = 43:11]

; <label>:35                                      ; preds = %22
  %36 = load i32* %j, align 4, !dbg !189          ; [#uses=1 type=i32] [debug line = 42:32]
  %37 = add nsw i32 %36, 1, !dbg !189             ; [#uses=1 type=i32] [debug line = 42:32]
  store i32 %37, i32* %j, align 4, !dbg !189      ; [debug line = 42:32]
  br label %18, !dbg !189                         ; [debug line = 42:32]

; <label>:38                                      ; preds = %18
  call void @llvm.dbg.declare(metadata !{[4 x i8]* %output}, metadata !190), !dbg !192 ; [debug line = 44:17] [debug variable = output]
  %39 = getelementptr inbounds [8 x i8]* %input, i32 0, i32 0, !dbg !193 ; [#uses=1 type=i8*] [debug line = 45:9]
  %40 = getelementptr inbounds [4 x i8]* %output, i32 0, i32 0, !dbg !193 ; [#uses=1 type=i8*] [debug line = 45:9]
  %41 = load i32* %k, align 4, !dbg !193          ; [#uses=1 type=i32] [debug line = 45:9]
  %42 = load i32* %h, align 4, !dbg !193          ; [#uses=1 type=i32] [debug line = 45:9]
  call void @Matrix_multiply_HW(i8* %39, i8* %40, i32 %41, i32 %42), !dbg !193 ; [debug line = 45:9]
  call void @llvm.dbg.declare(metadata !{i32* %j1}, metadata !194), !dbg !196 ; [debug line = 46:18] [debug variable = j]
  store i32 0, i32* %j1, align 4, !dbg !197       ; [debug line = 46:23]
  br label %43, !dbg !197                         ; [debug line = 46:23]

; <label>:43                                      ; preds = %69, %38
  %44 = load i32* %j1, align 4, !dbg !197         ; [#uses=1 type=i32] [debug line = 46:23]
  %45 = load i32* %h, align 4, !dbg !197          ; [#uses=1 type=i32] [debug line = 46:23]
  %46 = icmp slt i32 %44, %45, !dbg !197          ; [#uses=1 type=i1] [debug line = 46:23]
  br i1 %46, label %47, label %72, !dbg !197      ; [debug line = 46:23]

; <label>:47                                      ; preds = %43
  %48 = load i32* %j1, align 4, !dbg !198         ; [#uses=1 type=i32] [debug line = 47:11]
  %49 = sext i32 %48 to i64, !dbg !198            ; [#uses=1 type=i64] [debug line = 47:11]
  %50 = getelementptr inbounds [4 x i368]* @parity_buffer, i32 0, i64 %49, !dbg !198 ; [#uses=1 type=i368*] [debug line = 47:11]
  %51 = load i368* %50, align 8, !dbg !198        ; [#uses=1 type=i368] [debug line = 47:11]
  %52 = load i32* %i, align 4, !dbg !198          ; [#uses=1 type=i32] [debug line = 47:11]
  %53 = zext i32 %52 to i368, !dbg !198           ; [#uses=1 type=i368] [debug line = 47:11]
  %54 = shl i368 255, %53, !dbg !198              ; [#uses=1 type=i368] [debug line = 47:11]
  %55 = xor i368 %54, -1, !dbg !198               ; [#uses=1 type=i368] [debug line = 47:11]
  %56 = and i368 %51, %55, !dbg !198              ; [#uses=1 type=i368] [debug line = 47:11]
  %57 = load i32* %j1, align 4, !dbg !198         ; [#uses=1 type=i32] [debug line = 47:11]
  %58 = sext i32 %57 to i64, !dbg !198            ; [#uses=1 type=i64] [debug line = 47:11]
  %59 = getelementptr inbounds [4 x i8]* %output, i32 0, i64 %58, !dbg !198 ; [#uses=1 type=i8*] [debug line = 47:11]
  %60 = load i8* %59, align 1, !dbg !198          ; [#uses=1 type=i8] [debug line = 47:11]
  %61 = zext i8 %60 to i368, !dbg !198            ; [#uses=1 type=i368] [debug line = 47:11]
  %62 = load i32* %i, align 4, !dbg !198          ; [#uses=1 type=i32] [debug line = 47:11]
  %63 = zext i32 %62 to i368, !dbg !198           ; [#uses=1 type=i368] [debug line = 47:11]
  %64 = shl i368 %61, %63, !dbg !198              ; [#uses=1 type=i368] [debug line = 47:11]
  %65 = or i368 %56, %64, !dbg !198               ; [#uses=1 type=i368] [debug line = 47:11]
  %66 = load i32* %j1, align 4, !dbg !198         ; [#uses=1 type=i32] [debug line = 47:11]
  %67 = sext i32 %66 to i64, !dbg !198            ; [#uses=1 type=i64] [debug line = 47:11]
  %68 = getelementptr inbounds [4 x i368]* @parity_buffer, i32 0, i64 %67, !dbg !198 ; [#uses=1 type=i368*] [debug line = 47:11]
  store i368 %65, i368* %68, align 8, !dbg !198   ; [debug line = 47:11]
  br label %69, !dbg !198                         ; [debug line = 47:11]

; <label>:69                                      ; preds = %47
  %70 = load i32* %j1, align 4, !dbg !199         ; [#uses=1 type=i32] [debug line = 46:32]
  %71 = add nsw i32 %70, 1, !dbg !199             ; [#uses=1 type=i32] [debug line = 46:32]
  store i32 %71, i32* %j1, align 4, !dbg !199     ; [debug line = 46:32]
  br label %43, !dbg !199                         ; [debug line = 46:32]

; <label>:72                                      ; preds = %43
  call void (...)* @_ssdm_RegionEnd(i8* getelementptr inbounds ([12 x i8]* @.str2, i32 0, i32 0)) nounwind, !dbg !200 ; [debug line = 49:7]
  br label %73, !dbg !200                         ; [debug line = 49:7]

; <label>:73                                      ; preds = %72
  %74 = load i32* %i, align 4, !dbg !201          ; [#uses=1 type=i32] [debug line = 38:32]
  %75 = add nsw i32 %74, 8, !dbg !201             ; [#uses=1 type=i32] [debug line = 38:32]
  store i32 %75, i32* %i, align 4, !dbg !201      ; [debug line = 38:32]
  br label %14, !dbg !201                         ; [debug line = 38:32]

; <label>:76                                      ; preds = %14
  br label %83, !dbg !202                         ; [debug line = 50:7]

; <label>:77                                      ; preds = %0
  %78 = load i32* %2, align 4, !dbg !203          ; [#uses=1 type=i32] [debug line = 53:7]
  %79 = zext i32 %78 to i64, !dbg !203            ; [#uses=1 type=i64] [debug line = 53:7]
  %80 = getelementptr inbounds [4 x i368]* @parity_buffer, i32 0, i64 %79, !dbg !203 ; [#uses=1 type=i368*] [debug line = 53:7]
  %81 = load i368* %80, align 8, !dbg !203        ; [#uses=1 type=i368] [debug line = 53:7]
  %82 = load i368** %5, align 8, !dbg !203        ; [#uses=1 type=i368*] [debug line = 53:7]
  store i368 %81, i368* %82, align 8, !dbg !203   ; [debug line = 53:7]
  br label %83, !dbg !204                         ; [debug line = 54:3]

; <label>:83                                      ; preds = %77, %76, %8, %0
  ret void, !dbg !205                             ; [debug line = 55:1]
}

; [#uses=35]
declare void @llvm.dbg.declare(metadata, metadata) nounwind readnone

; [#uses=5]
declare void @_ssdm_SpecArrayPartition(...) nounwind

; [#uses=1]
declare void @_ssdm_RegionBegin(...) nounwind

; [#uses=1]
declare void @_ssdm_op_SpecPipeline(...) nounwind

; [#uses=1]
declare void @_ssdm_RegionEnd(...) nounwind

; [#uses=1]
define void @Matrix_multiply_HW(i8* %Data, i8* %Parity, i32 %k, i32 %h) nounwind uwtable {
  %1 = alloca i8*, align 8                        ; [#uses=4 type=i8**]
  %2 = alloca i8*, align 8                        ; [#uses=4 type=i8**]
  %3 = alloca i32, align 4                        ; [#uses=2 type=i32*]
  %4 = alloca i32, align 4                        ; [#uses=2 type=i32*]
  %i = alloca i32, align 4                        ; [#uses=7 type=i32*]
  %Result = alloca i32, align 4                   ; [#uses=4 type=i32*]
  %j = alloca i32, align 4                        ; [#uses=7 type=i32*]
  store i8* %Data, i8** %1, align 8
  call void @llvm.dbg.declare(metadata !{i8** %1}, metadata !206), !dbg !207 ; [debug line = 151:33] [debug variable = Data]
  store i8* %Parity, i8** %2, align 8
  call void @llvm.dbg.declare(metadata !{i8** %2}, metadata !208), !dbg !209 ; [debug line = 151:144] [debug variable = Parity]
  store i32 %k, i32* %3, align 4
  call void @llvm.dbg.declare(metadata !{i32* %3}, metadata !210), !dbg !211 ; [debug line = 151:180] [debug variable = k]
  store i32 %h, i32* %4, align 4
  call void @llvm.dbg.declare(metadata !{i32* %4}, metadata !212), !dbg !213 ; [debug line = 151:187] [debug variable = h]
  %5 = load i8** %1, align 8, !dbg !214           ; [#uses=1 type=i8*] [debug line = 152:2]
  call void (...)* @_ssdm_SpecArrayDimSize(i8* %5, i32 8) nounwind, !dbg !214 ; [debug line = 152:2]
  %6 = load i8** %2, align 8, !dbg !216           ; [#uses=1 type=i8*] [debug line = 152:102]
  call void (...)* @_ssdm_SpecArrayDimSize(i8* %6, i32 4) nounwind, !dbg !216 ; [debug line = 152:102]
  %7 = load i8** %1, align 8, !dbg !217           ; [#uses=1 type=i8*] [debug line = 153:1]
  call void (...)* @_ssdm_SpecArrayPartition(i8* %7, i32 1, i8* getelementptr inbounds ([9 x i8]* @.str3, i32 0, i32 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str14, i32 0, i32 0)) nounwind, !dbg !217 ; [debug line = 153:1]
  %8 = load i8** %2, align 8, !dbg !218           ; [#uses=1 type=i8*] [debug line = 154:1]
  call void (...)* @_ssdm_SpecArrayPartition(i8* %8, i32 1, i8* getelementptr inbounds ([9 x i8]* @.str3, i32 0, i32 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str14, i32 0, i32 0)) nounwind, !dbg !218 ; [debug line = 154:1]
  call void (...)* @_ssdm_SpecArrayPartition([8 x i8]* getelementptr inbounds ([4 x [8 x i8]]* @Matrix_multiply_HW.Generator, i32 0, i32 0), i32 0, i8* getelementptr inbounds ([9 x i8]* @.str3, i32 0, i32 0), i32 0, i8* getelementptr inbounds ([1 x i8]* @.str14, i32 0, i32 0)) nounwind, !dbg !219 ; [debug line = 159:1]
  call void @llvm.dbg.declare(metadata !{i32* %i}, metadata !220), !dbg !222 ; [debug line = 162:12] [debug variable = i]
  store i32 0, i32* %i, align 4, !dbg !223        ; [debug line = 162:17]
  br label %9, !dbg !223                          ; [debug line = 162:17]

; <label>:9                                       ; preds = %54, %0
  %10 = load i32* %i, align 4, !dbg !223          ; [#uses=1 type=i32] [debug line = 162:17]
  %11 = icmp slt i32 %10, 4, !dbg !223            ; [#uses=1 type=i1] [debug line = 162:17]
  br i1 %11, label %12, label %57, !dbg !223      ; [debug line = 162:17]

; <label>:12                                      ; preds = %9
  %13 = load i32* %i, align 4, !dbg !224          ; [#uses=1 type=i32] [debug line = 164:5]
  %14 = load i32* %4, align 4, !dbg !224          ; [#uses=1 type=i32] [debug line = 164:5]
  %15 = icmp slt i32 %13, %14, !dbg !224          ; [#uses=1 type=i1] [debug line = 164:5]
  br i1 %15, label %16, label %53, !dbg !224      ; [debug line = 164:5]

; <label>:16                                      ; preds = %12
  call void @llvm.dbg.declare(metadata !{i32* %Result}, metadata !226), !dbg !228 ; [debug line = 166:11] [debug variable = Result]
  store i32 0, i32* %Result, align 4, !dbg !229   ; [debug line = 166:21]
  call void @llvm.dbg.declare(metadata !{i32* %j}, metadata !230), !dbg !232 ; [debug line = 167:16] [debug variable = j]
  store i32 0, i32* %j, align 4, !dbg !233        ; [debug line = 167:21]
  br label %17, !dbg !233                         ; [debug line = 167:21]

; <label>:17                                      ; preds = %43, %16
  %18 = load i32* %j, align 4, !dbg !233          ; [#uses=1 type=i32] [debug line = 167:21]
  %19 = icmp slt i32 %18, 8, !dbg !233            ; [#uses=1 type=i1] [debug line = 167:21]
  br i1 %19, label %20, label %46, !dbg !233      ; [debug line = 167:21]

; <label>:20                                      ; preds = %17
  %21 = load i32* %j, align 4, !dbg !234          ; [#uses=1 type=i32] [debug line = 168:9]
  %22 = load i32* %3, align 4, !dbg !234          ; [#uses=1 type=i32] [debug line = 168:9]
  %23 = icmp slt i32 %21, %22, !dbg !234          ; [#uses=1 type=i1] [debug line = 168:9]
  br i1 %23, label %24, label %42, !dbg !234      ; [debug line = 168:9]

; <label>:24                                      ; preds = %20
  %25 = load i32* %Result, align 4, !dbg !235     ; [#uses=1 type=i32] [debug line = 169:20]
  %26 = trunc i32 %25 to i8, !dbg !235            ; [#uses=1 type=i8] [debug line = 169:20]
  %27 = load i32* %j, align 4, !dbg !236          ; [#uses=1 type=i32] [debug line = 169:35]
  %28 = sext i32 %27 to i64, !dbg !236            ; [#uses=1 type=i64] [debug line = 169:35]
  %29 = load i8** %1, align 8, !dbg !236          ; [#uses=1 type=i8*] [debug line = 169:35]
  %30 = getelementptr inbounds i8* %29, i64 %28, !dbg !236 ; [#uses=1 type=i8*] [debug line = 169:35]
  %31 = load i8* %30, align 1, !dbg !236          ; [#uses=1 type=i8] [debug line = 169:35]
  %32 = load i32* %j, align 4, !dbg !236          ; [#uses=1 type=i32] [debug line = 169:35]
  %33 = sext i32 %32 to i64, !dbg !236            ; [#uses=1 type=i64] [debug line = 169:35]
  %34 = load i32* %i, align 4, !dbg !236          ; [#uses=1 type=i32] [debug line = 169:35]
  %35 = sext i32 %34 to i64, !dbg !236            ; [#uses=1 type=i64] [debug line = 169:35]
  %36 = getelementptr inbounds [4 x [8 x i8]]* @Matrix_multiply_HW.Generator, i32 0, i64 %35, !dbg !236 ; [#uses=1 type=[8 x i8]*] [debug line = 169:35]
  %37 = getelementptr inbounds [8 x i8]* %36, i32 0, i64 %33, !dbg !236 ; [#uses=1 type=i8*] [debug line = 169:35]
  %38 = load i8* %37, align 1, !dbg !236          ; [#uses=1 type=i8] [debug line = 169:35]
  %39 = call zeroext i8 @GF_multiply(i8 zeroext %31, i8 zeroext %38), !dbg !236 ; [#uses=1 type=i8] [debug line = 169:35]
  %40 = call zeroext i8 @GF_add(i8 zeroext %26, i8 zeroext %39), !dbg !236 ; [#uses=1 type=i8] [debug line = 169:35]
  %41 = zext i8 %40 to i32, !dbg !236             ; [#uses=1 type=i32] [debug line = 169:35]
  store i32 %41, i32* %Result, align 4, !dbg !236 ; [debug line = 169:35]
  br label %42, !dbg !236                         ; [debug line = 169:35]

; <label>:42                                      ; preds = %24, %20
  br label %43, !dbg !236                         ; [debug line = 169:35]

; <label>:43                                      ; preds = %42
  %44 = load i32* %j, align 4, !dbg !237          ; [#uses=1 type=i32] [debug line = 167:124]
  %45 = add nsw i32 %44, 1, !dbg !237             ; [#uses=1 type=i32] [debug line = 167:124]
  store i32 %45, i32* %j, align 4, !dbg !237      ; [debug line = 167:124]
  br label %17, !dbg !237                         ; [debug line = 167:124]

; <label>:46                                      ; preds = %17
  %47 = load i32* %Result, align 4, !dbg !238     ; [#uses=1 type=i32] [debug line = 170:7]
  %48 = trunc i32 %47 to i8, !dbg !238            ; [#uses=1 type=i8] [debug line = 170:7]
  %49 = load i32* %i, align 4, !dbg !238          ; [#uses=1 type=i32] [debug line = 170:7]
  %50 = sext i32 %49 to i64, !dbg !238            ; [#uses=1 type=i64] [debug line = 170:7]
  %51 = load i8** %2, align 8, !dbg !238          ; [#uses=1 type=i8*] [debug line = 170:7]
  %52 = getelementptr inbounds i8* %51, i64 %50, !dbg !238 ; [#uses=1 type=i8*] [debug line = 170:7]
  store i8 %48, i8* %52, align 1, !dbg !238       ; [debug line = 170:7]
  br label %53, !dbg !239                         ; [debug line = 171:5]

; <label>:53                                      ; preds = %46, %12
  br label %54, !dbg !240                         ; [debug line = 172:3]

; <label>:54                                      ; preds = %53
  %55 = load i32* %i, align 4, !dbg !241          ; [#uses=1 type=i32] [debug line = 162:47]
  %56 = add nsw i32 %55, 1, !dbg !241             ; [#uses=1 type=i32] [debug line = 162:47]
  store i32 %56, i32* %i, align 4, !dbg !241      ; [debug line = 162:47]
  br label %9, !dbg !241                          ; [debug line = 162:47]

; <label>:57                                      ; preds = %9
  ret void, !dbg !242                             ; [debug line = 173:1]
}

; [#uses=4]
declare void @_ssdm_SpecArrayDimSize(...) nounwind

; [#uses=1]
define internal zeroext i8 @GF_add(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable {
  %1 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  %2 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  store i8 %X, i8* %1, align 1
  call void @llvm.dbg.declare(metadata !{i8* %1}, metadata !243), !dbg !244 ; [debug line = 16:31] [debug variable = X]
  store i8 %Y, i8* %2, align 1
  call void @llvm.dbg.declare(metadata !{i8* %2}, metadata !245), !dbg !246 ; [debug line = 16:42] [debug variable = Y]
  %3 = load i8* %1, align 1, !dbg !247            ; [#uses=1 type=i8] [debug line = 18:3]
  %4 = zext i8 %3 to i32, !dbg !247               ; [#uses=1 type=i32] [debug line = 18:3]
  %5 = load i8* %2, align 1, !dbg !247            ; [#uses=1 type=i8] [debug line = 18:3]
  %6 = zext i8 %5 to i32, !dbg !247               ; [#uses=1 type=i32] [debug line = 18:3]
  %7 = xor i32 %4, %6, !dbg !247                  ; [#uses=1 type=i32] [debug line = 18:3]
  %8 = trunc i32 %7 to i8, !dbg !247              ; [#uses=1 type=i8] [debug line = 18:3]
  ret i8 %8, !dbg !247                            ; [debug line = 18:3]
}

; [#uses=1]
define internal zeroext i8 @GF_multiply(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable {
  %1 = alloca i8, align 1                         ; [#uses=3 type=i8*]
  %2 = alloca i8, align 1                         ; [#uses=3 type=i8*]
  store i8 %X, i8* %1, align 1
  call void @llvm.dbg.declare(metadata !{i8* %1}, metadata !249), !dbg !250 ; [debug line = 38:36] [debug variable = X]
  store i8 %Y, i8* %2, align 1
  call void @llvm.dbg.declare(metadata !{i8* %2}, metadata !251), !dbg !252 ; [debug line = 38:47] [debug variable = Y]
  %3 = load i8* %1, align 1, !dbg !253            ; [#uses=1 type=i8] [debug line = 40:3]
  %4 = zext i8 %3 to i32, !dbg !253               ; [#uses=1 type=i32] [debug line = 40:3]
  %5 = icmp sgt i32 %4, 0, !dbg !253              ; [#uses=1 type=i1] [debug line = 40:3]
  br i1 %5, label %6, label %18, !dbg !253        ; [debug line = 40:3]

; <label>:6                                       ; preds = %0
  %7 = load i8* %2, align 1, !dbg !253            ; [#uses=1 type=i8] [debug line = 40:3]
  %8 = zext i8 %7 to i32, !dbg !253               ; [#uses=1 type=i32] [debug line = 40:3]
  %9 = icmp sgt i32 %8, 0, !dbg !253              ; [#uses=1 type=i1] [debug line = 40:3]
  br i1 %9, label %10, label %18, !dbg !253       ; [debug line = 40:3]

; <label>:10                                      ; preds = %6
  %11 = load i8* %1, align 1, !dbg !255           ; [#uses=1 type=i8] [debug line = 40:45]
  %12 = call zeroext i8 @GF_log(i8 zeroext %11), !dbg !255 ; [#uses=1 type=i8] [debug line = 40:45]
  %13 = load i8* %2, align 1, !dbg !256           ; [#uses=1 type=i8] [debug line = 40:56]
  %14 = call zeroext i8 @GF_log(i8 zeroext %13), !dbg !256 ; [#uses=1 type=i8] [debug line = 40:56]
  %15 = call zeroext i8 @Modulo_add(i8 zeroext %12, i8 zeroext %14), !dbg !256 ; [#uses=1 type=i8] [debug line = 40:56]
  %16 = call zeroext i8 @GF_exp(i8 zeroext %15), !dbg !256 ; [#uses=1 type=i8] [debug line = 40:56]
  %17 = zext i8 %16 to i32, !dbg !256             ; [#uses=1 type=i32] [debug line = 40:56]
  br label %19, !dbg !256                         ; [debug line = 40:56]

; <label>:18                                      ; preds = %6, %0
  br label %19, !dbg !256                         ; [debug line = 40:56]

; <label>:19                                      ; preds = %18, %10
  %20 = phi i32 [ %17, %10 ], [ 0, %18 ], !dbg !256 ; [#uses=1 type=i32] [debug line = 40:56]
  %21 = trunc i32 %20 to i8, !dbg !256            ; [#uses=1 type=i8] [debug line = 40:56]
  ret i8 %21, !dbg !256                           ; [debug line = 40:56]
}

; [#uses=1]
define internal zeroext i8 @GF_exp(i8 zeroext %X) nounwind uwtable {
  %1 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  store i8 %X, i8* %1, align 1
  call void @llvm.dbg.declare(metadata !{i8* %1}, metadata !257), !dbg !258 ; [debug line = 22:31] [debug variable = X]
  call void @Generate_exp_table(i8* getelementptr inbounds ([256 x i8]* @GF_exp.Table, i32 0, i32 0)), !dbg !259 ; [debug line = 25:3]
  %2 = load i8* %1, align 1, !dbg !261            ; [#uses=1 type=i8] [debug line = 26:3]
  %3 = zext i8 %2 to i64, !dbg !261               ; [#uses=1 type=i64] [debug line = 26:3]
  %4 = getelementptr inbounds [256 x i8]* @GF_exp.Table, i32 0, i64 %3, !dbg !261 ; [#uses=1 type=i8*] [debug line = 26:3]
  %5 = load i8* %4, align 1, !dbg !261            ; [#uses=1 type=i8] [debug line = 26:3]
  ret i8 %5, !dbg !261                            ; [debug line = 26:3]
}

; [#uses=1]
define internal zeroext i8 @Modulo_add(i8 zeroext %X, i8 zeroext %Y) nounwind uwtable {
  %1 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  %2 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  %Sum = alloca i32, align 4                      ; [#uses=4 type=i32*]
  store i8 %X, i8* %1, align 1
  call void @llvm.dbg.declare(metadata !{i8* %1}, metadata !262), !dbg !263 ; [debug line = 9:35] [debug variable = X]
  store i8 %Y, i8* %2, align 1
  call void @llvm.dbg.declare(metadata !{i8* %2}, metadata !264), !dbg !265 ; [debug line = 9:46] [debug variable = Y]
  call void @llvm.dbg.declare(metadata !{i32* %Sum}, metadata !266), !dbg !268 ; [debug line = 11:7] [debug variable = Sum]
  %3 = load i8* %1, align 1, !dbg !269            ; [#uses=1 type=i8] [debug line = 11:18]
  %4 = zext i8 %3 to i32, !dbg !269               ; [#uses=1 type=i32] [debug line = 11:18]
  %5 = load i8* %2, align 1, !dbg !269            ; [#uses=1 type=i8] [debug line = 11:18]
  %6 = zext i8 %5 to i32, !dbg !269               ; [#uses=1 type=i32] [debug line = 11:18]
  %7 = add nsw i32 %4, %6, !dbg !269              ; [#uses=1 type=i32] [debug line = 11:18]
  store i32 %7, i32* %Sum, align 4, !dbg !269     ; [debug line = 11:18]
  %8 = load i32* %Sum, align 4, !dbg !270         ; [#uses=1 type=i32] [debug line = 12:3]
  %9 = icmp sgt i32 %8, 255, !dbg !270            ; [#uses=1 type=i1] [debug line = 12:3]
  br i1 %9, label %10, label %13, !dbg !270       ; [debug line = 12:3]

; <label>:10                                      ; preds = %0
  %11 = load i32* %Sum, align 4, !dbg !270        ; [#uses=1 type=i32] [debug line = 12:3]
  %12 = sub nsw i32 %11, 255, !dbg !270           ; [#uses=1 type=i32] [debug line = 12:3]
  br label %15, !dbg !270                         ; [debug line = 12:3]

; <label>:13                                      ; preds = %0
  %14 = load i32* %Sum, align 4, !dbg !270        ; [#uses=1 type=i32] [debug line = 12:3]
  br label %15, !dbg !270                         ; [debug line = 12:3]

; <label>:15                                      ; preds = %13, %10
  %16 = phi i32 [ %12, %10 ], [ %14, %13 ], !dbg !270 ; [#uses=1 type=i32] [debug line = 12:3]
  %17 = trunc i32 %16 to i8, !dbg !270            ; [#uses=1 type=i8] [debug line = 12:3]
  ret i8 %17, !dbg !270                           ; [debug line = 12:3]
}

; [#uses=2]
define internal zeroext i8 @GF_log(i8 zeroext %X) nounwind uwtable {
  %1 = alloca i8, align 1                         ; [#uses=2 type=i8*]
  store i8 %X, i8* %1, align 1
  call void @llvm.dbg.declare(metadata !{i8* %1}, metadata !271), !dbg !272 ; [debug line = 30:31] [debug variable = X]
  call void @Generate_log_table(i8* getelementptr inbounds ([256 x i8]* @GF_log.Table, i32 0, i32 0)), !dbg !273 ; [debug line = 33:3]
  %2 = load i8* %1, align 1, !dbg !275            ; [#uses=1 type=i8] [debug line = 34:3]
  %3 = zext i8 %2 to i64, !dbg !275               ; [#uses=1 type=i64] [debug line = 34:3]
  %4 = getelementptr inbounds [256 x i8]* @GF_log.Table, i32 0, i64 %3, !dbg !275 ; [#uses=1 type=i8*] [debug line = 34:3]
  %5 = load i8* %4, align 1, !dbg !275            ; [#uses=1 type=i8] [debug line = 34:3]
  ret i8 %5, !dbg !275                            ; [debug line = 34:3]
}

; [#uses=1]
define internal void @Generate_log_table(i8* %Table) nounwind uwtable {
  %1 = alloca i8*, align 8                        ; [#uses=3 type=i8**]
  %Exp_table = alloca [256 x i8], align 16        ; [#uses=2 type=[256 x i8]*]
  %i = alloca i32, align 4                        ; [#uses=6 type=i32*]
  store i8* %Table, i8** %1, align 8
  call void @llvm.dbg.declare(metadata !{i8** %1}, metadata !276), !dbg !277 ; [debug line = 88:40] [debug variable = Table]
  %2 = load i8** %1, align 8, !dbg !278           ; [#uses=1 type=i8*] [debug line = 89:2]
  call void (...)* @_ssdm_SpecArrayDimSize(i8* %2, i32 256) nounwind, !dbg !278 ; [debug line = 89:2]
  call void @llvm.dbg.declare(metadata !{[256 x i8]* %Exp_table}, metadata !280), !dbg !281 ; [debug line = 90:11] [debug variable = Exp_table]
  %3 = getelementptr inbounds [256 x i8]* %Exp_table, i32 0, i32 0, !dbg !282 ; [#uses=1 type=i8*] [debug line = 91:3]
  call void @Generate_exp_table(i8* %3), !dbg !282 ; [debug line = 91:3]
  call void @llvm.dbg.declare(metadata !{i32* %i}, metadata !283), !dbg !285 ; [debug line = 93:12] [debug variable = i]
  store i32 1, i32* %i, align 4, !dbg !286        ; [debug line = 93:17]
  br label %4, !dbg !286                          ; [debug line = 93:17]

; <label>:4                                       ; preds = %17, %0
  %5 = load i32* %i, align 4, !dbg !286           ; [#uses=1 type=i32] [debug line = 93:17]
  %6 = icmp slt i32 %5, 256, !dbg !286            ; [#uses=1 type=i1] [debug line = 93:17]
  br i1 %6, label %7, label %20, !dbg !286        ; [debug line = 93:17]

; <label>:7                                       ; preds = %4
  %8 = load i32* %i, align 4, !dbg !287           ; [#uses=1 type=i32] [debug line = 94:5]
  %9 = trunc i32 %8 to i8, !dbg !287              ; [#uses=1 type=i8] [debug line = 94:5]
  %10 = load i32* %i, align 4, !dbg !287          ; [#uses=1 type=i32] [debug line = 94:5]
  %11 = sext i32 %10 to i64, !dbg !287            ; [#uses=1 type=i64] [debug line = 94:5]
  %12 = getelementptr inbounds [256 x i8]* %Exp_table, i32 0, i64 %11, !dbg !287 ; [#uses=1 type=i8*] [debug line = 94:5]
  %13 = load i8* %12, align 1, !dbg !287          ; [#uses=1 type=i8] [debug line = 94:5]
  %14 = zext i8 %13 to i64, !dbg !287             ; [#uses=1 type=i64] [debug line = 94:5]
  %15 = load i8** %1, align 8, !dbg !287          ; [#uses=1 type=i8*] [debug line = 94:5]
  %16 = getelementptr inbounds i8* %15, i64 %14, !dbg !287 ; [#uses=1 type=i8*] [debug line = 94:5]
  store i8 %9, i8* %16, align 1, !dbg !287        ; [debug line = 94:5]
  br label %17, !dbg !287                         ; [debug line = 94:5]

; <label>:17                                      ; preds = %7
  %18 = load i32* %i, align 4, !dbg !288          ; [#uses=1 type=i32] [debug line = 93:94]
  %19 = add nsw i32 %18, 1, !dbg !288             ; [#uses=1 type=i32] [debug line = 93:94]
  store i32 %19, i32* %i, align 4, !dbg !288      ; [debug line = 93:94]
  br label %4, !dbg !288                          ; [debug line = 93:94]

; <label>:20                                      ; preds = %4
  ret void, !dbg !289                             ; [debug line = 95:1]
}

; [#uses=2]
define internal void @Generate_exp_table(i8* %Table) nounwind uwtable {
  %1 = alloca i8*, align 8                        ; [#uses=5 type=i8**]
  %Primitive = alloca i32, align 4                ; [#uses=2 type=i32*]
  %i = alloca i32, align 4                        ; [#uses=6 type=i32*]
  %Value = alloca i32, align 4                    ; [#uses=5 type=i32*]
  store i8* %Table, i8** %1, align 8
  call void @llvm.dbg.declare(metadata !{i8** %1}, metadata !290), !dbg !291 ; [debug line = 74:40] [debug variable = Table]
  %2 = load i8** %1, align 8, !dbg !292           ; [#uses=1 type=i8*] [debug line = 75:2]
  call void (...)* @_ssdm_SpecArrayDimSize(i8* %2, i32 256) nounwind, !dbg !292 ; [debug line = 75:2]
  call void @llvm.dbg.declare(metadata !{i32* %Primitive}, metadata !294), !dbg !295 ; [debug line = 76:7] [debug variable = Primitive]
  %3 = call i32 @Get_primitive_polynomial(), !dbg !296 ; [#uses=1 type=i32] [debug line = 76:19]
  store i32 %3, i32* %Primitive, align 4, !dbg !296 ; [debug line = 76:19]
  %4 = load i8** %1, align 8, !dbg !297           ; [#uses=1 type=i8*] [debug line = 78:3]
  %5 = getelementptr inbounds i8* %4, i64 0, !dbg !297 ; [#uses=1 type=i8*] [debug line = 78:3]
  store i8 1, i8* %5, align 1, !dbg !297          ; [debug line = 78:3]
  call void @llvm.dbg.declare(metadata !{i32* %i}, metadata !298), !dbg !300 ; [debug line = 79:12] [debug variable = i]
  store i32 1, i32* %i, align 4, !dbg !301        ; [debug line = 79:17]
  br label %6, !dbg !301                          ; [debug line = 79:17]

; <label>:6                                       ; preds = %31, %0
  %7 = load i32* %i, align 4, !dbg !301           ; [#uses=1 type=i32] [debug line = 79:17]
  %8 = icmp slt i32 %7, 256, !dbg !301            ; [#uses=1 type=i1] [debug line = 79:17]
  br i1 %8, label %9, label %34, !dbg !301        ; [debug line = 79:17]

; <label>:9                                       ; preds = %6
  call void @llvm.dbg.declare(metadata !{i32* %Value}, metadata !302), !dbg !304 ; [debug line = 81:9] [debug variable = Value]
  %10 = load i32* %i, align 4, !dbg !305          ; [#uses=1 type=i32] [debug line = 81:33]
  %11 = sub nsw i32 %10, 1, !dbg !305             ; [#uses=1 type=i32] [debug line = 81:33]
  %12 = sext i32 %11 to i64, !dbg !305            ; [#uses=1 type=i64] [debug line = 81:33]
  %13 = load i8** %1, align 8, !dbg !305          ; [#uses=1 type=i8*] [debug line = 81:33]
  %14 = getelementptr inbounds i8* %13, i64 %12, !dbg !305 ; [#uses=1 type=i8*] [debug line = 81:33]
  %15 = load i8* %14, align 1, !dbg !305          ; [#uses=1 type=i8] [debug line = 81:33]
  %16 = zext i8 %15 to i32, !dbg !305             ; [#uses=1 type=i32] [debug line = 81:33]
  %17 = mul nsw i32 2, %16, !dbg !305             ; [#uses=1 type=i32] [debug line = 81:33]
  store i32 %17, i32* %Value, align 4, !dbg !305  ; [debug line = 81:33]
  %18 = load i32* %Value, align 4, !dbg !306      ; [#uses=1 type=i32] [debug line = 82:5]
  %19 = icmp sge i32 %18, 256, !dbg !306          ; [#uses=1 type=i1] [debug line = 82:5]
  br i1 %19, label %20, label %24, !dbg !306      ; [debug line = 82:5]

; <label>:20                                      ; preds = %9
  %21 = load i32* %Value, align 4, !dbg !307      ; [#uses=1 type=i32] [debug line = 83:7]
  %22 = load i32* %Primitive, align 4, !dbg !307  ; [#uses=1 type=i32] [debug line = 83:7]
  %23 = xor i32 %21, %22, !dbg !307               ; [#uses=1 type=i32] [debug line = 83:7]
  store i32 %23, i32* %Value, align 4, !dbg !307  ; [debug line = 83:7]
  br label %24, !dbg !307                         ; [debug line = 83:7]

; <label>:24                                      ; preds = %20, %9
  %25 = load i32* %Value, align 4, !dbg !308      ; [#uses=1 type=i32] [debug line = 84:5]
  %26 = trunc i32 %25 to i8, !dbg !308            ; [#uses=1 type=i8] [debug line = 84:5]
  %27 = load i32* %i, align 4, !dbg !308          ; [#uses=1 type=i32] [debug line = 84:5]
  %28 = sext i32 %27 to i64, !dbg !308            ; [#uses=1 type=i64] [debug line = 84:5]
  %29 = load i8** %1, align 8, !dbg !308          ; [#uses=1 type=i8*] [debug line = 84:5]
  %30 = getelementptr inbounds i8* %29, i64 %28, !dbg !308 ; [#uses=1 type=i8*] [debug line = 84:5]
  store i8 %26, i8* %30, align 1, !dbg !308       ; [debug line = 84:5]
  br label %31, !dbg !309                         ; [debug line = 85:3]

; <label>:31                                      ; preds = %24
  %32 = load i32* %i, align 4, !dbg !310          ; [#uses=1 type=i32] [debug line = 79:94]
  %33 = add nsw i32 %32, 1, !dbg !310             ; [#uses=1 type=i32] [debug line = 79:94]
  store i32 %33, i32* %i, align 4, !dbg !310      ; [debug line = 79:94]
  br label %6, !dbg !310                          ; [debug line = 79:94]

; <label>:34                                      ; preds = %6
  ret void, !dbg !311                             ; [debug line = 86:1]
}

; [#uses=1]
define internal i32 @Get_primitive_polynomial() nounwind uwtable {
  ret i32 285, !dbg !312                          ; [debug line = 66:7]
}

!llvm.dbg.cu = !{!0, !63}
!opencl.kernels = !{!112, !119, !125, !131, !137, !141, !142, !148, !149, !150}
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
!23 = metadata !{i32 786484, i32 0, null, metadata !"fb", metadata !"fb", metadata !"", metadata !24, i32 68, metadata !25, i32 0, i32 1, %struct.fec_block* @fb} ; [ DW_TAG_variable ]
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
!58 = metadata !{i32 786484, i32 0, null, metadata !"_IO_2_1_stdin_", metadata !"_IO_2_1_stdin_", metadata !"", metadata !59, i32 315, metadata !60, i32 0, i32 1, %struct.fec_block* @_IO_2_1_stdin_} ; [ DW_TAG_variable ]
!59 = metadata !{i32 786473, metadata !"/usr/include/libio.h", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", null} ; [ DW_TAG_file_type ]
!60 = metadata !{i32 786451, null, metadata !"_IO_FILE_plus", metadata !59, i32 313, i32 0, i32 0, i32 0, i32 4, null, null, i32 0} ; [ DW_TAG_structure_type ]
!61 = metadata !{i32 786484, i32 0, null, metadata !"_IO_2_1_stdout_", metadata !"_IO_2_1_stdout_", metadata !"", metadata !59, i32 316, metadata !60, i32 0, i32 1, %struct.fec_block* @_IO_2_1_stdout_} ; [ DW_TAG_variable ]
!62 = metadata !{i32 786484, i32 0, null, metadata !"_IO_2_1_stderr_", metadata !"_IO_2_1_stderr_", metadata !"", metadata !59, i32 317, metadata !60, i32 0, i32 1, %struct.fec_block* @_IO_2_1_stderr_} ; [ DW_TAG_variable ]
!63 = metadata !{i32 786449, i32 0, i32 12, metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore/RSECore/solution1/.autopilot/db/Encoder.pragma.2.c", metadata !"/home/gyzuh/University/DComp/Repository/P4Boosters/RSECore", metadata !"clang version 3.1 ", i1 true, i1 false, metadata !"", i32 0, metadata !1, metadata !1, metadata !64, metadata !88} ; [ DW_TAG_compile_unit ]
!64 = metadata !{metadata !65}
!65 = metadata !{metadata !66, metadata !72, metadata !75, metadata !78, metadata !81, metadata !82, metadata !85, metadata !86, metadata !87}
!66 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Matrix_multiply_HW", metadata !"Matrix_multiply_HW", metadata !"", metadata !67, i32 151, metadata !68, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, void (i8*, i8*, i32, i32)* @Matrix_multiply_HW, null, null, metadata !19, i32 152} ; [ DW_TAG_subprogram ]
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
!78 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Generate_log_table", metadata !"Generate_log_table", metadata !"", metadata !67, i32 88, metadata !79, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, void (i8*)* @Generate_log_table, null, null, metadata !19, i32 89} ; [ DW_TAG_subprogram ]
!79 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !80, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!80 = metadata !{null, metadata !70}
!81 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Generate_exp_table", metadata !"Generate_exp_table", metadata !"", metadata !67, i32 74, metadata !79, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, void (i8*)* @Generate_exp_table, null, null, metadata !19, i32 75} ; [ DW_TAG_subprogram ]
!82 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Get_primitive_polynomial", metadata !"Get_primitive_polynomial", metadata !"", metadata !67, i32 51, metadata !83, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i32 ()* @Get_primitive_polynomial, null, null, metadata !19, i32 52} ; [ DW_TAG_subprogram ]
!83 = metadata !{i32 786453, i32 0, metadata !"", i32 0, i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !84, i32 0, i32 0} ; [ DW_TAG_subroutine_type ]
!84 = metadata !{metadata !40}
!85 = metadata !{i32 786478, i32 0, metadata !67, metadata !"Modulo_add", metadata !"Modulo_add", metadata !"", metadata !67, i32 9, metadata !73, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8, i8)* @Modulo_add, null, null, metadata !19, i32 10} ; [ DW_TAG_subprogram ]
!86 = metadata !{i32 786478, i32 0, metadata !67, metadata !"GF_exp", metadata !"GF_exp", metadata !"", metadata !67, i32 22, metadata !76, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8)* @GF_exp, null, null, metadata !19, i32 23} ; [ DW_TAG_subprogram ]
!87 = metadata !{i32 786478, i32 0, metadata !67, metadata !"GF_add", metadata !"GF_add", metadata !"", metadata !67, i32 16, metadata !73, i1 true, i1 true, i32 0, i32 0, null, i32 256, i1 false, i8 (i8, i8)* @GF_add, null, null, metadata !19, i32 17} ; [ DW_TAG_subprogram ]
!88 = metadata !{metadata !89}
!89 = metadata !{metadata !90, metadata !93, metadata !58, metadata !61, metadata !62, metadata !107, metadata !111}
!90 = metadata !{i32 786484, i32 0, metadata !66, metadata !"Generator", metadata !"Generator", metadata !"", metadata !67, i32 156, metadata !91, i32 1, i32 1, [4 x [8 x i8]]* @Matrix_multiply_HW.Generator} ; [ DW_TAG_variable ]
!91 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 256, i64 8, i32 0, i32 0, metadata !71, metadata !92, i32 0, i32 0} ; [ DW_TAG_array_type ]
!92 = metadata !{metadata !57, metadata !53}
!93 = metadata !{i32 786484, i32 0, null, metadata !"fb", metadata !"fb", metadata !"", metadata !24, i32 68, metadata !94, i32 0, i32 1, %struct.fec_block* @fb} ; [ DW_TAG_variable ]
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
!107 = metadata !{i32 786484, i32 0, metadata !75, metadata !"Table", metadata !"Table", metadata !"", metadata !67, i32 32, metadata !108, i32 1, i32 1, [256 x i8]* @GF_log.Table} ; [ DW_TAG_variable ]
!108 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 2048, i64 8, i32 0, i32 0, metadata !71, metadata !109, i32 0, i32 0} ; [ DW_TAG_array_type ]
!109 = metadata !{metadata !110}
!110 = metadata !{i32 786465, i64 0, i64 255}     ; [ DW_TAG_subrange_type ]
!111 = metadata !{i32 786484, i32 0, metadata !86, metadata !"Table", metadata !"Table", metadata !"", metadata !67, i32 24, metadata !108, i32 1, i32 1, [256 x i8]* @GF_exp.Table} ; [ DW_TAG_variable ]
!112 = metadata !{void (i8, i32, i1, i368, i368*)* @RSE_core, metadata !113, metadata !114, metadata !115, metadata !116, metadata !117, metadata !118}
!113 = metadata !{metadata !"kernel_arg_addr_space", i32 0, i32 0, i32 0, i32 0, i32 1}
!114 = metadata !{metadata !"kernel_arg_access_qual", metadata !"none", metadata !"none", metadata !"none", metadata !"none", metadata !"none"}
!115 = metadata !{metadata !"kernel_arg_type", metadata !"uint8", metadata !"uint32", metadata !"uint1", metadata !"packet_t", metadata !"packet_t*"}
!116 = metadata !{metadata !"kernel_arg_type_qual", metadata !"", metadata !"", metadata !"", metadata !"", metadata !""}
!117 = metadata !{metadata !"kernel_arg_name", metadata !"operation", metadata !"index", metadata !"is_parity", metadata !"data", metadata !"parity"}
!118 = metadata !{metadata !"reqd_work_group_size", i32 1, i32 1, i32 1}
!119 = metadata !{void (i8*, i8*, i32, i32)* @Matrix_multiply_HW, metadata !120, metadata !121, metadata !122, metadata !123, metadata !124, metadata !118}
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
!137 = metadata !{void (i8*)* @Generate_log_table, metadata !138, metadata !133, metadata !139, metadata !135, metadata !140, metadata !118}
!138 = metadata !{metadata !"kernel_arg_addr_space", i32 1}
!139 = metadata !{metadata !"kernel_arg_type", metadata !"fec_sym*"}
!140 = metadata !{metadata !"kernel_arg_name", metadata !"Table"}
!141 = metadata !{void (i8*)* @Generate_exp_table, metadata !138, metadata !133, metadata !139, metadata !135, metadata !140, metadata !118}
!142 = metadata !{i32 ()* @Get_primitive_polynomial, metadata !143, metadata !144, metadata !145, metadata !146, metadata !147, metadata !118}
!143 = metadata !{metadata !"kernel_arg_addr_space"}
!144 = metadata !{metadata !"kernel_arg_access_qual"}
!145 = metadata !{metadata !"kernel_arg_type"}
!146 = metadata !{metadata !"kernel_arg_type_qual"}
!147 = metadata !{metadata !"kernel_arg_name"}
!148 = metadata !{i8 (i8, i8)* @Modulo_add, metadata !126, metadata !127, metadata !128, metadata !129, metadata !130, metadata !118}
!149 = metadata !{i8 (i8)* @GF_exp, metadata !132, metadata !133, metadata !134, metadata !135, metadata !136, metadata !118}
!150 = metadata !{i8 (i8, i8)* @GF_add, metadata !126, metadata !127, metadata !128, metadata !129, metadata !130, metadata !118}
!151 = metadata !{i32 786689, metadata !5, metadata !"operation", metadata !6, i32 16777240, metadata !9, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!152 = metadata !{i32 24, i32 21, metadata !5, null}
!153 = metadata !{i32 786689, metadata !5, metadata !"index", metadata !6, i32 33554456, metadata !11, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!154 = metadata !{i32 24, i32 39, metadata !5, null}
!155 = metadata !{i32 786689, metadata !5, metadata !"is_parity", metadata !6, i32 50331672, metadata !13, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!156 = metadata !{i32 24, i32 52, metadata !5, null}
!157 = metadata !{i32 786689, metadata !5, metadata !"data", metadata !6, i32 67108888, metadata !15, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!158 = metadata !{i32 24, i32 72, metadata !5, null}
!159 = metadata !{i32 786689, metadata !5, metadata !"parity", metadata !6, i32 83886104, metadata !18, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!160 = metadata !{i32 24, i32 89, metadata !5, null}
!161 = metadata !{i32 26, i32 1, metadata !162, null}
!162 = metadata !{i32 786443, metadata !5, i32 25, i32 1, metadata !6, i32 0} ; [ DW_TAG_lexical_block ]
!163 = metadata !{i32 27, i32 1, metadata !162, null}
!164 = metadata !{i32 786688, metadata !162, metadata !"k", metadata !6, i32 28, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!165 = metadata !{i32 28, i32 6, metadata !162, null}
!166 = metadata !{i32 28, i32 105, metadata !162, null}
!167 = metadata !{i32 786688, metadata !162, metadata !"h", metadata !6, i32 29, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!168 = metadata !{i32 29, i32 7, metadata !162, null}
!169 = metadata !{i32 29, i32 33, metadata !162, null}
!170 = metadata !{i32 31, i32 3, metadata !162, null}
!171 = metadata !{i32 34, i32 7, metadata !172, null}
!172 = metadata !{i32 786443, metadata !162, i32 32, i32 3, metadata !6, i32 1} ; [ DW_TAG_lexical_block ]
!173 = metadata !{i32 35, i32 7, metadata !172, null}
!174 = metadata !{i32 786688, metadata !175, metadata !"i", metadata !6, i32 38, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!175 = metadata !{i32 786443, metadata !172, i32 38, i32 7, metadata !6, i32 2} ; [ DW_TAG_lexical_block ]
!176 = metadata !{i32 38, i32 16, metadata !175, null}
!177 = metadata !{i32 38, i32 21, metadata !175, null}
!178 = metadata !{i32 39, i32 8, metadata !179, null}
!179 = metadata !{i32 786443, metadata !175, i32 39, i32 7, metadata !6, i32 3} ; [ DW_TAG_lexical_block ]
!180 = metadata !{i32 40, i32 1, metadata !179, null}
!181 = metadata !{i32 786688, metadata !179, metadata !"input", metadata !6, i32 41, metadata !182, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!182 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 64, i64 8, i32 0, i32 0, metadata !28, metadata !52, i32 0, i32 0} ; [ DW_TAG_array_type ]
!183 = metadata !{i32 41, i32 10, metadata !179, null}
!184 = metadata !{i32 786688, metadata !185, metadata !"j", metadata !6, i32 42, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!185 = metadata !{i32 786443, metadata !179, i32 42, i32 9, metadata !6, i32 4} ; [ DW_TAG_lexical_block ]
!186 = metadata !{i32 42, i32 18, metadata !185, null}
!187 = metadata !{i32 42, i32 23, metadata !185, null}
!188 = metadata !{i32 43, i32 11, metadata !185, null}
!189 = metadata !{i32 42, i32 32, metadata !185, null}
!190 = metadata !{i32 786688, metadata !179, metadata !"output", metadata !6, i32 44, metadata !191, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!191 = metadata !{i32 786433, null, metadata !"", null, i32 0, i64 32, i64 8, i32 0, i32 0, metadata !28, metadata !56, i32 0, i32 0} ; [ DW_TAG_array_type ]
!192 = metadata !{i32 44, i32 17, metadata !179, null}
!193 = metadata !{i32 45, i32 9, metadata !179, null}
!194 = metadata !{i32 786688, metadata !195, metadata !"j", metadata !6, i32 46, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!195 = metadata !{i32 786443, metadata !179, i32 46, i32 9, metadata !6, i32 5} ; [ DW_TAG_lexical_block ]
!196 = metadata !{i32 46, i32 18, metadata !195, null}
!197 = metadata !{i32 46, i32 23, metadata !195, null}
!198 = metadata !{i32 47, i32 11, metadata !195, null}
!199 = metadata !{i32 46, i32 32, metadata !195, null}
!200 = metadata !{i32 49, i32 7, metadata !179, null}
!201 = metadata !{i32 38, i32 32, metadata !175, null}
!202 = metadata !{i32 50, i32 7, metadata !172, null}
!203 = metadata !{i32 53, i32 7, metadata !172, null}
!204 = metadata !{i32 54, i32 3, metadata !172, null}
!205 = metadata !{i32 55, i32 1, metadata !162, null}
!206 = metadata !{i32 786689, metadata !66, metadata !"Data", metadata !67, i32 16777367, metadata !70, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!207 = metadata !{i32 151, i32 33, metadata !66, null}
!208 = metadata !{i32 786689, metadata !66, metadata !"Parity", metadata !67, i32 33554583, metadata !70, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!209 = metadata !{i32 151, i32 144, metadata !66, null}
!210 = metadata !{i32 786689, metadata !66, metadata !"k", metadata !67, i32 50331799, metadata !40, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!211 = metadata !{i32 151, i32 180, metadata !66, null}
!212 = metadata !{i32 786689, metadata !66, metadata !"h", metadata !67, i32 67109015, metadata !40, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!213 = metadata !{i32 151, i32 187, metadata !66, null}
!214 = metadata !{i32 152, i32 2, metadata !215, null}
!215 = metadata !{i32 786443, metadata !66, i32 152, i32 1, metadata !67, i32 0} ; [ DW_TAG_lexical_block ]
!216 = metadata !{i32 152, i32 102, metadata !215, null}
!217 = metadata !{i32 153, i32 1, metadata !215, null}
!218 = metadata !{i32 154, i32 1, metadata !215, null}
!219 = metadata !{i32 159, i32 1, metadata !215, null}
!220 = metadata !{i32 786688, metadata !221, metadata !"i", metadata !67, i32 162, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!221 = metadata !{i32 786443, metadata !215, i32 162, i32 3, metadata !67, i32 1} ; [ DW_TAG_lexical_block ]
!222 = metadata !{i32 162, i32 12, metadata !221, null}
!223 = metadata !{i32 162, i32 17, metadata !221, null}
!224 = metadata !{i32 164, i32 5, metadata !225, null}
!225 = metadata !{i32 786443, metadata !221, i32 163, i32 3, metadata !67, i32 2} ; [ DW_TAG_lexical_block ]
!226 = metadata !{i32 786688, metadata !227, metadata !"Result", metadata !67, i32 166, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!227 = metadata !{i32 786443, metadata !225, i32 165, i32 5, metadata !67, i32 3} ; [ DW_TAG_lexical_block ]
!228 = metadata !{i32 166, i32 11, metadata !227, null}
!229 = metadata !{i32 166, i32 21, metadata !227, null}
!230 = metadata !{i32 786688, metadata !231, metadata !"j", metadata !67, i32 167, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!231 = metadata !{i32 786443, metadata !227, i32 167, i32 7, metadata !67, i32 4} ; [ DW_TAG_lexical_block ]
!232 = metadata !{i32 167, i32 16, metadata !231, null}
!233 = metadata !{i32 167, i32 21, metadata !231, null}
!234 = metadata !{i32 168, i32 9, metadata !231, null}
!235 = metadata !{i32 169, i32 20, metadata !231, null}
!236 = metadata !{i32 169, i32 35, metadata !231, null}
!237 = metadata !{i32 167, i32 124, metadata !231, null}
!238 = metadata !{i32 170, i32 7, metadata !227, null}
!239 = metadata !{i32 171, i32 5, metadata !227, null}
!240 = metadata !{i32 172, i32 3, metadata !225, null}
!241 = metadata !{i32 162, i32 47, metadata !221, null}
!242 = metadata !{i32 173, i32 1, metadata !215, null}
!243 = metadata !{i32 786689, metadata !87, metadata !"X", metadata !67, i32 16777232, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!244 = metadata !{i32 16, i32 31, metadata !87, null}
!245 = metadata !{i32 786689, metadata !87, metadata !"Y", metadata !67, i32 33554448, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!246 = metadata !{i32 16, i32 42, metadata !87, null}
!247 = metadata !{i32 18, i32 3, metadata !248, null}
!248 = metadata !{i32 786443, metadata !87, i32 17, i32 1, metadata !67, i32 15} ; [ DW_TAG_lexical_block ]
!249 = metadata !{i32 786689, metadata !72, metadata !"X", metadata !67, i32 16777254, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!250 = metadata !{i32 38, i32 36, metadata !72, null}
!251 = metadata !{i32 786689, metadata !72, metadata !"Y", metadata !67, i32 33554470, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!252 = metadata !{i32 38, i32 47, metadata !72, null}
!253 = metadata !{i32 40, i32 3, metadata !254, null}
!254 = metadata !{i32 786443, metadata !72, i32 39, i32 1, metadata !67, i32 5} ; [ DW_TAG_lexical_block ]
!255 = metadata !{i32 40, i32 45, metadata !254, null}
!256 = metadata !{i32 40, i32 56, metadata !254, null}
!257 = metadata !{i32 786689, metadata !86, metadata !"X", metadata !67, i32 16777238, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!258 = metadata !{i32 22, i32 31, metadata !86, null}
!259 = metadata !{i32 25, i32 3, metadata !260, null}
!260 = metadata !{i32 786443, metadata !86, i32 23, i32 1, metadata !67, i32 14} ; [ DW_TAG_lexical_block ]
!261 = metadata !{i32 26, i32 3, metadata !260, null}
!262 = metadata !{i32 786689, metadata !85, metadata !"X", metadata !67, i32 16777225, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!263 = metadata !{i32 9, i32 35, metadata !85, null}
!264 = metadata !{i32 786689, metadata !85, metadata !"Y", metadata !67, i32 33554441, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!265 = metadata !{i32 9, i32 46, metadata !85, null}
!266 = metadata !{i32 786688, metadata !267, metadata !"Sum", metadata !67, i32 11, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!267 = metadata !{i32 786443, metadata !85, i32 10, i32 1, metadata !67, i32 13} ; [ DW_TAG_lexical_block ]
!268 = metadata !{i32 11, i32 7, metadata !267, null}
!269 = metadata !{i32 11, i32 18, metadata !267, null}
!270 = metadata !{i32 12, i32 3, metadata !267, null}
!271 = metadata !{i32 786689, metadata !75, metadata !"X", metadata !67, i32 16777246, metadata !71, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!272 = metadata !{i32 30, i32 31, metadata !75, null}
!273 = metadata !{i32 33, i32 3, metadata !274, null}
!274 = metadata !{i32 786443, metadata !75, i32 31, i32 1, metadata !67, i32 6} ; [ DW_TAG_lexical_block ]
!275 = metadata !{i32 34, i32 3, metadata !274, null}
!276 = metadata !{i32 786689, metadata !78, metadata !"Table", metadata !67, i32 16777304, metadata !70, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!277 = metadata !{i32 88, i32 40, metadata !78, null}
!278 = metadata !{i32 89, i32 2, metadata !279, null}
!279 = metadata !{i32 786443, metadata !78, i32 89, i32 1, metadata !67, i32 7} ; [ DW_TAG_lexical_block ]
!280 = metadata !{i32 786688, metadata !279, metadata !"Exp_table", metadata !67, i32 90, metadata !108, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!281 = metadata !{i32 90, i32 11, metadata !279, null}
!282 = metadata !{i32 91, i32 3, metadata !279, null}
!283 = metadata !{i32 786688, metadata !284, metadata !"i", metadata !67, i32 93, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!284 = metadata !{i32 786443, metadata !279, i32 93, i32 3, metadata !67, i32 8} ; [ DW_TAG_lexical_block ]
!285 = metadata !{i32 93, i32 12, metadata !284, null}
!286 = metadata !{i32 93, i32 17, metadata !284, null}
!287 = metadata !{i32 94, i32 5, metadata !284, null}
!288 = metadata !{i32 93, i32 94, metadata !284, null}
!289 = metadata !{i32 95, i32 1, metadata !279, null}
!290 = metadata !{i32 786689, metadata !81, metadata !"Table", metadata !67, i32 16777290, metadata !70, i32 0, i32 0} ; [ DW_TAG_arg_variable ]
!291 = metadata !{i32 74, i32 40, metadata !81, null}
!292 = metadata !{i32 75, i32 2, metadata !293, null}
!293 = metadata !{i32 786443, metadata !81, i32 75, i32 1, metadata !67, i32 9} ; [ DW_TAG_lexical_block ]
!294 = metadata !{i32 786688, metadata !293, metadata !"Primitive", metadata !67, i32 76, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!295 = metadata !{i32 76, i32 7, metadata !293, null}
!296 = metadata !{i32 76, i32 19, metadata !293, null}
!297 = metadata !{i32 78, i32 3, metadata !293, null}
!298 = metadata !{i32 786688, metadata !299, metadata !"i", metadata !67, i32 79, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!299 = metadata !{i32 786443, metadata !293, i32 79, i32 3, metadata !67, i32 10} ; [ DW_TAG_lexical_block ]
!300 = metadata !{i32 79, i32 12, metadata !299, null}
!301 = metadata !{i32 79, i32 17, metadata !299, null}
!302 = metadata !{i32 786688, metadata !303, metadata !"Value", metadata !67, i32 81, metadata !40, i32 0, i32 0} ; [ DW_TAG_auto_variable ]
!303 = metadata !{i32 786443, metadata !299, i32 80, i32 3, metadata !67, i32 11} ; [ DW_TAG_lexical_block ]
!304 = metadata !{i32 81, i32 9, metadata !303, null}
!305 = metadata !{i32 81, i32 33, metadata !303, null}
!306 = metadata !{i32 82, i32 5, metadata !303, null}
!307 = metadata !{i32 83, i32 7, metadata !303, null}
!308 = metadata !{i32 84, i32 5, metadata !303, null}
!309 = metadata !{i32 85, i32 3, metadata !303, null}
!310 = metadata !{i32 79, i32 94, metadata !299, null}
!311 = metadata !{i32 86, i32 1, metadata !293, null}
!312 = metadata !{i32 66, i32 7, metadata !313, null}
!313 = metadata !{i32 786443, metadata !82, i32 52, i32 1, metadata !67, i32 12} ; [ DW_TAG_lexical_block ]
