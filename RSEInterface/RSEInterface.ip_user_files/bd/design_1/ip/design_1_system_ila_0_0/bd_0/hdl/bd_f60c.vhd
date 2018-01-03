--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.1_sdx (lin64) Build 1915620 Thu Jun 22 17:54:59 MDT 2017
--Date        : Tue Jan  2 16:45:39 2018
--Host        : lenovo-laptop running 64-bit Ubuntu 16.04.3 LTS
--Command     : generate_target bd_f60c.bd
--Design      : bd_f60c
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_f60c is
  port (
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    SLOT_0_AXIS_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    SLOT_0_AXIS_tvalid : in STD_LOGIC;
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    resetn : in STD_LOGIC
  );
  attribute core_generation_info : string;
  attribute core_generation_info of bd_f60c : entity is "bd_f60c,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_f60c,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=SBD,synth_mode=OOC_per_IP}";
  attribute hw_handoff : string;
  attribute hw_handoff of bd_f60c : entity is "design_1_system_ila_0_0.hwdef";
end bd_f60c;

architecture STRUCTURE of bd_f60c is
  component bd_f60c_ila_lib_0 is
  port (
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe3 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe6 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe7 : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component bd_f60c_ila_lib_0;
  component bd_f60c_g_inst_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    slot_0_axis_tvalid : in STD_LOGIC;
    slot_0_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    slot_0_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    slot_0_axis_tlast : in STD_LOGIC;
    slot_0_axis_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_slot_0_axis_tvalid : out STD_LOGIC;
    m_slot_0_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_slot_0_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_slot_0_axis_tlast : out STD_LOGIC;
    m_slot_0_axis_tuser : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component bd_f60c_g_inst_0;
  signal Conn_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal Conn_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn_TLAST : STD_LOGIC;
  signal Conn_TUSER : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn_TVALID : STD_LOGIC;
  signal clk_1 : STD_LOGIC;
  signal net_slot_0_axis_tdata : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal net_slot_0_axis_tkeep : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal net_slot_0_axis_tlast : STD_LOGIC;
  signal net_slot_0_axis_tuser : STD_LOGIC_VECTOR ( 0 to 0 );
  signal net_slot_0_axis_tvalid : STD_LOGIC;
  signal probe0_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal probe1_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal probe2_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal resetn_1 : STD_LOGIC;
begin
  Conn_TDATA(63 downto 0) <= SLOT_0_AXIS_tdata(63 downto 0);
  Conn_TKEEP(7 downto 0) <= SLOT_0_AXIS_tkeep(7 downto 0);
  Conn_TLAST <= SLOT_0_AXIS_tlast;
  Conn_TUSER(0) <= SLOT_0_AXIS_tuser(0);
  Conn_TVALID <= SLOT_0_AXIS_tvalid;
  clk_1 <= clk;
  probe0_1(0) <= probe0(0);
  probe1_1(0) <= probe1(0);
  probe2_1(0) <= probe2(0);
  resetn_1 <= resetn;
g_inst: component bd_f60c_g_inst_0
     port map (
      aclk => clk_1,
      aresetn => resetn_1,
      m_slot_0_axis_tdata(63 downto 0) => net_slot_0_axis_tdata(63 downto 0),
      m_slot_0_axis_tkeep(7 downto 0) => net_slot_0_axis_tkeep(7 downto 0),
      m_slot_0_axis_tlast => net_slot_0_axis_tlast,
      m_slot_0_axis_tuser(0) => net_slot_0_axis_tuser(0),
      m_slot_0_axis_tvalid => net_slot_0_axis_tvalid,
      slot_0_axis_tdata(63 downto 0) => Conn_TDATA(63 downto 0),
      slot_0_axis_tkeep(7 downto 0) => Conn_TKEEP(7 downto 0),
      slot_0_axis_tlast => Conn_TLAST,
      slot_0_axis_tuser(0) => Conn_TUSER(0),
      slot_0_axis_tvalid => Conn_TVALID
    );
ila_lib: component bd_f60c_ila_lib_0
     port map (
      clk => clk_1,
      probe0(0) => probe0_1(0),
      probe1(0) => probe1_1(0),
      probe2(0) => probe2_1(0),
      probe3(63 downto 0) => net_slot_0_axis_tdata(63 downto 0),
      probe4(7 downto 0) => net_slot_0_axis_tkeep(7 downto 0),
      probe5(0) => net_slot_0_axis_tuser(0),
      probe6(0) => net_slot_0_axis_tvalid,
      probe7(0) => net_slot_0_axis_tlast
    );
end STRUCTURE;
