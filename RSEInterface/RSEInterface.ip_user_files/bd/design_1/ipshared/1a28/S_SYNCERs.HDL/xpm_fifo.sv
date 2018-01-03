// d52cbaca0ef8cf4fd3d6354deb5066970fb6511d02d18d15835e6014ed847fb0
//------------------------------------------------------------------------------
//  (c) Copyright 2016 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------

// ***************************
// * DO NOT MODIFY THIS FILE *
// ***************************

`timescale 1ps/1ps
`default_nettype none
(* XPM_MODULE = "TRUE",  KEEP_HIERARCHY = "TRUE" *)
module xpm_fifo_base # (

  // Common module parameters
  parameter integer                 COMMON_CLOCK         = 1,
  parameter integer                 RELATED_CLOCKS       = 0,
  parameter integer                 FIFO_MEMORY_TYPE     = 0,
  parameter integer                 ECC_MODE             = 0,

  parameter integer                 FIFO_WRITE_DEPTH     = 2048,
  parameter integer                 WRITE_DATA_WIDTH     = 32,
  parameter integer                 WR_DATA_COUNT_WIDTH  = 12,
  parameter integer                 PROG_FULL_THRESH     = 10,

  parameter                         READ_MODE            = 0,
  parameter                         FIFO_READ_LATENCY    = 1,
  parameter integer                 READ_DATA_WIDTH      = WRITE_DATA_WIDTH,
  parameter integer                 RD_DATA_COUNT_WIDTH  = 12,
  parameter integer                 PROG_EMPTY_THRESH    = 10,
  parameter                         DOUT_RESET_VALUE     = "",
  parameter integer                 CDC_DEST_SYNC_FF     = 2,
  parameter integer                 FULL_RESET_VALUE     = 0,
  parameter integer                 REMOVE_WR_RD_PROT_LOGIC = 0,

  parameter integer                 WAKEUP_TIME          = 0,
  parameter integer                 VERSION              = 1

) (

  // Common module ports
  input  wire                                sleep,
  input  wire                                rst,

  // Write Domain ports
  input  wire                                wr_clk,
  input  wire                                wr_en,
  input  wire [WRITE_DATA_WIDTH-1:0]         din,
  output wire                                full,
  output wire                                prog_full,
  output wire [WR_DATA_COUNT_WIDTH-1:0]      wr_data_count,
  output wire                                overflow,
  output wire                                wr_rst_busy,

  // Read Domain ports
  input  wire                                rd_clk,
  input  wire                                rd_en,
  output wire [READ_DATA_WIDTH-1:0]          dout,
  output wire                                empty,
  output wire                                prog_empty,
  output wire [RD_DATA_COUNT_WIDTH-1:0]      rd_data_count,
  output wire                                underflow,
  output wire                                rd_rst_busy,

  // ECC Related ports
  input  wire                                injectsbiterr,
  input  wire                                injectdbiterr,
  output wire                                sbiterr,
  output wire                                dbiterr
);

  localparam SIM_ASSERT_CHK  = 0;
  localparam FIFO_MEM_TYPE   = FIFO_MEMORY_TYPE;
  localparam RD_MODE         = READ_MODE;
  localparam ENABLE_ECC      = (ECC_MODE == 1) ? 3 : 0;
  localparam FIFO_READ_DEPTH = FIFO_WRITE_DEPTH*WRITE_DATA_WIDTH/READ_DATA_WIDTH;
  localparam FIFO_SIZE       = FIFO_WRITE_DEPTH*WRITE_DATA_WIDTH;
  localparam WR_PNTR_WIDTH   = $clog2(FIFO_WRITE_DEPTH);
  localparam RD_PNTR_WIDTH   = $clog2(FIFO_READ_DEPTH);
  localparam FULL_RST_VAL    = FULL_RESET_VALUE == 0 ? 1'b0 : 1'b1;
  localparam WR_RD_RATIO     = (WR_PNTR_WIDTH > RD_PNTR_WIDTH) ? (WR_PNTR_WIDTH-RD_PNTR_WIDTH) : 0;
  localparam PF_THRESH_ADJ   = (READ_MODE == 0) ? PROG_FULL_THRESH :
                               PROG_FULL_THRESH - (2*(2**WR_RD_RATIO));
  localparam PE_THRESH_ADJ   = (READ_MODE == 1 && FIFO_MEMORY_TYPE != 4) ? PROG_EMPTY_THRESH - 2'h2 : PROG_EMPTY_THRESH;

  localparam PF_THRESH_MIN   = 3+(READ_MODE*2*(((FIFO_WRITE_DEPTH-1)/FIFO_READ_DEPTH)+1))+CDC_DEST_SYNC_FF;
  localparam PF_THRESH_MAX   = (FIFO_WRITE_DEPTH-3)-(READ_MODE*2*(((FIFO_WRITE_DEPTH-1)/FIFO_READ_DEPTH)+1));
  localparam PE_THRESH_MIN   = 3+(READ_MODE*2);
  localparam PE_THRESH_MAX   = (FIFO_READ_DEPTH-3)-(READ_MODE*2);
  localparam WR_DC_WIDTH_EXT = $clog2(FIFO_WRITE_DEPTH)+1;
  localparam RD_DC_WIDTH_EXT = $clog2(FIFO_READ_DEPTH)+1;
  localparam RD_LATENCY      = (READ_MODE == 2) ? 1 : (READ_MODE == 1) ? 2 : FIFO_READ_LATENCY;

  wire [WR_PNTR_WIDTH-1:0]   wr_pntr;
  wire [WR_PNTR_WIDTH:0]     wr_pntr_ext;
  wire [WR_PNTR_WIDTH-1:0]   wr_pntr_rd_cdc;
  wire [WR_PNTR_WIDTH:0]     wr_pntr_rd_cdc_dc;
  wire [WR_PNTR_WIDTH-1:0]   wr_pntr_rd;
  wire [WR_PNTR_WIDTH:0]     wr_pntr_rd_dc;
  wire [WR_PNTR_WIDTH-1:0]   rd_pntr_wr_adj;
  wire [WR_PNTR_WIDTH:0]     rd_pntr_wr_adj_dc;
  wire [WR_PNTR_WIDTH-1:0]   wr_pntr_plus1;
  wire [WR_PNTR_WIDTH-1:0]   wr_pntr_plus2;
  wire [WR_PNTR_WIDTH:0]     wr_pntr_plus1_pf;
  wire [WR_PNTR_WIDTH:0]     rd_pntr_wr_adj_inv_pf;
  reg  [WR_PNTR_WIDTH:0]     diff_pntr_pf_q = {WR_PNTR_WIDTH{1'b0}};
  wire [WR_PNTR_WIDTH-1:0]   diff_pntr_pf;
  wire [RD_PNTR_WIDTH-1:0]   rd_pntr;
  wire [RD_PNTR_WIDTH:0]     rd_pntr_ext;
  wire [RD_PNTR_WIDTH-1:0]   rd_pntr_wr_cdc;
  wire [RD_PNTR_WIDTH-1:0]   rd_pntr_wr;
  wire [RD_PNTR_WIDTH:0]     rd_pntr_wr_cdc_dc;
  wire [RD_PNTR_WIDTH:0]     rd_pntr_wr_dc;
  wire  [RD_PNTR_WIDTH-1:0]   wr_pntr_rd_adj;
  wire  [RD_PNTR_WIDTH:0]     wr_pntr_rd_adj_dc;
  wire [RD_PNTR_WIDTH-1:0]   rd_pntr_plus1;
  wire                       invalid_state;
  wire                       valid_fwft;
  wire                       ram_valid_fwft;
  wire                       going_empty;
  wire                       leaving_empty;
  reg                        ram_empty_i = 1'b1;
  wire                       empty_i;
  wire                       going_full;
  wire                       leaving_full;
  reg                        prog_full_i = FULL_RST_VAL;
  reg                        ram_full_i  = FULL_RST_VAL;
//  reg                        ram_full_i_fb = 1'b0;
  wire                       ram_wr_en_i;
  wire                       ram_rd_en_i;
  wire                       rd_en_i;
  reg                        rd_en_fwft;
  wire                       ram_regce;
  wire                       ram_regce_pipe;
  wire [READ_DATA_WIDTH-1:0] dout_i;
  reg                        empty_fwft_i     = 1'b1;
  reg                        empty_fwft_fb    = 1'b1;
  reg                        overflow_i       = 1'b0;
  reg                        underflow_i      = 1'b0;
  wire                       wrp_gt_rdp_and_red;
  wire                       wrp_lt_rdp_and_red;
  reg                        ram_wr_en_pf_q = 1'b0;
  reg                        ram_rd_en_pf_q = 1'b0;
  wire                       ram_wr_en_pf;
  wire                       ram_rd_en_pf;
  wire                       wr_pntr_plus1_pf_carry;
  wire                       rd_pntr_wr_adj_pf_carry;
  wire                       write_allow;
  wire                       read_allow;
  wire                       read_only;
  wire                       write_only;
  reg                        write_only_q;
  reg                        read_only_q;
  reg [RD_PNTR_WIDTH-1:0]    diff_pntr_pe_reg1;
  reg [RD_PNTR_WIDTH-1:0]    diff_pntr_pe_reg2;
  reg [RD_PNTR_WIDTH-1:0]    diff_pntr_pe = 'b0;
  reg                        prog_empty_i = 1'b1;
  // function to validate the write depth value
  function logic dpth_pwr_2;
    input integer fifo_depth;
    integer log2_of_depth; // correcponding to the default value of 2k depth
    log2_of_depth = $clog2(fifo_depth);
    if (fifo_depth == 2 ** log2_of_depth)
      dpth_pwr_2 = 1;
    else
      dpth_pwr_2 = 0;
    return dpth_pwr_2;
  endfunction
  
  initial begin : config_drc
    reg drc_err_flag;
    drc_err_flag = 0;
    #1;

    if (COMMON_CLOCK == 0 && FIFO_MEM_TYPE == 3) begin
      $error("[%s %0d-%0d] UltraRAM cannot be used as asynchronous FIFO because it has only one clock support %m", "XPM_FIFO", 1, 1);
      drc_err_flag = 1;
    end

    if (COMMON_CLOCK == 1 && RELATED_CLOCKS == 1) begin
      $error("[%s %0d-%0d] Related Clocks cannot be used in synchronous FIFO because it is applicable only for asynchronous FIFO %m", "XPM_FIFO", 1, 2);
      drc_err_flag = 1;
    end

    if(!(FIFO_WRITE_DEPTH > 15 && FIFO_WRITE_DEPTH <= 4*1024*1024)) begin
      $error("[%s %0d-%0d] FIFO_WRITE_DEPTH (%0d) value specified is not within the supported ranges. Miniumum supported depth is 16, and the maximum supported depth is 4*1024*1024 locations. %m", "XPM_FIFO", 1, 3, FIFO_WRITE_DEPTH);
      drc_err_flag = 1;
    end

    if(!dpth_pwr_2(FIFO_WRITE_DEPTH) && (FIFO_WRITE_DEPTH > 15 && FIFO_WRITE_DEPTH <= 4*1024*1024)) begin
      $error("[%s %0d-%0d] FIFO_WRITE_DEPTH (%0d) value specified is non-power of 2, but this release of XPM_FIFO supports configurations having the fifo write depth set to power of 2. %m", "XPM_FIFO", 1, 4, FIFO_WRITE_DEPTH);
      drc_err_flag = 1;
    end

    if (CDC_DEST_SYNC_FF < 2 || CDC_DEST_SYNC_FF > 8) begin
      $error("[%s %0d-%0d] CDC_DEST_SYNC_FF (%0d) value is specified for this configuration, but this beta release of XPM_FIFO supports CDC_DEST_SYNC_FF values in between 2 and 8. %m", "XPM_FIFO", 1, 5,CDC_DEST_SYNC_FF);
      drc_err_flag = 1;
    end
    if (CDC_DEST_SYNC_FF != 2 && RELATED_CLOCKS == 1) begin
      $error("[%s %0d-%0d] CDC_DEST_SYNC_FF (%0d) value is specified for this configuration, but CDC_DEST_SYNC_FF value can not be modified from default value when RELATED_CLOCKS parameter is set. %m", "XPM_FIFO", 1, 6,CDC_DEST_SYNC_FF);
      drc_err_flag = 1;
    end
    if (FIFO_WRITE_DEPTH == 16 && CDC_DEST_SYNC_FF > 4) begin
      $error("[%s %0d-%0d] CDC_DEST_SYNC_FF = %0d and FIFO_WRITE_DEPTH = %0d. This is invalid combination. Either FIFO_WRITE_DEPTH should be increased or CDC_DEST_SYNC_FF should be reduced. %m", "XPM_FIFO", 1, 7,CDC_DEST_SYNC_FF, FIFO_WRITE_DEPTH);
      drc_err_flag = 1;
    end

    // Range Checks
    if (COMMON_CLOCK > 1) begin
      $error("[%s %0d-%0d] COMMON_CLOCK (%s) value is outside of legal range. %m", "XPM_FIFO", 10, 1, COMMON_CLOCK);
      drc_err_flag = 1;
    end
    if (FIFO_MEMORY_TYPE > 3) begin
      $error("[%s %0d-%0d] FIFO_MEMORY_TYPE (%s) value is outside of legal range. %m", "XPM_FIFO", 10, 2, FIFO_MEMORY_TYPE);
      drc_err_flag = 1;
    end
	if (READ_MODE > 1) begin
      $error("[%s %0d-%0d] READ_MODE (%s) value is outside of legal range. %m", "XPM_FIFO", 10, 3, READ_MODE);
      drc_err_flag = 1;
    end

    if (ECC_MODE > 1) begin
      $error("[%s %0d-%0d] ECC_MODE (%s) value is outside of legal range. %m", "XPM_FIFO", 10, 4, ECC_MODE);
      drc_err_flag = 1;
    end
	if (!(WAKEUP_TIME == 0 || WAKEUP_TIME == 2)) begin
      $error("[%s %0d-%0d] WAKEUP_TIME (%0d) value is outside of legal range. WAKEUP_TIME should be either 0 or 2. %m", "XPM_FIFO", 10, 5, WAKEUP_TIME);
      drc_err_flag = 1;
    end
    if (!(VERSION == 0)) begin
      $error("[%s %0d-%0d] VERSION (%0d) value is outside of legal range. %m", "XPM_FIFO", 10, 6, VERSION);
      drc_err_flag = 1;
    end

    if (!(WRITE_DATA_WIDTH > 0)) begin
      $error("[%s %0d-%0d] WRITE_DATA_WIDTH (%0d) value is outside of legal range. %m", "XPM_FIFO", 15, 2, WRITE_DATA_WIDTH);
      drc_err_flag = 1;
    end
    if (!(READ_DATA_WIDTH > 0)) begin
      $error("[%s %0d-%0d] READ_DATA_WIDTH (%0d) value is outside of legal range. %m", "XPM_FIFO", 15, 3, READ_DATA_WIDTH);
      drc_err_flag = 1;
    end

    if ((PROG_FULL_THRESH < PF_THRESH_MIN) || (PROG_FULL_THRESH > PF_THRESH_MAX)) begin
      $error("[%s %0d-%0d] PROG_FULL_THRESH (%0d) value is outside of legal range. PROG_FULL_THRESH value must be between %0d and %0d. %m", "XPM_FIFO", 15, 4, PROG_FULL_THRESH, PF_THRESH_MIN, PF_THRESH_MAX);
      drc_err_flag = 1;
    end

    if ((PROG_EMPTY_THRESH < PE_THRESH_MIN) || (PROG_EMPTY_THRESH > PE_THRESH_MAX)) begin
      $error("[%s %0d-%0d] PROG_EMPTY_THRESH (%0d) value is outside of legal range. PROG_EMPTY_THRESH value must be between %0d and %0d. %m", "XPM_FIFO", 15, 5, PROG_EMPTY_THRESH, PE_THRESH_MIN, PE_THRESH_MAX);
      drc_err_flag = 1;
    end

    if ((WR_DATA_COUNT_WIDTH < 0) || (WR_DATA_COUNT_WIDTH > WR_DC_WIDTH_EXT)) begin
      $error("[%s %0d-%0d] WR_DATA_COUNT_WIDTH (%0d) value is outside of legal range. WR_DATA_COUNT_WIDTH value must be between %0d and %0d. %m", "XPM_FIFO", 15, 6, WR_DATA_COUNT_WIDTH, 0, WR_DC_WIDTH_EXT);
      drc_err_flag = 1;
    end


    if ((RD_DATA_COUNT_WIDTH < 0) || (RD_DATA_COUNT_WIDTH > RD_DC_WIDTH_EXT)) begin
      $error("[%s %0d-%0d] RD_DATA_COUNT_WIDTH (%0d) value is outside of legal range. RD_DATA_COUNT_WIDTH value must be between %0d and %0d. %m", "XPM_FIFO", 15, 7, RD_DATA_COUNT_WIDTH, 0, RD_DC_WIDTH_EXT);
      drc_err_flag = 1;
    end

    // Infos

    // Warnings
    if (drc_err_flag == 1)
      #1 $finish;
  end : config_drc

  wire wr_en_i;
  wire wr_rst_i;
  wire rd_rst_i;
  reg  rd_rst_d2 = 1'b0;
  wire rst_d1;
  wire rst_d2;
  wire clr_full;
  wire empty_fwft_d1;
  wire leaving_empty_fwft_fe;
  wire leaving_empty_fwft_re;
  wire le_fwft_re;
  wire le_fwft_fe;
  wire [1:0] extra_words_fwft;
  wire le_fwft_re_wr;
  wire le_fwft_fe_wr;

  generate

  xpm_fifo_rst # (COMMON_CLOCK, CDC_DEST_SYNC_FF, SIM_ASSERT_CHK)
    xpm_fifo_rst_inst (rst, wr_clk, rd_clk, wr_rst_i, rd_rst_i, wr_rst_busy, rd_rst_busy);

  xpm_fifo_reg_bit #(0)
    rst_d1_inst (1'b0, wr_clk, wr_rst_busy, rst_d1);
  xpm_fifo_reg_bit #(0)
    rst_d2_inst (1'b0, wr_clk, rst_d1, rst_d2);

  assign clr_full = ~wr_rst_busy & rst_d1 & ~rst;
  assign rd_en_i = (RD_MODE == 0) ? rd_en : rd_en_fwft;

  if (REMOVE_WR_RD_PROT_LOGIC == 1) begin : ngen_wr_rd_prot
    assign ram_wr_en_i = wr_en;
    assign ram_rd_en_i = rd_en_i;
  end : ngen_wr_rd_prot
  else begin : gen_wr_rd_prot
    assign ram_wr_en_i = wr_en & ~ram_full_i & ~(wr_rst_busy);
    assign ram_rd_en_i = rd_en_i & ~ram_empty_i;
  end : gen_wr_rd_prot

  // Write pointer generation
  xpm_counter_updn # (WR_PNTR_WIDTH+1, 0)
    wrp_inst (wr_rst_busy, wr_clk, ram_wr_en_i, ram_wr_en_i, 1'b0, wr_pntr_ext);
  assign wr_pntr = wr_pntr_ext[WR_PNTR_WIDTH-1:0];

  xpm_counter_updn # (WR_PNTR_WIDTH, 1)
    wrpp1_inst (wr_rst_busy, wr_clk, ram_wr_en_i, ram_wr_en_i, 1'b0, wr_pntr_plus1);

  xpm_counter_updn # (WR_PNTR_WIDTH, 2)
    wrpp2_inst (wr_rst_busy, wr_clk, ram_wr_en_i, ram_wr_en_i, 1'b0, wr_pntr_plus2);

  // Read pointer generation
  xpm_counter_updn # (RD_PNTR_WIDTH+1, 0)
    rdp_inst (rd_rst_i, rd_clk, ram_rd_en_i, ram_rd_en_i, 1'b0, rd_pntr_ext);
  assign rd_pntr = rd_pntr_ext[RD_PNTR_WIDTH-1:0];

  xpm_counter_updn # (RD_PNTR_WIDTH, 1)
    rdpp1_inst (rd_rst_i, rd_clk, ram_rd_en_i, ram_rd_en_i, 1'b0, rd_pntr_plus1);

  assign full       = ram_full_i;

  assign prog_full  = (PROG_FULL_THRESH > 0) ? prog_full_i : 1'b0;
  assign prog_empty  = (PROG_EMPTY_THRESH > 0) ? prog_empty_i : 1'b1;
  
  assign empty_i = (RD_MODE == 0)? ram_empty_i : empty_fwft_i;
  assign empty   = empty_i;

  // Simple dual port RAM instantiation for non-Built-in FIFO
  if (FIFO_MEMORY_TYPE < 4) begin : gen_sdpram

  // Reset is not supported when ECC is enabled by the BRAM/URAM primitives
    wire rst_int;
    if(ECC_MODE !=0) begin : gnd_rst
      assign rst_int = 0;
    end : gnd_rst
    else begin : rst_gen
      assign rst_int = rd_rst_i;
    end : rst_gen
  // ----------------------------------------------------------------------
  // Base module instantiation with simple dual port RAM configuration
  // ----------------------------------------------------------------------

  xpm_memory_base # (

    // Common module parameters
    .MEMORY_TYPE        (1                         ),
    .MEMORY_SIZE        (FIFO_SIZE                 ),
    .MEMORY_PRIMITIVE   (FIFO_MEMORY_TYPE          ),
    .CLOCKING_MODE      (COMMON_CLOCK ? 0 : 1      ),
    .ECC_MODE           (ENABLE_ECC                ),
    .MEMORY_INIT_FILE   ("none"                    ),
    .MEMORY_INIT_PARAM  (""                        ),
    .WAKEUP_TIME        (WAKEUP_TIME               ),
    .MESSAGE_CONTROL    (0                         ),
    .VERSION            (0                         ),

    // Port A module parameters
    .WRITE_DATA_WIDTH_A (WRITE_DATA_WIDTH          ),
    .READ_DATA_WIDTH_A  (WRITE_DATA_WIDTH          ),
    .BYTE_WRITE_WIDTH_A (WRITE_DATA_WIDTH          ),
    .ADDR_WIDTH_A       (WR_PNTR_WIDTH             ),
    .READ_RESET_VALUE_A ("0"                       ),
    .READ_LATENCY_A     (2                         ),
    .WRITE_MODE_A       (2                         ),

    // Port B module parameters
    .WRITE_DATA_WIDTH_B (READ_DATA_WIDTH           ),
    .READ_DATA_WIDTH_B  (READ_DATA_WIDTH           ),
    .BYTE_WRITE_WIDTH_B (READ_DATA_WIDTH           ),
    .ADDR_WIDTH_B       (RD_PNTR_WIDTH             ),
    .READ_RESET_VALUE_B (DOUT_RESET_VALUE          ),
//    .READ_LATENCY_B     (FIFO_READ_LATENCY == 0 ? 2 :FIFO_READ_LATENCY ),
    .READ_LATENCY_B     (RD_LATENCY),
    .WRITE_MODE_B       ((FIFO_MEMORY_TYPE == 1 || FIFO_MEMORY_TYPE == 3) ? 1 : 2)
  ) xpm_memory_base_inst (

    // Common module ports
    .sleep          (sleep                    ),

    // Port A module ports
    .clka           (wr_clk                   ),
    .rsta           (1'b0                     ),
    .ena            (ram_wr_en_i              ),
    .regcea         (1'b0                     ),
    .wea            (ram_wr_en_i              ),
    .addra          (wr_pntr                  ),
    .dina           (din                      ),
    .injectsbiterra (injectsbiterr            ),
    .injectdbiterra (injectdbiterr            ),
    .douta          (                         ),
    .sbiterra       (                         ),
    .dbiterra       (                         ),

    // Port B module ports
    .clkb           (rd_clk                   ),
    .rstb           (rst_int                  ),
    .enb            (ram_rd_en_i              ),
    .regceb         (READ_MODE == 0 ? ram_regce_pipe: ram_regce),
    .web            (1'b0                     ),
    .addrb          (rd_pntr                  ),
    .dinb           ({READ_DATA_WIDTH{1'b0}}  ),
    .injectsbiterrb (1'b0                     ),
    .injectdbiterrb (1'b0                     ),
    .doutb          (dout_i                   ),
    .sbiterrb       (sbiterr                  ),
    .dbiterrb       (dbiterr                  )
  );
  end : gen_sdpram

  if (WR_PNTR_WIDTH == RD_PNTR_WIDTH) begin : wrp_eq_rdp
    assign wr_pntr_rd_adj    = wr_pntr_rd[WR_PNTR_WIDTH-1:WR_PNTR_WIDTH-RD_PNTR_WIDTH];
    assign wr_pntr_rd_adj_dc = wr_pntr_rd_dc[WR_PNTR_WIDTH:WR_PNTR_WIDTH-RD_PNTR_WIDTH];
    assign rd_pntr_wr_adj    = rd_pntr_wr[RD_PNTR_WIDTH-1:RD_PNTR_WIDTH-WR_PNTR_WIDTH];
    assign rd_pntr_wr_adj_dc = rd_pntr_wr_dc[RD_PNTR_WIDTH:RD_PNTR_WIDTH-WR_PNTR_WIDTH];
  end : wrp_eq_rdp

  if (WR_PNTR_WIDTH > RD_PNTR_WIDTH) begin : wrp_gt_rdp
    assign wr_pntr_rd_adj = wr_pntr_rd[WR_PNTR_WIDTH-1:WR_PNTR_WIDTH-RD_PNTR_WIDTH];
    assign wr_pntr_rd_adj_dc = wr_pntr_rd_dc[WR_PNTR_WIDTH:WR_PNTR_WIDTH-RD_PNTR_WIDTH];
    assign rd_pntr_wr_adj[WR_PNTR_WIDTH-1:WR_PNTR_WIDTH-RD_PNTR_WIDTH] = rd_pntr_wr;
    assign rd_pntr_wr_adj[WR_PNTR_WIDTH-RD_PNTR_WIDTH-1:0] = {(WR_PNTR_WIDTH-RD_PNTR_WIDTH){1'b0}};
    assign rd_pntr_wr_adj_dc[WR_PNTR_WIDTH:WR_PNTR_WIDTH-RD_PNTR_WIDTH] = rd_pntr_wr_dc;
    assign rd_pntr_wr_adj_dc[WR_PNTR_WIDTH-RD_PNTR_WIDTH-1:0] = {(WR_PNTR_WIDTH-RD_PNTR_WIDTH){1'b0}};
  end : wrp_gt_rdp

  if (WR_PNTR_WIDTH < RD_PNTR_WIDTH) begin : wrp_lt_rdp
    assign wr_pntr_rd_adj[RD_PNTR_WIDTH-1:RD_PNTR_WIDTH-WR_PNTR_WIDTH] = wr_pntr_rd;
    assign wr_pntr_rd_adj[RD_PNTR_WIDTH-WR_PNTR_WIDTH-1:0] = {(RD_PNTR_WIDTH-WR_PNTR_WIDTH){1'b0}};
    assign wr_pntr_rd_adj_dc[RD_PNTR_WIDTH:RD_PNTR_WIDTH-WR_PNTR_WIDTH] = wr_pntr_rd_dc;
    assign wr_pntr_rd_adj_dc[RD_PNTR_WIDTH-WR_PNTR_WIDTH-1:0] = {(RD_PNTR_WIDTH-WR_PNTR_WIDTH){1'b0}};
    assign rd_pntr_wr_adj = rd_pntr_wr[RD_PNTR_WIDTH-1:RD_PNTR_WIDTH-WR_PNTR_WIDTH];
    assign rd_pntr_wr_adj_dc = rd_pntr_wr_dc[RD_PNTR_WIDTH:RD_PNTR_WIDTH-WR_PNTR_WIDTH];
  end : wrp_lt_rdp

  if (COMMON_CLOCK == 0 && RELATED_CLOCKS == 0) begin : gen_cdc_pntr
    // Synchronize the write pointer in rd_clk domain
    xpm_cdc_gray #(
      .DEST_SYNC_FF          (CDC_DEST_SYNC_FF),
      .WIDTH                 (WR_PNTR_WIDTH))
      
      wr_pntr_cdc_inst (
        .src_clk             (wr_clk),
        .src_in_bin          (wr_pntr),
        .dest_clk            (rd_clk),
        .dest_out_bin        (wr_pntr_rd_cdc));

    // Register the output of XPM_CDC_GRAY on read side
    xpm_fifo_reg_vec #(WR_PNTR_WIDTH)
      wpr_gray_reg (rd_rst_i, rd_clk, wr_pntr_rd_cdc, wr_pntr_rd);

    // Synchronize the extended write pointer in rd_clk domain
    xpm_cdc_gray #(
      .DEST_SYNC_FF          (READ_MODE == 0 ? CDC_DEST_SYNC_FF : CDC_DEST_SYNC_FF+2),
      .WIDTH                 (WR_PNTR_WIDTH+1))
      wr_pntr_cdc_dc_inst (
        .src_clk             (wr_clk),
        .src_in_bin          (wr_pntr_ext),
        .dest_clk            (rd_clk),
        .dest_out_bin        (wr_pntr_rd_cdc_dc));

    // Register the output of XPM_CDC_GRAY on read side
    xpm_fifo_reg_vec #(WR_PNTR_WIDTH+1)
      wpr_gray_reg_dc (rd_rst_i, rd_clk, wr_pntr_rd_cdc_dc, wr_pntr_rd_dc);

    // Synchronize the read pointer in wr_clk domain
    xpm_cdc_gray #(
      .DEST_SYNC_FF          (CDC_DEST_SYNC_FF),
      .WIDTH                 (RD_PNTR_WIDTH))
      rd_pntr_cdc_inst (
        .src_clk             (rd_clk),
        .src_in_bin          (rd_pntr),
        .dest_clk            (wr_clk),
        .dest_out_bin        (rd_pntr_wr_cdc));

    // Register the output of XPM_CDC_GRAY on write side
    xpm_fifo_reg_vec #(RD_PNTR_WIDTH)
      rpw_gray_reg (wr_rst_busy, wr_clk, rd_pntr_wr_cdc, rd_pntr_wr);

    // Synchronize the read pointer, subtracted by the extra word read for FWFT, in wr_clk domain
    xpm_cdc_gray #(
      .DEST_SYNC_FF          (CDC_DEST_SYNC_FF),
      .WIDTH                 (RD_PNTR_WIDTH+1))
      rd_pntr_cdc_dc_inst (
        .src_clk             (rd_clk),
        .src_in_bin          (rd_pntr_ext-extra_words_fwft),
        .dest_clk            (wr_clk),
        .dest_out_bin        (rd_pntr_wr_cdc_dc));

    // Register the output of XPM_CDC_GRAY on write side
    xpm_fifo_reg_vec #(RD_PNTR_WIDTH+1)
      rpw_gray_reg_dc (wr_rst_busy, wr_clk, rd_pntr_wr_cdc_dc, rd_pntr_wr_dc);

  end : gen_cdc_pntr

  if (RELATED_CLOCKS == 1) begin : gen_pntr_pf_rc
    xpm_fifo_reg_vec #(RD_PNTR_WIDTH)
      rpw_rc_reg (wr_rst_busy, wr_clk, rd_pntr, rd_pntr_wr);

    xpm_fifo_reg_vec #(WR_PNTR_WIDTH)
      wpr_rc_reg (rd_rst_i, rd_clk, wr_pntr, wr_pntr_rd);

    xpm_fifo_reg_vec #(WR_PNTR_WIDTH+1)
      wpr_rc_reg_dc (rd_rst_i, rd_clk, wr_pntr_ext, wr_pntr_rd_dc);

    xpm_fifo_reg_vec #(RD_PNTR_WIDTH+1)
      rpw_rc_reg_dc (wr_rst_busy, wr_clk, (rd_pntr_ext-extra_words_fwft), rd_pntr_wr_dc);
  end : gen_pntr_pf_rc

  if (COMMON_CLOCK == 0 || RELATED_CLOCKS == 1) begin : gen_pf_ic_rc
  
    assign going_empty   = ((wr_pntr_rd_adj == rd_pntr_plus1) & ram_rd_en_i);
    assign leaving_empty = ((wr_pntr_rd_adj == rd_pntr));
  
    assign going_full    = ((rd_pntr_wr_adj == wr_pntr_plus2) & ram_wr_en_i);
    assign leaving_full  = ((rd_pntr_wr_adj == wr_pntr_plus1));
  
    // Empty flag generation
    always @ (posedge rd_clk) begin
      if (rd_rst_i)
         ram_empty_i  <= 1'b1;
      else
         ram_empty_i  <= going_empty | leaving_empty;
    end
  
    // Full flag generation
    if (FULL_RST_VAL == 1) begin : gen_full_rst_val
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
          ram_full_i   <= FULL_RST_VAL;
        else if (~rst) begin
          if (clr_full)
            ram_full_i   <= 1'b0;
          else
            ram_full_i   <= going_full | leaving_full;
        end
      end
    end : gen_full_rst_val
    else begin : ngen_full_rst_val
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
          ram_full_i   <= 1'b0;
        else
          ram_full_i   <= going_full | leaving_full;
      end
    end : ngen_full_rst_val

  // synthesis translate_off
    if (SIM_ASSERT_CHK == 1) begin: assert_wr_rd_en
      always @ (posedge rd_clk) begin
        assert (!$isunknown(rd_en)) else $warning ("Input port 'rd_en' has unknown value 'X' or 'Z' at %0t. This may cause full/empty to be 'X' or 'Z' in simulation. Ensure 'rd_en' has a valid value ('0' or '1')",$time);
      end

      always @ (posedge wr_clk) begin
        assert (!$isunknown(wr_en)) else $warning ("Input port 'wr_en' has unknown value 'X' or 'Z' at %0t. This may cause full/empty to be 'X' or 'Z' in simulation. Ensure 'wr_en' has a valid value ('0' or '1')",$time);
      end

      always @ (posedge wr_clk) begin
        assert (!$isunknown(wr_en)) else $warning ("Input port 'wr_en' has unknown value 'X' or 'Z' at %0t. This may cause full/empty to be 'X' or 'Z' in simulation. Ensure 'wr_en' has a valid value ('0' or '1')",$time);
      end

    end : assert_wr_rd_en
  // synthesis translate_on

    // Programmable Full flag generation
    assign wr_pntr_plus1_pf = {wr_pntr_plus1,wr_pntr_plus1_pf_carry};
    assign rd_pntr_wr_adj_inv_pf = {~rd_pntr_wr_adj,rd_pntr_wr_adj_pf_carry};

    // PF carry generation
   assign wr_pntr_plus1_pf_carry  = ram_wr_en_i;
   assign rd_pntr_wr_adj_pf_carry = ram_wr_en_i;

    // PF diff pointer generation
    always @ (posedge wr_clk) begin
      if (wr_rst_busy)
         diff_pntr_pf_q  <= {WR_PNTR_WIDTH{1'b0}};
      else
         diff_pntr_pf_q  <= wr_pntr_plus1_pf + rd_pntr_wr_adj_inv_pf;
    end
    assign diff_pntr_pf = diff_pntr_pf_q[WR_PNTR_WIDTH:1];

    always @ (posedge wr_clk) begin
      if (wr_rst_busy)
         prog_full_i  <= FULL_RST_VAL;
      else if (clr_full)
         prog_full_i  <= 1'b0;
      else if (~ram_full_i) begin
        if (diff_pntr_pf >= PF_THRESH_ADJ)
          prog_full_i  <= 1'b1;
        else
          prog_full_i  <= 1'b0;
      end else
        prog_full_i  <= prog_full_i;
    end

   /*********************************************************
    * Programmable EMPTY flags
    *********************************************************/
   //Determine the Assert and Negate thresholds for Programmable Empty

   always @(posedge rd_clk) begin
     if (rd_rst_i) begin
       diff_pntr_pe      <= 0;
       prog_empty_i       <= 1'b1;
     end else begin
       if (ram_rd_en_i)
         diff_pntr_pe       <=  (wr_pntr_rd_adj - rd_pntr) - 1'h1;
       else
         diff_pntr_pe       <=  (wr_pntr_rd_adj - rd_pntr);
  
       if (~empty_i) begin
         if (diff_pntr_pe <= PE_THRESH_ADJ)
           prog_empty_i <= 1'b1;
         else
           prog_empty_i <= 1'b0;
       end else
         prog_empty_i   <= prog_empty_i;
     end
   end
  end : gen_pf_ic_rc

  if (COMMON_CLOCK == 1 && RELATED_CLOCKS == 0) begin : gen_pntr_flags_cc
    assign wr_pntr_rd = wr_pntr;
    assign rd_pntr_wr = rd_pntr;
    assign wr_pntr_rd_dc = wr_pntr_ext;
    assign rd_pntr_wr_dc = rd_pntr_ext-extra_words_fwft;
    assign write_allow  = ram_wr_en_i & ~ram_full_i;
    assign read_allow   = ram_rd_en_i & ~empty_i;

    if (WR_PNTR_WIDTH == RD_PNTR_WIDTH) begin : wrp_eq_rdp
      assign ram_wr_en_pf  = ram_wr_en_i;
      assign ram_rd_en_pf  = ram_rd_en_i;
  
      assign going_empty   = ((wr_pntr_rd_adj == rd_pntr_plus1) & ~ram_wr_en_i & ram_rd_en_i);
      assign leaving_empty = ((wr_pntr_rd_adj == rd_pntr) & ram_wr_en_i);
  
      assign going_full    = ((rd_pntr_wr_adj == wr_pntr_plus1) & ram_wr_en_i & ~ram_rd_en_i);
      assign leaving_full  = ((rd_pntr_wr_adj == wr_pntr) & ram_rd_en_i);

      assign write_only    = write_allow & ~read_allow;
      assign read_only     = read_allow & ~write_allow;

    end : wrp_eq_rdp
  
    if (WR_PNTR_WIDTH > RD_PNTR_WIDTH) begin : wrp_gt_rdp
      assign wrp_gt_rdp_and_red = &wr_pntr_rd[WR_PNTR_WIDTH-RD_PNTR_WIDTH-1:0];
  
      assign going_empty   = ((wr_pntr_rd_adj == rd_pntr_plus1) & ~(ram_wr_en_i & wrp_gt_rdp_and_red) & ram_rd_en_i);
      assign leaving_empty = ((wr_pntr_rd_adj == rd_pntr) & (ram_wr_en_i & wrp_gt_rdp_and_red));
  
      assign going_full    = ((rd_pntr_wr_adj == wr_pntr_plus1) & ram_wr_en_i & ~ram_rd_en_i);
      assign leaving_full  = ((rd_pntr_wr_adj == wr_pntr) & ram_rd_en_i);
  
      assign ram_wr_en_pf  = ram_wr_en_i & wrp_gt_rdp_and_red;
      assign ram_rd_en_pf  = ram_rd_en_i;

      assign read_only     = read_allow & (~(write_allow  & (&wr_pntr[WR_PNTR_WIDTH-RD_PNTR_WIDTH-1 : 0])));
      assign write_only    = write_allow & (&wr_pntr[WR_PNTR_WIDTH-RD_PNTR_WIDTH-1 : 0]) & ~read_allow;


    end : wrp_gt_rdp
  
    if (WR_PNTR_WIDTH < RD_PNTR_WIDTH) begin : wrp_lt_rdp
      assign wrp_lt_rdp_and_red = &rd_pntr_wr[RD_PNTR_WIDTH-WR_PNTR_WIDTH-1:0];
  
      assign going_empty   = ((wr_pntr_rd_adj == rd_pntr_plus1) & ~ram_wr_en_i & ram_rd_en_i);
      assign leaving_empty = ((wr_pntr_rd_adj == rd_pntr) & ram_wr_en_i);
  
      assign going_full    = ((rd_pntr_wr_adj == wr_pntr_plus1) & ~(ram_rd_en_i & wrp_lt_rdp_and_red) & ram_wr_en_i);
      assign leaving_full  = ((rd_pntr_wr_adj == wr_pntr) & (ram_rd_en_i & wrp_lt_rdp_and_red));
  
      assign ram_wr_en_pf = ram_wr_en_i;
      assign ram_rd_en_pf = ram_rd_en_i & wrp_lt_rdp_and_red;

      assign read_only   = read_allow & (&rd_pntr[RD_PNTR_WIDTH-WR_PNTR_WIDTH-1 : 0]) & ~write_allow;
      assign write_only    = write_allow    & (~(read_allow & (&rd_pntr[RD_PNTR_WIDTH-WR_PNTR_WIDTH-1 : 0])));
    end : wrp_lt_rdp
  
    // Empty flag generation
    always @ (posedge rd_clk) begin
      if (rd_rst_i)
         ram_empty_i  <= 1'b1;
      else
         ram_empty_i  <= going_empty | (~leaving_empty & ram_empty_i);
    end

    // Full flag generation
    if (FULL_RST_VAL == 1) begin : gen_full_rst_val
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
          ram_full_i   <= FULL_RST_VAL;
        else if (~rst) begin
          if (clr_full)
            ram_full_i   <= 1'b0;
          else
            ram_full_i   <= going_full | (~leaving_full & ram_full_i);
        end
      end
    end : gen_full_rst_val
    else begin : ngen_full_rst_val
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
          ram_full_i   <= 1'b0;
        else
          ram_full_i   <= going_full | (~leaving_full & ram_full_i);
      end
    end : ngen_full_rst_val

    // Programmable Full flag generation
    if ((WR_PNTR_WIDTH == RD_PNTR_WIDTH) && (RELATED_CLOCKS == 0)) begin : wrp_eq_rdp_pf_cc

      assign wr_pntr_plus1_pf = {wr_pntr_plus1,wr_pntr_plus1_pf_carry};
      assign rd_pntr_wr_adj_inv_pf = {~rd_pntr_wr_adj,rd_pntr_wr_adj_pf_carry};

      // Delayed write/read enable for PF generation
      always @ (posedge wr_clk) begin
        if (wr_rst_busy) begin
           ram_wr_en_pf_q   <= 1'b0;
           ram_rd_en_pf_q   <= 1'b0;
        end else begin
           ram_wr_en_pf_q   <= ram_wr_en_pf;
           ram_rd_en_pf_q   <= ram_rd_en_pf;
        end
      end

      // PF carry generation
     assign wr_pntr_plus1_pf_carry  = ram_wr_en_i & ~ram_rd_en_pf;
     assign rd_pntr_wr_adj_pf_carry = ram_wr_en_i & ~ram_rd_en_pf;

      // PF diff pointer generation
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
           diff_pntr_pf_q  <= {WR_PNTR_WIDTH{1'b0}};
        else
           diff_pntr_pf_q  <= wr_pntr_plus1_pf + rd_pntr_wr_adj_inv_pf;
      end
      assign diff_pntr_pf = diff_pntr_pf_q[WR_PNTR_WIDTH:1];

      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
           prog_full_i  <= FULL_RST_VAL;
        else if (clr_full)
           prog_full_i  <= 1'b0;
        else if ((diff_pntr_pf == PF_THRESH_ADJ) & ram_wr_en_pf_q & ~ram_rd_en_pf_q)
           prog_full_i  <= 1'b1;
        else if ((diff_pntr_pf == PF_THRESH_ADJ) & ~ram_wr_en_pf_q & ram_rd_en_pf_q)
           prog_full_i  <= 1'b0;
        else
           prog_full_i  <= prog_full_i;
      end

      always @(posedge rd_clk) begin
        if (rd_rst_i) begin
          read_only_q    <= 1'b0;
          write_only_q   <= 1'b0;
          diff_pntr_pe    <= 0;
        end 
        else begin
          read_only_q  <= read_only;
          write_only_q <= write_only;
          // Add 1 to the difference pointer value when write or both write & read or no write & read happen.
          if (read_only)
            diff_pntr_pe <= wr_pntr_rd_adj - rd_pntr - 1;
          else
            diff_pntr_pe <= wr_pntr_rd_adj - rd_pntr;
        end
      end

      always @(posedge rd_clk) begin
        if (rd_rst_i)
          prog_empty_i  <= 1'b1;
        else begin
          if (diff_pntr_pe == PE_THRESH_ADJ && read_only_q)
            prog_empty_i <= 1'b1;
          else if (diff_pntr_pe == PE_THRESH_ADJ && write_only_q)
            prog_empty_i <= 1'b0;
          else
            prog_empty_i <= prog_empty_i;
        end
      end
    end : wrp_eq_rdp_pf_cc

    if ((WR_PNTR_WIDTH != RD_PNTR_WIDTH) && (RELATED_CLOCKS == 0)) begin : wrp_neq_rdp_pf_cc
      // PF diff pointer generation
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
           diff_pntr_pf_q  <= {WR_PNTR_WIDTH{1'b0}};
        else if (~ram_full_i)
           diff_pntr_pf_q[WR_PNTR_WIDTH:1]  <= wr_pntr + ~rd_pntr_wr_adj + 1;
      end
      assign diff_pntr_pf = diff_pntr_pf_q[WR_PNTR_WIDTH:1];
      always @ (posedge wr_clk) begin
        if (wr_rst_busy)
           prog_full_i  <= FULL_RST_VAL;
        else if (clr_full)
           prog_full_i  <= 1'b0;
        else if (~ram_full_i) begin
          if (diff_pntr_pf >= PF_THRESH_ADJ)
             prog_full_i  <= 1'b1;
          else if (diff_pntr_pf < PF_THRESH_ADJ)
             prog_full_i  <= 1'b0;
          else
             prog_full_i  <= prog_full_i;
        end
      end
      // Programmanble Empty flag Generation
      // Diff pointer Generation
      localparam [RD_PNTR_WIDTH-1 : 0] DIFF_MAX_RD = {RD_PNTR_WIDTH{1'b1}};
      wire [RD_PNTR_WIDTH-1:0] diff_pntr_pe_max;
      wire                     carry;
      reg  [RD_PNTR_WIDTH : 0] diff_pntr_pe_asym = 'b0;
      wire [RD_PNTR_WIDTH : 0] wr_pntr_rd_adj_asym;
      wire [RD_PNTR_WIDTH : 0] rd_pntr_asym;
      reg                      full_reg;
      reg                      rst_full_ff_reg1;
      reg                      rst_full_ff_reg2;

      assign diff_pntr_pe_max = DIFF_MAX_RD;
      assign wr_pntr_rd_adj_asym[RD_PNTR_WIDTH:0] = {wr_pntr_rd_adj,1'b1};
      assign rd_pntr_asym[RD_PNTR_WIDTH:0] = {~rd_pntr,1'b1};

      always @(posedge rd_clk ) begin
        if (rd_rst_i) begin
          diff_pntr_pe_asym    <= 0;
          full_reg             <= 0;
          rst_full_ff_reg1     <= 1;
          rst_full_ff_reg2     <= 1;
          diff_pntr_pe_reg1    <= 0;
        end else begin
          diff_pntr_pe_asym <= wr_pntr_rd_adj_asym + rd_pntr_asym;
          full_reg          <= ram_full_i;
          rst_full_ff_reg1  <= FULL_RST_VAL;
          rst_full_ff_reg2  <= rst_full_ff_reg1;
        end
      end
      wire [RD_PNTR_WIDTH-1:0]    diff_pntr_pe_i;
      assign carry = (~(|(diff_pntr_pe_asym [RD_PNTR_WIDTH : 1])));
      assign diff_pntr_pe_i = (full_reg && ~rst_d2 && carry ) ? diff_pntr_pe_max : diff_pntr_pe_asym[RD_PNTR_WIDTH:1];
  
      always @(posedge rd_clk) begin
        if (rd_rst_i)
          prog_empty_i  <= 1'b1;
        else begin
          if (diff_pntr_pe_i <= PE_THRESH_ADJ)
            prog_empty_i <= 1'b1;
          else if (diff_pntr_pe_i > PE_THRESH_ADJ)
            prog_empty_i <= 1'b0;
          else
            prog_empty_i <= prog_empty_i;
        end
      end
    end : wrp_neq_rdp_pf_cc

  end : gen_pntr_flags_cc

  if (READ_MODE == 0 && FIFO_READ_LATENCY > 1) begin : gen_regce_std
    xpm_reg_pipe_bit #(FIFO_READ_LATENCY-1, 0)
      wrst_wr_inst (rd_rst_i, rd_clk, ram_rd_en_i, ram_regce_pipe);
  end : gen_regce_std

  if (READ_MODE == 1 && FIFO_MEMORY_TYPE != 4) begin : gen_fwft
  // First word fall through logic

   localparam invalid             = 0;
   localparam stage1_valid        = 2;
   localparam stage2_valid        = 1;
   localparam both_stages_valid   = 3;

   reg  [1:0] curr_fwft_state = invalid;
   reg  [1:0] next_fwft_state;// = invalid;
   wire next_fwft_state_d1;
   assign invalid_state = ~|curr_fwft_state;
   assign valid_fwft = next_fwft_state_d1;
   assign ram_valid_fwft = curr_fwft_state[1];

    xpm_fifo_reg_bit #(0)
      next_state_d1_inst (1'b0, rd_clk, next_fwft_state[0], next_fwft_state_d1);
   //FSM : To generate the enable, clock enable for xpm_memory and to generate
   //empty signal
   //FSM : Next state Assignment
     always @(curr_fwft_state or ram_empty_i or rd_en) begin
       case (curr_fwft_state)
         invalid: begin
           if (~ram_empty_i)
              next_fwft_state     = stage1_valid;
           else
              next_fwft_state     = invalid;
           end
         stage1_valid: begin
           if (ram_empty_i)
              next_fwft_state     = stage2_valid;
           else
              next_fwft_state     = both_stages_valid;
           end
         stage2_valid: begin
           if (ram_empty_i && rd_en)
              next_fwft_state     = invalid;
           else if (~ram_empty_i && rd_en)
              next_fwft_state     = stage1_valid;
           else if (~ram_empty_i && ~rd_en)
              next_fwft_state     = both_stages_valid;
           else
              next_fwft_state     = stage2_valid;
           end
         both_stages_valid: begin
           if (ram_empty_i && rd_en)
              next_fwft_state     = stage2_valid;
           else if (~ram_empty_i && rd_en)
              next_fwft_state     = both_stages_valid;
           else
              next_fwft_state     = both_stages_valid;
           end
         default: next_fwft_state    = invalid;
       endcase
     end
     // FSM : current state assignment
     always @ (posedge rd_clk) begin
       if (rd_rst_i)
          curr_fwft_state  <= invalid;
       else
          curr_fwft_state  <= next_fwft_state;
     end
 
     reg ram_regout_en;

     // FSM(output assignments) : clock enable generation for xpm_memory
     //always @(*) begin
     always @(curr_fwft_state or rd_en) begin
       case (curr_fwft_state)
         invalid:           ram_regout_en = 1'b0;
         stage1_valid:      ram_regout_en = 1'b1;
         stage2_valid:      ram_regout_en = 1'b0;
         both_stages_valid: ram_regout_en = rd_en;
         default:           ram_regout_en = 1'b0;
       endcase
     end

     // FSM(output assignments) : rd_en (enable) signal generation for xpm_memory
     always @(curr_fwft_state or ram_empty_i or rd_en) begin
       case (curr_fwft_state)
         invalid :
           if (~ram_empty_i)
             rd_en_fwft = 1'b1;
           else
             rd_en_fwft = 1'b0;
         stage1_valid :
           if (~ram_empty_i)
             rd_en_fwft = 1'b1;
           else
             rd_en_fwft = 1'b0;
         stage2_valid :
           if (~ram_empty_i)
             rd_en_fwft = 1'b1;
           else
             rd_en_fwft = 1'b0;
         both_stages_valid :
           if (~ram_empty_i && rd_en)
             rd_en_fwft = 1'b1;
           else
             rd_en_fwft = 1'b0;
         default :
           rd_en_fwft = 1'b0;
       endcase
     end
     // assingment to control regce xpm_memory
     assign ram_regce = ram_regout_en;

     reg going_empty_fwft;
     reg leaving_empty_fwft;

     always @(curr_fwft_state or rd_en) begin
       case (curr_fwft_state)
         stage2_valid : going_empty_fwft = rd_en;
         default      : going_empty_fwft = 1'b0;
       endcase
     end

     always @(curr_fwft_state or rd_en) begin
       case (curr_fwft_state)
         stage1_valid : leaving_empty_fwft = 1'b1;
         default      : leaving_empty_fwft = 1'b0;
       endcase
     end
     // fwft empty signal generation 
     always @ (posedge rd_clk) begin
       if(rd_rst_i)
         begin
           empty_fwft_i  <= 1'b1;
           empty_fwft_fb <= 1'b1;
         end
       else begin
         empty_fwft_i  <= going_empty_fwft | (~ leaving_empty_fwft & empty_fwft_fb);
         empty_fwft_fb <= going_empty_fwft | (~ leaving_empty_fwft & empty_fwft_fb);
       end
     end

    xpm_fifo_reg_bit #(0)
      empty_fwft_d1_inst (1'b0, rd_clk, leaving_empty_fwft, empty_fwft_d1);

    wire ge_fwft_d1;
    xpm_fifo_reg_bit #(0)
      ge_fwft_d1_inst (1'b0, rd_clk, going_empty_fwft, ge_fwft_d1);

    wire count_up  ;
    wire count_down;
    wire count_en  ;
    wire count_rst ;
    assign count_up   = (next_fwft_state == 2'b10 && ~|curr_fwft_state) | (curr_fwft_state == 2'b10 && &next_fwft_state) | (curr_fwft_state == 2'b01 && &next_fwft_state);
    assign count_down = (next_fwft_state == 2'b01 && &curr_fwft_state) | (curr_fwft_state == 2'b01 && ~|next_fwft_state);
    assign count_en   = count_up | count_down;
    assign count_rst  = (rd_rst_i | (~|curr_fwft_state & ~|next_fwft_state));

    xpm_counter_updn # (2, 0)
      rdpp1_inst (count_rst, rd_clk, count_en, count_up, count_down, extra_words_fwft);

 
  end : gen_fwft


  if (READ_MODE == 2) begin : gen_fwft_ll
  // Low Latency First word fall through logic

   localparam invalid             = 0;
   localparam stage1_valid        = 2;
   localparam stage2_valid        = 1;
   localparam both_stages_valid   = 3;

   reg  [1:0] curr_fwft_state = invalid;
   reg  [1:0] next_fwft_state;// = invalid;
   reg  ram_regout_en;
   wire ram_empty_d1;

   //FSM : To generate the enable, clock enable for xpm_memory and to generate
   //empty signal
   //FSM : Next state Assignment
     always @(curr_fwft_state or ram_empty_i or rd_en) begin
       case (curr_fwft_state)
         invalid: begin
           if (~ram_empty_i)
              next_fwft_state     = stage1_valid;
           else
              next_fwft_state     = invalid;
           end
         stage1_valid: begin
           if (ram_empty_i && rd_en)
              next_fwft_state     = invalid;
           else
              next_fwft_state     = stage1_valid;
           end
         default: next_fwft_state    = invalid;
       endcase
     end
     // FSM : current state assignment
     always @ (posedge rd_clk) begin
       if (rd_rst_i)
          curr_fwft_state  <= invalid;
       else
          curr_fwft_state  <= next_fwft_state;
     end
 

     // FSM(output assignments) : clock enable generation for xpm_memory
    xpm_fifo_reg_bit #(1)
      ram_empty_d1_inst (rd_rst_i, rd_clk, ram_empty_i, ram_empty_d1);

     always @ (posedge rd_clk) begin
       if (rd_rst_i)
          curr_fwft_state  <= invalid;
       else
          curr_fwft_state  <= next_fwft_state;
     end
     always @(curr_fwft_state or ram_empty_d1 or ram_empty_i or rd_en) begin
       case (curr_fwft_state)
         invalid:           ram_regout_en = ram_empty_d1 & ~ram_empty_i;
         stage1_valid:      ram_regout_en = ~ram_empty_i & rd_en;
         default:           ram_regout_en = 1'b0;
       endcase
     end

     // FSM(output assignments) : rd_en (enable) signal generation for xpm_memory
     always @(curr_fwft_state or ram_empty_i or rd_en) begin
       case (curr_fwft_state)
         invalid :      rd_en_fwft = ~ram_empty_i;
         stage1_valid:  rd_en_fwft = ~ram_empty_i & rd_en;
         default :      rd_en_fwft = 1'b0;
       endcase
     end
     // assingment to control regce xpm_memory
     assign ram_regce = ram_regout_en;

     reg going_empty_fwft;
     reg leaving_empty_fwft;

     always @(curr_fwft_state or ram_empty_i or rd_en) begin
       case (curr_fwft_state)
         stage1_valid : going_empty_fwft = ram_empty_i & rd_en;
         default      : going_empty_fwft = 1'b0;
       endcase
     end

     always @(curr_fwft_state or ram_empty_d1 or ram_empty_i) begin
       case (curr_fwft_state)
         invalid      : leaving_empty_fwft = ram_empty_d1 & ~ram_empty_i;
         stage1_valid : leaving_empty_fwft = 1'b1;
         default      : leaving_empty_fwft = 1'b0;
       endcase
     end
     // fwft empty signal generation 
     always @ (posedge rd_clk) begin
       if(rd_rst_i)
         begin
           empty_fwft_i  <= 1'b1;
           empty_fwft_fb <= 1'b1;
         end
       else begin
         empty_fwft_i  <= going_empty_fwft | (~ leaving_empty_fwft & empty_fwft_fb);
         empty_fwft_fb <= going_empty_fwft | (~ leaving_empty_fwft & empty_fwft_fb);
       end
     end

    xpm_fifo_reg_bit #(0)
      empty_fwft_d1_inst (1'b0, rd_clk, leaving_empty_fwft, empty_fwft_d1);

    assign le_fwft_re = ~empty_fwft_d1 &  leaving_empty_fwft;
    assign le_fwft_fe =  empty_fwft_d1 & ~leaving_empty_fwft;

    wire count_up  ;
    wire count_down;
    wire count_en  ;
    wire count_rst ;
    assign count_up   = (next_fwft_state == 2'b10 && ~|curr_fwft_state) | (curr_fwft_state == 2'b10 && &next_fwft_state) | (curr_fwft_state == 2'b01 && &next_fwft_state);
    assign count_down = (next_fwft_state == 2'b01 && &curr_fwft_state) | (curr_fwft_state == 2'b01 && ~|next_fwft_state);
    assign count_en   = count_up | count_down;
    assign count_rst  = (rd_rst_i | (~|curr_fwft_state & ~|next_fwft_state));
 
    xpm_counter_updn # (2, 0)
      rdpp1_inst (count_rst, rd_clk, count_en, count_up, count_down, extra_words_fwft);
 
  end : gen_fwft_ll

  if (READ_MODE == 0) begin : ngen_fwft
    assign le_fwft_re       = 1'b0;
    assign le_fwft_fe       = 1'b0;
    assign extra_words_fwft = 2'h0;
  end : ngen_fwft

  // output data bus assignment
  assign dout  = dout_i;

  // Overflow and Underflow flag generation
    always @ (posedge rd_clk) begin
      underflow_i <=  (rd_rst_i | empty_i) & rd_en;
    end

    always @ (posedge wr_clk) begin
     overflow_i  <=  (wr_rst_busy | ram_full_i) & wr_en;
    end
  // underflow and overflow flags assignment
  assign underflow   = underflow_i;
  assign overflow    = overflow_i;

  // -------------------------------------------------------------------------------------------------------------------
  // Write Data Count for Independent Clocks FIFO
  // -------------------------------------------------------------------------------------------------------------------

  reg  [WR_DC_WIDTH_EXT-1:0] wr_data_count_i;
  wire [WR_DC_WIDTH_EXT-1:0] diff_wr_rd_pntr;
  assign diff_wr_rd_pntr = wr_pntr_ext-rd_pntr_wr_adj_dc;
  always @ (posedge wr_clk) begin
    if (wr_rst_busy)
       wr_data_count_i   <= {WR_DC_WIDTH_EXT{1'b0}};
    else
       wr_data_count_i  <= diff_wr_rd_pntr;
  end
  assign wr_data_count = wr_data_count_i[WR_DC_WIDTH_EXT-1:WR_DC_WIDTH_EXT-WR_DATA_COUNT_WIDTH];

  // -------------------------------------------------------------------------------------------------------------------
  // Read Data Count for Independent Clocks FIFO
  // -------------------------------------------------------------------------------------------------------------------

  reg  [RD_DC_WIDTH_EXT-1:0] rd_data_count_i;
  wire [RD_DC_WIDTH_EXT-1:0] diff_wr_rd_pntr_rdc;
  assign diff_wr_rd_pntr_rdc = wr_pntr_rd_adj_dc-rd_pntr_ext+extra_words_fwft;
  always @ (posedge rd_clk) begin
    if (rd_rst_i | invalid_state)
       rd_data_count_i   <= {RD_DC_WIDTH_EXT{1'b0}};
    else
       rd_data_count_i  <= diff_wr_rd_pntr_rdc;
  end
  assign rd_data_count = rd_data_count_i[RD_DC_WIDTH_EXT-1:RD_DC_WIDTH_EXT-RD_DATA_COUNT_WIDTH];

  endgenerate

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation constructs
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off

  initial begin
  #1;
    if (SIM_ASSERT_CHK == 1)
    `ifdef XILINX_SIMULATOR
      $warning("Vivado Simulator does not currently support the SystemVerilog Assertion syntax used within XPM_FIFO.  \
Messages related to potential misuse will not be reported.");
    `else
      $warning("SIM_ASSERT_CHK (%0d) specifies simulation message reporting, messages related to potential misuse \
will be reported.", SIM_ASSERT_CHK);
    `endif
  end

  `ifndef XILINX_SIMULATOR
  if (SIM_ASSERT_CHK == 1) begin : rst_usage
    //Checks for valid conditions in which the src_send signal can toggle (based on src_rcv value)
    //Start new handshake after previous handshake completes.
    assume property (@(posedge wr_clk )
      (($past(rst) == 0) && (rst == 1)) |-> ##1 $rose(wr_rst_busy))
    else
      $error("[%s %s-%0d] New reset (rst transitioning to 1) at %0t shouldn't occur until the previous reset \
sequence completes (wr_rst_busy must be 0).  This reset is ignored.  Please refer to the \
XPM_FIFO documentation in the libraries guide.", "XPM_FIFO_RESET", "S", 1, $time);
  end : rst_usage

  if (SIM_ASSERT_CHK == 1 && FULL_RESET_VALUE == 1) begin : rst_full_usage
    assert property (@(posedge wr_clk )
      $rose(wr_rst_busy) |-> ##1 $rose(full))
    else 
      $error("[%s %s-%0d] FULL_RESET_VALUE is set to %0d. Full flag is not 1 or transitioning to 1 at %0t.", "FULL_RESET_VALUE", "S", 2, FULL_RESET_VALUE, $time);

    assert property (@(posedge wr_clk )
      $fell(wr_rst_busy) |-> ##1 $fell(full))
    else
      $error("[%s %s-%0d] After reset removal, full flag is not transitioning to 0 at %0t.", "FULL_CHECK", "S", 3, $time);

  end : rst_full_usage

  if (SIM_ASSERT_CHK == 1) begin : rst_empty_chk
    assert property (@(posedge rd_clk )
      ($rose(rd_rst_busy) || (empty && $rose(rd_rst_busy))) |-> ##1 $rose(empty))
    else 
      $error("[%s %s-%0d] Reset is applied, but empty flag is not 1 or transitioning to 1 at %0t.", "EMPTY_CHECK", "S", 4, $time);

    assert property (@(posedge wr_clk )
      ($changed(rd_pntr) |->  ##1 ($past(rd_pntr) == rd_pntr_wr)))
    else 
      $error("[%s %s-%0d] 'sleep' is deasserted at %0t, but wr_en must be low for %0d wr_clk cycles after %0t", "SLEEP_CHECK", "S", 5, $time, WAKEUP_TIME, $time);
  end : rst_empty_chk

  if (SIM_ASSERT_CHK == 1) begin : sleep_chk
    assert property (@(posedge wr_clk )
      ($fell(sleep) |->  !wr_en[*WAKEUP_TIME]))
    else 
      $error("[%s %s-%0d] 'sleep' is deasserted at %0t, but wr_en must be low for %0d wr_clk cycles after %0t", "SLEEP_CHECK", "S", 6, $time, WAKEUP_TIME, $time);

    assert property (@(posedge rd_clk )
      ($fell(sleep) |->  !rd_en[*WAKEUP_TIME]))
    else 
      $error("[%s %s-%0d] 'sleep' is deasserted at %0t, but rd_en must be low for %0d rd_clk cycles after %0t", "SLEEP_CHECK", "S", 7, $time, WAKEUP_TIME, $time);
  end : sleep_chk

  `endif

  // synthesis translate_on
endmodule : xpm_fifo_base

//********************************************************************************************************************

module xpm_fifo_rst # (
  parameter integer   COMMON_CLOCK     = 1,
  parameter integer   CDC_DEST_SYNC_FF = 2,
  parameter integer   SIM_ASSERT_CHK = 0

) (
  input  wire         rst,
  input  wire         wr_clk,
  input  wire         rd_clk,
  output wire         wr_rst,
  output wire         rd_rst,
  output wire         wr_rst_busy,
  output wire         rd_rst_busy
);
  reg  [1:0] power_on_rst  = 2'h3;
  reg  fifo_wr_rst_i = 1'b0;
  wire fifo_rd_rst_i;
  wire rst_i;

  // -------------------------------------------------------------------------------------------------------------------
  // Reset Logic
  // -------------------------------------------------------------------------------------------------------------------
   always @ (posedge wr_clk) begin
     power_on_rst <= {power_on_rst[0], 1'b0};
   end
   assign rst_i = power_on_rst[1] | rst;

  // Write and read reset generation common clock FIFO
   if (COMMON_CLOCK == 1) begin : gen_rst_cc
    assign wr_rst        = fifo_wr_rst_i;
    assign rd_rst        = fifo_wr_rst_i;
    assign rd_rst_busy   = fifo_wr_rst_i;
    assign wr_rst_busy   = fifo_wr_rst_i;

  // synthesis translate_off
    if (SIM_ASSERT_CHK == 1) begin: assert_rst
      always @ (posedge wr_clk) begin
        assert (!$isunknown(rst)) else $warning ("Input port 'rst' has unknown value 'X' or 'Z' at %0t. This may cause the outputs of FIFO to be 'X' or 'Z' in simulation. Ensure 'rst' has a valid value ('0' or '1')",$time);
      end
    end : assert_rst
  // synthesis translate_on

    always @ (posedge wr_clk) begin
      if (rst_i && ~fifo_wr_rst_i)
        fifo_wr_rst_i <= 1'b1;
      else
        fifo_wr_rst_i <= 1'b0;
    end
  end : gen_rst_cc

  // Write and read reset generation independent clock FIFO
  if (COMMON_CLOCK == 0) begin : gen_rst_ic
    wire fifo_wr_rst_d2               ;
    reg  fifo_wr_rst_d3         = 1'b0;
    wire fifo_rd_rst_d3               ;
    reg  fifo_wr_rst_done       = 1'b0;
    reg  fifo_rd_rst_done       = 1'b0;
    reg  fifo_rd_rst_d3_wr_d2   = 1'b0;
    wire fifo_rst_active;
    wire fifo_rst_done;
    wire fifo_rd_rst_wr_i;

    assign wr_rst        = fifo_wr_rst_i;
    assign rd_rst        = fifo_rd_rst_i | fifo_rd_rst_d3;
    assign rd_rst_busy   = fifo_rd_rst_i;
    assign wr_rst_busy   = fifo_wr_rst_i | fifo_rd_rst_wr_i;
    assign fifo_rst_active = fifo_wr_rst_i | fifo_wr_rst_d2 | fifo_rd_rst_wr_i;
    assign fifo_rst_done   = fifo_wr_rst_done & fifo_rd_rst_done;

  // synthesis translate_off
    if (SIM_ASSERT_CHK == 1) begin: assert_rst
      always @ (posedge wr_clk) begin
        assert (!$isunknown(rst)) else $warning ("Input port 'rst' has unknown value 'X' or 'Z' at %0t. This may cause the outputs of FIFO to be 'X' or 'Z' in simulation. Ensure 'rst' has a valid value ('0' or '1')",$time);
      end
    end : assert_rst

  // synthesis translate_on
    // Reset input is sampled by wr_clk and cleared by fifo_rst_done
    always @ (posedge wr_clk) begin
      if (rst_i && ~fifo_rst_active)
        fifo_wr_rst_i <= 1'b1;
      else if (fifo_wr_rst_i & fifo_rst_done)
        fifo_wr_rst_i <= 1'b0;
      else
        fifo_wr_rst_i <= fifo_wr_rst_i;
    end

    // fifo_wr_rst_done is generated by wr_clk and cleared by fifo_rst_done
    xpm_reg_pipe_bit #(2, 0)
      wrst_wr_inst (1'b0, wr_clk, fifo_wr_rst_i, fifo_wr_rst_d2);
    always @ (posedge wr_clk) begin
      fifo_wr_rst_d3 <= fifo_wr_rst_d2;
      if (~fifo_wr_rst_d3 & fifo_wr_rst_d2)
        fifo_wr_rst_done <= 1'b1;
      else if (fifo_rst_done)
        fifo_wr_rst_done <= 1'b0;
    end

    // Synchronize the wr_rst in read clock domain
    xpm_cdc_sync_rst #(
      .DEST_SYNC_FF      (CDC_DEST_SYNC_FF),
      .INIT              (0),
      .SIM_ASSERT_CHK    (1),
      .VERSION           (0))
      wrst_rd_inst (
        .src_rst         (fifo_wr_rst_i),
        .dest_clk        (rd_clk),
        .dest_rst        (fifo_rd_rst_i));

    // Ensure rd_rst at least 3 rd_clk (rd_rst_d3)
    xpm_reg_pipe_bit #(3, 0)
      rrst_rd_inst (1'b0, rd_clk, fifo_rd_rst_i, fifo_rd_rst_d3);

    // Synchronize the rd_rst_d3 in write clock domain
    xpm_cdc_sync_rst #(
      .DEST_SYNC_FF      (CDC_DEST_SYNC_FF),
      .INIT              (0),
      .SIM_ASSERT_CHK    (1),
      .VERSION           (0))
      rrst_wr_inst (
        .src_rst         (fifo_rd_rst_d3),
        .dest_clk        (wr_clk),
        .dest_rst        (fifo_rd_rst_wr_i));

    // fifo_rd_rst_done is generated by wr_clk and cleared by fifo_rst_done
    always @ (posedge wr_clk) begin
      fifo_rd_rst_d3_wr_d2 <= fifo_rd_rst_wr_i;
      if (~fifo_rd_rst_d3_wr_d2 & fifo_rd_rst_wr_i)
        fifo_rd_rst_done <= 1'b1;
      else if (fifo_rst_done)
        fifo_rd_rst_done <= 1'b0;
    end
  end : gen_rst_ic
endmodule : xpm_fifo_rst

//********************************************************************************************************************

//********************************************************************************************************************
// -------------------------------------------------------------------------------------------------------------------
// Up-Down Counter
// -------------------------------------------------------------------------------------------------------------------
//********************************************************************************************************************

module xpm_counter_updn # (
  parameter integer               COUNTER_WIDTH        = 4,
  parameter integer               RESET_VALUE          = 0

) (
  input  wire                     rst,
  input  wire                     clk,
  input  wire                     cnt_en,
  input  wire                     cnt_up,
  input  wire                     cnt_down,
  output wire [COUNTER_WIDTH-1:0] count_value
);
  reg [COUNTER_WIDTH-1:0]          count_value_i = RESET_VALUE;
  assign count_value = count_value_i;
  always @ (posedge clk) begin
    if (rst) begin
      count_value_i  <= RESET_VALUE;
    end else if (cnt_en) begin
      count_value_i  <= count_value_i + cnt_up - cnt_down;
    end
  end
endmodule : xpm_counter_updn

//********************************************************************************************************************
//********************************************************************************************************************

module xpm_fifo_reg_vec # (
  parameter integer           REG_WIDTH        = 4

) (
  input  wire                 rst,
  input  wire                 clk,
  input  wire [REG_WIDTH-1:0] reg_in,
  output wire  [REG_WIDTH-1:0] reg_out
);
  reg [REG_WIDTH-1:0] reg_out_i;
  always @ (posedge clk) begin
    if (rst)
      reg_out_i  <= {REG_WIDTH{1'b0}};
    else
      reg_out_i  <= reg_in;
  end
  assign reg_out = reg_out_i;
endmodule : xpm_fifo_reg_vec

//********************************************************************************************************************
//********************************************************************************************************************

module xpm_fifo_reg_bit # (
  parameter integer           RST_VALUE        = 0

) (
  input  wire  rst,
  input  wire  clk,
  input  wire  d_in,
  output reg   d_out = RST_VALUE
);
  always @ (posedge clk) begin
    if (rst)
      d_out  <= RST_VALUE;
    else
      d_out  <= d_in;
  end
endmodule : xpm_fifo_reg_bit
//********************************************************************************************************************
//********************************************************************************************************************

module xpm_reg_pipe_bit # (
  parameter integer           PIPE_STAGES      = 1,
  parameter integer           RST_VALUE        = 0

) (
  input  wire  rst,
  input  wire  clk,
  input  wire  pipe_in,
  output wire  pipe_out
);
  wire pipe_stage_ff [PIPE_STAGES:0];

  assign pipe_stage_ff[0] = pipe_in;

    for (genvar pipestage = 0; pipestage < PIPE_STAGES ;pipestage = pipestage + 1) begin : gen_pipe_bit
      xpm_fifo_reg_bit #(RST_VALUE)
        pipe_bit_inst (rst, clk, pipe_stage_ff[pipestage], pipe_stage_ff[pipestage+1]);
    end : gen_pipe_bit

  assign pipe_out = pipe_stage_ff[PIPE_STAGES];
endmodule : xpm_reg_pipe_bit
//********************************************************************************************************************
//********************************************************************************************************************


(* XPM_MODULE = "TRUE" *)
module xpm_fifo_sync # (

  // Common module parameters
  parameter                         FIFO_MEMORY_TYPE   = "BRAM",
  parameter                         ECC_MODE           = "NO_ECC",

  parameter integer                 FIFO_WRITE_DEPTH   = 2048,
  parameter integer                 WRITE_DATA_WIDTH   = 32,
  parameter integer                 WR_DATA_COUNT_WIDTH  = 10,
  parameter integer                 PROG_FULL_THRESH   = 10,
  parameter integer                 FULL_RESET_VALUE   = 0,

  parameter                         READ_MODE          = "STD",
  parameter integer                 FIFO_READ_LATENCY  = 1,
  parameter integer                 READ_DATA_WIDTH    = WRITE_DATA_WIDTH,
  parameter integer                 RD_DATA_COUNT_WIDTH  = 10,
  parameter integer                 PROG_EMPTY_THRESH  = 10,
  parameter                         DOUT_RESET_VALUE   = "0",

  parameter                         WAKEUP_TIME        = 0,
  parameter integer                 VERSION            = 0

) (

  // Common module ports
  input  wire                                  sleep,
  input  wire                                  rst,

  // Write Domain ports
  input  wire                                  wr_clk,
  input  wire                                  wr_en,
  input  wire [WRITE_DATA_WIDTH-1:0]           din,
  output wire                                  full,
  output wire                                  prog_full,
  output wire [WR_DATA_COUNT_WIDTH-1:0]        wr_data_count,
  output wire                                  overflow,
  output wire                                  wr_rst_busy,

  // Read Domain ports
  input  wire                                  rd_en,
  output wire [READ_DATA_WIDTH-1:0]            dout,
  output wire                                  empty,
  output wire                                  prog_empty,
  output wire [RD_DATA_COUNT_WIDTH-1:0]        rd_data_count,
  output wire                                  underflow,
  output wire                                  rd_rst_busy,

  // ECC Related ports
  input  wire                                  injectsbiterr,
  input  wire                                  injectdbiterr,
  output wire                                  sbiterr,
  output wire                                  dbiterr
);

  // Define local parameters for mapping with base file
  localparam integer P_FIFO_MEMORY_TYPE      = ( (FIFO_MEMORY_TYPE == "lutram"   || FIFO_MEMORY_TYPE == "LUTRAM"   || FIFO_MEMORY_TYPE == "distributed"   || FIFO_MEMORY_TYPE == "DISTRIBUTED"  ) ? 1 :
                                               ( (FIFO_MEMORY_TYPE == "bram" || FIFO_MEMORY_TYPE == "BRAM" || FIFO_MEMORY_TYPE == "block" || FIFO_MEMORY_TYPE == "BLOCK") ? 2 :
                                               ( (FIFO_MEMORY_TYPE == "uram" || FIFO_MEMORY_TYPE == "URAM" || FIFO_MEMORY_TYPE == "ultra" || FIFO_MEMORY_TYPE == "ULTRA") ? 3 :
                                               ( (FIFO_MEMORY_TYPE == "builtin"  || FIFO_MEMORY_TYPE == "BUILTIN" ) ? 4 : 0))));
  
  localparam integer P_COMMON_CLOCK          = 1;

  localparam integer P_ECC_MODE              = ( (ECC_MODE  == "no_ecc" || ECC_MODE  == "NO_ECC" ) ? 0 : 1);

  localparam integer P_READ_MODE             = ( (READ_MODE == "std"  || READ_MODE == "STD" ) ? 0 :
                                               ( (READ_MODE == "fwft" || READ_MODE == "FWFT") ? 1 : 2));

//  localparam integer P_WDC_TYPE              = ( (WRCOUNT_TYPE == "disable_wr_dc" || WRCOUNT_TYPE == "DISABLE_WR_DC" ) ? 0 :
//                                               ( (WRCOUNT_TYPE == "enable_wr_dc"  || WRCOUNT_TYPE == "ENABLE_WR_DC"  ) ? 1 : 2));
//
//  localparam integer P_RDC_TYPE              = ( (RDCOUNT_TYPE == "disable_rd_dc" || RDCOUNT_TYPE == "DISABLE_RD_DC" ) ? 0 :
//                                               ( (RDCOUNT_TYPE == "enable_rd_dc"  || RDCOUNT_TYPE == "ENABLE_RD_DC"  ) ? 1 : 2));

  localparam integer P_WAKEUP_TIME           = ( (WAKEUP_TIME == "disable_sleep"    || WAKEUP_TIME == "DISABLE_SLEEP"   ) ? 0 : 2);

  // -------------------------------------------------------------------------------------------------------------------
  // Generate the instantiation of the appropriate XPM module
  // -------------------------------------------------------------------------------------------------------------------
      assign rd_rst_busy = wr_rst_busy;
      xpm_fifo_base # (
        .COMMON_CLOCK        (P_COMMON_CLOCK      ),
        .FIFO_MEMORY_TYPE    (P_FIFO_MEMORY_TYPE  ),
        .ECC_MODE            (P_ECC_MODE          ),
        .FIFO_WRITE_DEPTH    (FIFO_WRITE_DEPTH    ),
        .WRITE_DATA_WIDTH    (WRITE_DATA_WIDTH    ),
        .WR_DATA_COUNT_WIDTH (WR_DATA_COUNT_WIDTH ),
        .PROG_FULL_THRESH    (PROG_FULL_THRESH    ),
        .FULL_RESET_VALUE    (FULL_RESET_VALUE    ),
        .READ_MODE           (P_READ_MODE         ),
        .FIFO_READ_LATENCY   (FIFO_READ_LATENCY   ),
        .READ_DATA_WIDTH     (READ_DATA_WIDTH     ),
        .RD_DATA_COUNT_WIDTH (RD_DATA_COUNT_WIDTH ),
        .PROG_EMPTY_THRESH   (PROG_EMPTY_THRESH   ),
        .DOUT_RESET_VALUE    (DOUT_RESET_VALUE    ),
        .CDC_DEST_SYNC_FF    (2                   ),
        .REMOVE_WR_RD_PROT_LOGIC    (0            ),
        .WAKEUP_TIME         (WAKEUP_TIME         ),
        .VERSION             (VERSION             )

      ) xpm_fifo_base_inst (
        .sleep            (sleep),
        .rst              (rst),
        .wr_clk           (wr_clk),
        .wr_en            (wr_en),
        .din              (din),
        .full             (full),
        .prog_full        (prog_full),
        .wr_data_count    (wr_data_count),
        .overflow         (overflow),
        .wr_rst_busy      (wr_rst_busy),
        .rd_clk           (wr_clk),
        .rd_en            (rd_en),
        .dout             (dout),
        .empty            (empty),
        .prog_empty       (prog_empty),
        .rd_data_count    (rd_data_count),
        .underflow        (underflow),
        .rd_rst_busy      (),
        .injectsbiterr    (injectsbiterr),
        .injectdbiterr    (injectdbiterr),
        .sbiterr          (sbiterr),
        .dbiterr          (dbiterr)
      );

endmodule : xpm_fifo_sync

//********************************************************************************************************************
//********************************************************************************************************************
//********************************************************************************************************************


(* XPM_MODULE = "TRUE" *)
module xpm_fifo_async # (

  // Common module parameters
  parameter                         FIFO_MEMORY_TYPE   = "BRAM",
  parameter                         ECC_MODE           = "NO_ECC",
  parameter integer                 RELATED_CLOCKS     = 0,

  parameter integer                 FIFO_WRITE_DEPTH   = 2048,
  parameter integer                 WRITE_DATA_WIDTH   = 32,
  parameter integer                 WR_DATA_COUNT_WIDTH  = 10,
  parameter integer                 PROG_FULL_THRESH   = 10,
  parameter integer                 FULL_RESET_VALUE   = 0,

  parameter                         READ_MODE          = "STD",
  parameter integer                 FIFO_READ_LATENCY  = 1,
  parameter integer                 READ_DATA_WIDTH    = WRITE_DATA_WIDTH,
  parameter integer                 RD_DATA_COUNT_WIDTH  = 10,
  parameter integer                 PROG_EMPTY_THRESH  = 10,
  parameter                         DOUT_RESET_VALUE   = "0",
  parameter integer                 CDC_SYNC_STAGES    = 2,

  parameter                         WAKEUP_TIME        = 0,
  parameter integer                 VERSION            = 0

) (

  // Common module ports
  input  wire                                         sleep,
  input  wire                                         rst,

  // Write Domain ports
  input  wire                                         wr_clk,
  input  wire                                         wr_en,
  input  wire [WRITE_DATA_WIDTH-1:0]                  din,
  output wire                                         full,
  output wire                                         prog_full,
  output wire [WR_DATA_COUNT_WIDTH-1:0]               wr_data_count,
  output wire                                         overflow,
  output wire                                         wr_rst_busy,

  // Read Domain ports
  input  wire                                         rd_clk,
  input  wire                                         rd_en,
  output wire [READ_DATA_WIDTH-1:0]                   dout,
  output wire                                         empty,
  output wire                                         prog_empty,
  output wire [RD_DATA_COUNT_WIDTH-1:0]               rd_data_count,
  output wire                                         underflow,
  output wire                                         rd_rst_busy,

  // ECC Related ports
  input  wire                                         injectsbiterr,
  input  wire                                         injectdbiterr,
  output wire                                         sbiterr,
  output wire                                         dbiterr
);

  // Define local parameters for mapping with base file
  localparam integer P_FIFO_MEMORY_TYPE      = ( (FIFO_MEMORY_TYPE == "lutram"   || FIFO_MEMORY_TYPE == "LUTRAM"   || FIFO_MEMORY_TYPE == "distributed"   || FIFO_MEMORY_TYPE == "DISTRIBUTED"  ) ? 1 :
                                               ( (FIFO_MEMORY_TYPE == "bram" || FIFO_MEMORY_TYPE == "BRAM" || FIFO_MEMORY_TYPE == "block" || FIFO_MEMORY_TYPE == "BLOCK") ? 2 :
                                               ( (FIFO_MEMORY_TYPE == "uram" || FIFO_MEMORY_TYPE == "URAM" || FIFO_MEMORY_TYPE == "ultra" || FIFO_MEMORY_TYPE == "ULTRA") ? 3 :
                                               ( (FIFO_MEMORY_TYPE == "builtin"  || FIFO_MEMORY_TYPE == "BUILTIN" ) ? 4 : 0))));
  
  localparam integer P_COMMON_CLOCK          = 0;

  localparam integer P_ECC_MODE              = ( (ECC_MODE  == "no_ecc" || ECC_MODE  == "NO_ECC" ) ? 0 : 1);

  localparam integer P_READ_MODE             = ( (READ_MODE == "std"  || READ_MODE == "STD" ) ? 0 :
                                               ( (READ_MODE == "fwft" || READ_MODE == "FWFT") ? 1 : 2));

//  localparam integer P_WDC_TYPE              = ( (WRCOUNT_TYPE == "disable_wr_dc" || WRCOUNT_TYPE == "DISABLE_WR_DC" ) ? 0 :
//                                               ( (WRCOUNT_TYPE == "enable_wr_dc"  || WRCOUNT_TYPE == "ENABLE_WR_DC"  ) ? 1 : 2));
//
//  localparam integer P_RDC_TYPE              = ( (RDCOUNT_TYPE == "disable_rd_dc" || RDCOUNT_TYPE == "DISABLE_RD_DC" ) ? 0 :
//                                               ( (RDCOUNT_TYPE == "enable_rd_dc"  || RDCOUNT_TYPE == "ENABLE_RD_DC"  ) ? 1 : 2));
//
  localparam integer P_WAKEUP_TIME           = ( (WAKEUP_TIME == "disable_sleep"    || WAKEUP_TIME == "DISABLE_SLEEP"   ) ? 0 : 2);

  // -------------------------------------------------------------------------------------------------------------------
  // Generate the instantiation of the appropriate XPM module
  // -------------------------------------------------------------------------------------------------------------------
      xpm_fifo_base # (
        .COMMON_CLOCK        (P_COMMON_CLOCK      ),
        .RELATED_CLOCKS      (RELATED_CLOCKS      ),
        .FIFO_MEMORY_TYPE    (P_FIFO_MEMORY_TYPE  ),
        .ECC_MODE            (P_ECC_MODE          ),
        .FIFO_WRITE_DEPTH    (FIFO_WRITE_DEPTH    ),
        .WRITE_DATA_WIDTH    (WRITE_DATA_WIDTH    ),
        .WR_DATA_COUNT_WIDTH (WR_DATA_COUNT_WIDTH ),
        .PROG_FULL_THRESH    (PROG_FULL_THRESH    ),
        .FULL_RESET_VALUE    (FULL_RESET_VALUE    ),
        .READ_MODE           (P_READ_MODE         ),
        .FIFO_READ_LATENCY   (FIFO_READ_LATENCY   ),
        .READ_DATA_WIDTH     (READ_DATA_WIDTH     ),
        .RD_DATA_COUNT_WIDTH (RD_DATA_COUNT_WIDTH ),
        .PROG_EMPTY_THRESH   (PROG_EMPTY_THRESH   ),
        .DOUT_RESET_VALUE    (DOUT_RESET_VALUE    ),
        .CDC_DEST_SYNC_FF    (CDC_SYNC_STAGES     ),
        .REMOVE_WR_RD_PROT_LOGIC    (0            ),
        .WAKEUP_TIME         (WAKEUP_TIME         ),
        .VERSION             (VERSION             )

      ) xpm_fifo_base_inst (
        .sleep            (sleep),
        .rst              (rst),
        .wr_clk           (wr_clk),
        .wr_en            (wr_en),
        .din              (din),
        .full             (full),
        .prog_full        (prog_full),
        .wr_data_count    (wr_data_count),
        .overflow         (overflow),
        .wr_rst_busy      (wr_rst_busy),
        .rd_clk           (rd_clk),
        .rd_en            (rd_en),
        .dout             (dout),
        .empty            (empty),
        .prog_empty       (prog_empty),
        .rd_data_count    (rd_data_count),
        .underflow        (underflow),
        .rd_rst_busy      (rd_rst_busy),
        .injectsbiterr    (injectsbiterr),
        .injectdbiterr    (injectdbiterr),
        .sbiterr          (sbiterr),
        .dbiterr          (dbiterr)
      );

endmodule : xpm_fifo_async
`default_nettype wire
