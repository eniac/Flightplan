--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.1_sdx (lin64) Build 1915620 Thu Jun 22 17:54:59 MDT 2017
--Date        : Wed Sep 19 16:12:51 2018
--Host        : hactar running 64-bit Ubuntu 16.04.4 LTS
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    gt_rtl_grx_n : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gt_rtl_grx_p : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gt_rtl_gtx_n : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gt_rtl_gtx_p : out STD_LOGIC_VECTOR ( 1 downto 0 );
    sfp_tx_dis : out STD_LOGIC_VECTOR ( 1 downto 0 );
    user_si570_sysclk_clk_n : in STD_LOGIC;
    user_si570_sysclk_clk_p : in STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    gt_rtl_grx_n : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gt_rtl_grx_p : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gt_rtl_gtx_n : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gt_rtl_gtx_p : out STD_LOGIC_VECTOR ( 1 downto 0 );
    sfp_tx_dis : out STD_LOGIC_VECTOR ( 1 downto 0 );
    user_si570_sysclk_clk_n : in STD_LOGIC;
    user_si570_sysclk_clk_p : in STD_LOGIC
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      gt_rtl_grx_n(1 downto 0) => gt_rtl_grx_n(1 downto 0),
      gt_rtl_grx_p(1 downto 0) => gt_rtl_grx_p(1 downto 0),
      gt_rtl_gtx_n(1 downto 0) => gt_rtl_gtx_n(1 downto 0),
      gt_rtl_gtx_p(1 downto 0) => gt_rtl_gtx_p(1 downto 0),
      sfp_tx_dis(1 downto 0) => sfp_tx_dis(1 downto 0),
      user_si570_sysclk_clk_n => user_si570_sysclk_clk_n,
      user_si570_sysclk_clk_p => user_si570_sysclk_clk_p
    );
end STRUCTURE;
