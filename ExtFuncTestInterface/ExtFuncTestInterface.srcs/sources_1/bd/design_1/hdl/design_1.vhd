--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.1_sdx (lin64) Build 1915620 Thu Jun 22 17:54:59 MDT 2017
--Date        : Tue Jan  9 14:56:30 2018
--Host        : lenovo-laptop running 64-bit Ubuntu 16.04.3 LTS
--Command     : generate_target design_1.bd
--Design      : design_1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity s00_couplers_imp_1LLE45P is
  port (
    M_AXIS_ACLK : in STD_LOGIC;
    M_AXIS_ARESETN : in STD_LOGIC;
    M_AXIS_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M_AXIS_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXIS_tlast : out STD_LOGIC;
    M_AXIS_tready : in STD_LOGIC;
    M_AXIS_tvalid : out STD_LOGIC;
    S_AXIS_ACLK : in STD_LOGIC;
    S_AXIS_ARESETN : in STD_LOGIC;
    S_AXIS_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXIS_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXIS_tlast : in STD_LOGIC;
    S_AXIS_tuser : in STD_LOGIC;
    S_AXIS_tvalid : in STD_LOGIC
  );
end s00_couplers_imp_1LLE45P;

architecture STRUCTURE of s00_couplers_imp_1LLE45P is
  component design_1_auto_ss_si_r_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    transfer_dropped : out STD_LOGIC
  );
  end component design_1_auto_ss_si_r_0;
  component design_1_auto_cc_0 is
  port (
    s_axis_aresetn : in STD_LOGIC;
    m_axis_aresetn : in STD_LOGIC;
    s_axis_aclk : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_aclk : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tuser : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_auto_cc_0;
  component design_1_auto_ss_u_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC
  );
  end component design_1_auto_ss_u_0;
  signal M_AXIS_ACLK_1 : STD_LOGIC;
  signal M_AXIS_ARESETN_1 : STD_LOGIC;
  signal S_AXIS_ACLK_1 : STD_LOGIC;
  signal S_AXIS_ARESETN_1 : STD_LOGIC;
  signal auto_cc_to_auto_ss_u_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal auto_cc_to_auto_ss_u_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_cc_to_auto_ss_u_TLAST : STD_LOGIC;
  signal auto_cc_to_auto_ss_u_TREADY : STD_LOGIC;
  signal auto_cc_to_auto_ss_u_TUSER : STD_LOGIC_VECTOR ( 0 to 0 );
  signal auto_cc_to_auto_ss_u_TVALID : STD_LOGIC;
  signal auto_ss_si_r_to_auto_cc_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal auto_ss_si_r_to_auto_cc_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_ss_si_r_to_auto_cc_TLAST : STD_LOGIC;
  signal auto_ss_si_r_to_auto_cc_TREADY : STD_LOGIC;
  signal auto_ss_si_r_to_auto_cc_TUSER : STD_LOGIC_VECTOR ( 0 to 0 );
  signal auto_ss_si_r_to_auto_cc_TVALID : STD_LOGIC;
  signal auto_ss_u_to_s00_couplers_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal auto_ss_u_to_s00_couplers_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_ss_u_to_s00_couplers_TLAST : STD_LOGIC;
  signal auto_ss_u_to_s00_couplers_TREADY : STD_LOGIC;
  signal auto_ss_u_to_s00_couplers_TVALID : STD_LOGIC;
  signal s00_couplers_to_auto_ss_si_r_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal s00_couplers_to_auto_ss_si_r_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s00_couplers_to_auto_ss_si_r_TLAST : STD_LOGIC;
  signal s00_couplers_to_auto_ss_si_r_TUSER : STD_LOGIC;
  signal s00_couplers_to_auto_ss_si_r_TVALID : STD_LOGIC;
  signal NLW_auto_ss_si_r_transfer_dropped_UNCONNECTED : STD_LOGIC;
begin
  M_AXIS_ACLK_1 <= M_AXIS_ACLK;
  M_AXIS_ARESETN_1 <= M_AXIS_ARESETN;
  M_AXIS_tdata(63 downto 0) <= auto_ss_u_to_s00_couplers_TDATA(63 downto 0);
  M_AXIS_tkeep(7 downto 0) <= auto_ss_u_to_s00_couplers_TKEEP(7 downto 0);
  M_AXIS_tlast <= auto_ss_u_to_s00_couplers_TLAST;
  M_AXIS_tvalid <= auto_ss_u_to_s00_couplers_TVALID;
  S_AXIS_ACLK_1 <= S_AXIS_ACLK;
  S_AXIS_ARESETN_1 <= S_AXIS_ARESETN;
  auto_ss_u_to_s00_couplers_TREADY <= M_AXIS_tready;
  s00_couplers_to_auto_ss_si_r_TDATA(63 downto 0) <= S_AXIS_tdata(63 downto 0);
  s00_couplers_to_auto_ss_si_r_TKEEP(7 downto 0) <= S_AXIS_tkeep(7 downto 0);
  s00_couplers_to_auto_ss_si_r_TLAST <= S_AXIS_tlast;
  s00_couplers_to_auto_ss_si_r_TUSER <= S_AXIS_tuser;
  s00_couplers_to_auto_ss_si_r_TVALID <= S_AXIS_tvalid;
auto_cc: component design_1_auto_cc_0
     port map (
      m_axis_aclk => M_AXIS_ACLK_1,
      m_axis_aresetn => M_AXIS_ARESETN_1,
      m_axis_tdata(63 downto 0) => auto_cc_to_auto_ss_u_TDATA(63 downto 0),
      m_axis_tkeep(7 downto 0) => auto_cc_to_auto_ss_u_TKEEP(7 downto 0),
      m_axis_tlast => auto_cc_to_auto_ss_u_TLAST,
      m_axis_tready => auto_cc_to_auto_ss_u_TREADY,
      m_axis_tuser(0) => auto_cc_to_auto_ss_u_TUSER(0),
      m_axis_tvalid => auto_cc_to_auto_ss_u_TVALID,
      s_axis_aclk => S_AXIS_ACLK_1,
      s_axis_aresetn => S_AXIS_ARESETN_1,
      s_axis_tdata(63 downto 0) => auto_ss_si_r_to_auto_cc_TDATA(63 downto 0),
      s_axis_tkeep(7 downto 0) => auto_ss_si_r_to_auto_cc_TKEEP(7 downto 0),
      s_axis_tlast => auto_ss_si_r_to_auto_cc_TLAST,
      s_axis_tready => auto_ss_si_r_to_auto_cc_TREADY,
      s_axis_tuser(0) => auto_ss_si_r_to_auto_cc_TUSER(0),
      s_axis_tvalid => auto_ss_si_r_to_auto_cc_TVALID
    );
auto_ss_si_r: component design_1_auto_ss_si_r_0
     port map (
      aclk => S_AXIS_ACLK_1,
      aresetn => S_AXIS_ARESETN_1,
      m_axis_tdata(63 downto 0) => auto_ss_si_r_to_auto_cc_TDATA(63 downto 0),
      m_axis_tkeep(7 downto 0) => auto_ss_si_r_to_auto_cc_TKEEP(7 downto 0),
      m_axis_tlast => auto_ss_si_r_to_auto_cc_TLAST,
      m_axis_tready => auto_ss_si_r_to_auto_cc_TREADY,
      m_axis_tuser(0) => auto_ss_si_r_to_auto_cc_TUSER(0),
      m_axis_tvalid => auto_ss_si_r_to_auto_cc_TVALID,
      s_axis_tdata(63 downto 0) => s00_couplers_to_auto_ss_si_r_TDATA(63 downto 0),
      s_axis_tkeep(7 downto 0) => s00_couplers_to_auto_ss_si_r_TKEEP(7 downto 0),
      s_axis_tlast => s00_couplers_to_auto_ss_si_r_TLAST,
      s_axis_tuser(0) => s00_couplers_to_auto_ss_si_r_TUSER,
      s_axis_tvalid => s00_couplers_to_auto_ss_si_r_TVALID,
      transfer_dropped => NLW_auto_ss_si_r_transfer_dropped_UNCONNECTED
    );
auto_ss_u: component design_1_auto_ss_u_0
     port map (
      aclk => M_AXIS_ACLK_1,
      aresetn => M_AXIS_ARESETN_1,
      m_axis_tdata(63 downto 0) => auto_ss_u_to_s00_couplers_TDATA(63 downto 0),
      m_axis_tkeep(7 downto 0) => auto_ss_u_to_s00_couplers_TKEEP(7 downto 0),
      m_axis_tlast => auto_ss_u_to_s00_couplers_TLAST,
      m_axis_tready => auto_ss_u_to_s00_couplers_TREADY,
      m_axis_tvalid => auto_ss_u_to_s00_couplers_TVALID,
      s_axis_tdata(63 downto 0) => auto_cc_to_auto_ss_u_TDATA(63 downto 0),
      s_axis_tkeep(7 downto 0) => auto_cc_to_auto_ss_u_TKEEP(7 downto 0),
      s_axis_tlast => auto_cc_to_auto_ss_u_TLAST,
      s_axis_tready => auto_cc_to_auto_ss_u_TREADY,
      s_axis_tuser(0) => auto_cc_to_auto_ss_u_TUSER(0),
      s_axis_tvalid => auto_cc_to_auto_ss_u_TVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity s00_couplers_imp_1O4UG5P is
  port (
    M_AXIS_ACLK : in STD_LOGIC;
    M_AXIS_ARESETN : in STD_LOGIC;
    M_AXIS_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M_AXIS_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXIS_tlast : out STD_LOGIC;
    M_AXIS_tready : in STD_LOGIC;
    M_AXIS_tuser : out STD_LOGIC;
    M_AXIS_tvalid : out STD_LOGIC;
    S_AXIS_ACLK : in STD_LOGIC;
    S_AXIS_ARESETN : in STD_LOGIC;
    S_AXIS_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXIS_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXIS_tlast : in STD_LOGIC;
    S_AXIS_tready : out STD_LOGIC;
    S_AXIS_tvalid : in STD_LOGIC
  );
end s00_couplers_imp_1O4UG5P;

architecture STRUCTURE of s00_couplers_imp_1O4UG5P is
  component design_1_auto_cc_1 is
  port (
    s_axis_aresetn : in STD_LOGIC;
    m_axis_aresetn : in STD_LOGIC;
    s_axis_aclk : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    m_axis_aclk : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC
  );
  end component design_1_auto_cc_1;
  component design_1_auto_ss_u_1 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tuser : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_auto_ss_u_1;
  signal M_AXIS_ACLK_1 : STD_LOGIC;
  signal M_AXIS_ARESETN_1 : STD_LOGIC;
  signal S_AXIS_ACLK_1 : STD_LOGIC;
  signal S_AXIS_ARESETN_1 : STD_LOGIC;
  signal auto_cc_to_auto_ss_u_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal auto_cc_to_auto_ss_u_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_cc_to_auto_ss_u_TLAST : STD_LOGIC;
  signal auto_cc_to_auto_ss_u_TREADY : STD_LOGIC;
  signal auto_cc_to_auto_ss_u_TVALID : STD_LOGIC;
  signal auto_ss_u_to_s00_couplers_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal auto_ss_u_to_s00_couplers_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_ss_u_to_s00_couplers_TLAST : STD_LOGIC;
  signal auto_ss_u_to_s00_couplers_TREADY : STD_LOGIC;
  signal auto_ss_u_to_s00_couplers_TUSER : STD_LOGIC_VECTOR ( 0 to 0 );
  signal auto_ss_u_to_s00_couplers_TVALID : STD_LOGIC;
  signal s00_couplers_to_auto_cc_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal s00_couplers_to_auto_cc_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s00_couplers_to_auto_cc_TLAST : STD_LOGIC;
  signal s00_couplers_to_auto_cc_TREADY : STD_LOGIC;
  signal s00_couplers_to_auto_cc_TVALID : STD_LOGIC;
begin
  M_AXIS_ACLK_1 <= M_AXIS_ACLK;
  M_AXIS_ARESETN_1 <= M_AXIS_ARESETN;
  M_AXIS_tdata(63 downto 0) <= auto_ss_u_to_s00_couplers_TDATA(63 downto 0);
  M_AXIS_tkeep(7 downto 0) <= auto_ss_u_to_s00_couplers_TKEEP(7 downto 0);
  M_AXIS_tlast <= auto_ss_u_to_s00_couplers_TLAST;
  M_AXIS_tuser <= auto_ss_u_to_s00_couplers_TUSER(0);
  M_AXIS_tvalid <= auto_ss_u_to_s00_couplers_TVALID;
  S_AXIS_ACLK_1 <= S_AXIS_ACLK;
  S_AXIS_ARESETN_1 <= S_AXIS_ARESETN;
  S_AXIS_tready <= s00_couplers_to_auto_cc_TREADY;
  auto_ss_u_to_s00_couplers_TREADY <= M_AXIS_tready;
  s00_couplers_to_auto_cc_TDATA(63 downto 0) <= S_AXIS_tdata(63 downto 0);
  s00_couplers_to_auto_cc_TKEEP(7 downto 0) <= S_AXIS_tkeep(7 downto 0);
  s00_couplers_to_auto_cc_TLAST <= S_AXIS_tlast;
  s00_couplers_to_auto_cc_TVALID <= S_AXIS_tvalid;
auto_cc: component design_1_auto_cc_1
     port map (
      m_axis_aclk => M_AXIS_ACLK_1,
      m_axis_aresetn => M_AXIS_ARESETN_1,
      m_axis_tdata(63 downto 0) => auto_cc_to_auto_ss_u_TDATA(63 downto 0),
      m_axis_tkeep(7 downto 0) => auto_cc_to_auto_ss_u_TKEEP(7 downto 0),
      m_axis_tlast => auto_cc_to_auto_ss_u_TLAST,
      m_axis_tready => auto_cc_to_auto_ss_u_TREADY,
      m_axis_tvalid => auto_cc_to_auto_ss_u_TVALID,
      s_axis_aclk => S_AXIS_ACLK_1,
      s_axis_aresetn => S_AXIS_ARESETN_1,
      s_axis_tdata(63 downto 0) => s00_couplers_to_auto_cc_TDATA(63 downto 0),
      s_axis_tkeep(7 downto 0) => s00_couplers_to_auto_cc_TKEEP(7 downto 0),
      s_axis_tlast => s00_couplers_to_auto_cc_TLAST,
      s_axis_tready => s00_couplers_to_auto_cc_TREADY,
      s_axis_tvalid => s00_couplers_to_auto_cc_TVALID
    );
auto_ss_u: component design_1_auto_ss_u_1
     port map (
      aclk => M_AXIS_ACLK_1,
      aresetn => M_AXIS_ARESETN_1,
      m_axis_tdata(63 downto 0) => auto_ss_u_to_s00_couplers_TDATA(63 downto 0),
      m_axis_tkeep(7 downto 0) => auto_ss_u_to_s00_couplers_TKEEP(7 downto 0),
      m_axis_tlast => auto_ss_u_to_s00_couplers_TLAST,
      m_axis_tready => auto_ss_u_to_s00_couplers_TREADY,
      m_axis_tuser(0) => auto_ss_u_to_s00_couplers_TUSER(0),
      m_axis_tvalid => auto_ss_u_to_s00_couplers_TVALID,
      s_axis_tdata(63 downto 0) => auto_cc_to_auto_ss_u_TDATA(63 downto 0),
      s_axis_tkeep(7 downto 0) => auto_cc_to_auto_ss_u_TKEEP(7 downto 0),
      s_axis_tlast => auto_cc_to_auto_ss_u_TLAST,
      s_axis_tready => auto_cc_to_auto_ss_u_TREADY,
      s_axis_tvalid => auto_cc_to_auto_ss_u_TVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity s00_couplers_imp_O7FAN0 is
  port (
    M_ACLK : in STD_LOGIC;
    M_ARESETN : in STD_LOGIC;
    M_AXI_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    M_AXI_arready : in STD_LOGIC;
    M_AXI_arvalid : out STD_LOGIC;
    M_AXI_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    M_AXI_awready : in STD_LOGIC;
    M_AXI_awvalid : out STD_LOGIC;
    M_AXI_bready : out STD_LOGIC;
    M_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_bvalid : in STD_LOGIC;
    M_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_rready : out STD_LOGIC;
    M_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_rvalid : in STD_LOGIC;
    M_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_wready : in STD_LOGIC;
    M_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_wvalid : out STD_LOGIC;
    S_ACLK : in STD_LOGIC;
    S_ARESETN : in STD_LOGIC;
    S_AXI_araddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    S_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_arid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_arlock : in STD_LOGIC;
    S_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_arready : out STD_LOGIC;
    S_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_arvalid : in STD_LOGIC;
    S_AXI_awaddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    S_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_awid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_awlock : in STD_LOGIC;
    S_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_awready : out STD_LOGIC;
    S_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_awvalid : in STD_LOGIC;
    S_AXI_bid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_bready : in STD_LOGIC;
    S_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_bvalid : out STD_LOGIC;
    S_AXI_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    S_AXI_rid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_rlast : out STD_LOGIC;
    S_AXI_rready : in STD_LOGIC;
    S_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_rvalid : out STD_LOGIC;
    S_AXI_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    S_AXI_wlast : in STD_LOGIC;
    S_AXI_wready : out STD_LOGIC;
    S_AXI_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_wvalid : in STD_LOGIC
  );
end s00_couplers_imp_O7FAN0;

architecture STRUCTURE of s00_couplers_imp_O7FAN0 is
  component design_1_auto_ds_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wlast : out STD_LOGIC;
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rlast : in STD_LOGIC;
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC
  );
  end component design_1_auto_ds_0;
  component design_1_auto_pc_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC
  );
  end component design_1_auto_pc_0;
  signal S_ACLK_1 : STD_LOGIC;
  signal S_ARESETN_1 : STD_LOGIC;
  signal auto_ds_to_auto_pc_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal auto_ds_to_auto_pc_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal auto_ds_to_auto_pc_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_ds_to_auto_pc_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal auto_ds_to_auto_pc_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal auto_ds_to_auto_pc_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_ARREADY : STD_LOGIC;
  signal auto_ds_to_auto_pc_ARREGION : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal auto_ds_to_auto_pc_ARVALID : STD_LOGIC;
  signal auto_ds_to_auto_pc_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal auto_ds_to_auto_pc_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal auto_ds_to_auto_pc_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal auto_ds_to_auto_pc_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal auto_ds_to_auto_pc_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal auto_ds_to_auto_pc_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_AWREADY : STD_LOGIC;
  signal auto_ds_to_auto_pc_AWREGION : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal auto_ds_to_auto_pc_AWVALID : STD_LOGIC;
  signal auto_ds_to_auto_pc_BREADY : STD_LOGIC;
  signal auto_ds_to_auto_pc_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal auto_ds_to_auto_pc_BVALID : STD_LOGIC;
  signal auto_ds_to_auto_pc_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal auto_ds_to_auto_pc_RLAST : STD_LOGIC;
  signal auto_ds_to_auto_pc_RREADY : STD_LOGIC;
  signal auto_ds_to_auto_pc_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal auto_ds_to_auto_pc_RVALID : STD_LOGIC;
  signal auto_ds_to_auto_pc_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal auto_ds_to_auto_pc_WLAST : STD_LOGIC;
  signal auto_ds_to_auto_pc_WREADY : STD_LOGIC;
  signal auto_ds_to_auto_pc_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_ds_to_auto_pc_WVALID : STD_LOGIC;
  signal auto_pc_to_s00_couplers_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal auto_pc_to_s00_couplers_ARREADY : STD_LOGIC;
  signal auto_pc_to_s00_couplers_ARVALID : STD_LOGIC;
  signal auto_pc_to_s00_couplers_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal auto_pc_to_s00_couplers_AWREADY : STD_LOGIC;
  signal auto_pc_to_s00_couplers_AWVALID : STD_LOGIC;
  signal auto_pc_to_s00_couplers_BREADY : STD_LOGIC;
  signal auto_pc_to_s00_couplers_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal auto_pc_to_s00_couplers_BVALID : STD_LOGIC;
  signal auto_pc_to_s00_couplers_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal auto_pc_to_s00_couplers_RREADY : STD_LOGIC;
  signal auto_pc_to_s00_couplers_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal auto_pc_to_s00_couplers_RVALID : STD_LOGIC;
  signal auto_pc_to_s00_couplers_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal auto_pc_to_s00_couplers_WREADY : STD_LOGIC;
  signal auto_pc_to_s00_couplers_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal auto_pc_to_s00_couplers_WVALID : STD_LOGIC;
  signal s00_couplers_to_auto_ds_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal s00_couplers_to_auto_ds_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_auto_ds_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s00_couplers_to_auto_ds_ARID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s00_couplers_to_auto_ds_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s00_couplers_to_auto_ds_ARLOCK : STD_LOGIC;
  signal s00_couplers_to_auto_ds_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s00_couplers_to_auto_ds_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s00_couplers_to_auto_ds_ARREADY : STD_LOGIC;
  signal s00_couplers_to_auto_ds_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s00_couplers_to_auto_ds_ARVALID : STD_LOGIC;
  signal s00_couplers_to_auto_ds_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal s00_couplers_to_auto_ds_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_auto_ds_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s00_couplers_to_auto_ds_AWID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s00_couplers_to_auto_ds_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s00_couplers_to_auto_ds_AWLOCK : STD_LOGIC;
  signal s00_couplers_to_auto_ds_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s00_couplers_to_auto_ds_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s00_couplers_to_auto_ds_AWREADY : STD_LOGIC;
  signal s00_couplers_to_auto_ds_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s00_couplers_to_auto_ds_AWVALID : STD_LOGIC;
  signal s00_couplers_to_auto_ds_BID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s00_couplers_to_auto_ds_BREADY : STD_LOGIC;
  signal s00_couplers_to_auto_ds_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_auto_ds_BVALID : STD_LOGIC;
  signal s00_couplers_to_auto_ds_RDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal s00_couplers_to_auto_ds_RID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s00_couplers_to_auto_ds_RLAST : STD_LOGIC;
  signal s00_couplers_to_auto_ds_RREADY : STD_LOGIC;
  signal s00_couplers_to_auto_ds_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_auto_ds_RVALID : STD_LOGIC;
  signal s00_couplers_to_auto_ds_WDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal s00_couplers_to_auto_ds_WLAST : STD_LOGIC;
  signal s00_couplers_to_auto_ds_WREADY : STD_LOGIC;
  signal s00_couplers_to_auto_ds_WSTRB : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s00_couplers_to_auto_ds_WVALID : STD_LOGIC;
  signal NLW_auto_pc_m_axi_arprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_auto_pc_m_axi_awprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
begin
  M_AXI_araddr(39 downto 0) <= auto_pc_to_s00_couplers_ARADDR(39 downto 0);
  M_AXI_arvalid <= auto_pc_to_s00_couplers_ARVALID;
  M_AXI_awaddr(39 downto 0) <= auto_pc_to_s00_couplers_AWADDR(39 downto 0);
  M_AXI_awvalid <= auto_pc_to_s00_couplers_AWVALID;
  M_AXI_bready <= auto_pc_to_s00_couplers_BREADY;
  M_AXI_rready <= auto_pc_to_s00_couplers_RREADY;
  M_AXI_wdata(31 downto 0) <= auto_pc_to_s00_couplers_WDATA(31 downto 0);
  M_AXI_wstrb(3 downto 0) <= auto_pc_to_s00_couplers_WSTRB(3 downto 0);
  M_AXI_wvalid <= auto_pc_to_s00_couplers_WVALID;
  S_ACLK_1 <= S_ACLK;
  S_ARESETN_1 <= S_ARESETN;
  S_AXI_arready <= s00_couplers_to_auto_ds_ARREADY;
  S_AXI_awready <= s00_couplers_to_auto_ds_AWREADY;
  S_AXI_bid(15 downto 0) <= s00_couplers_to_auto_ds_BID(15 downto 0);
  S_AXI_bresp(1 downto 0) <= s00_couplers_to_auto_ds_BRESP(1 downto 0);
  S_AXI_bvalid <= s00_couplers_to_auto_ds_BVALID;
  S_AXI_rdata(127 downto 0) <= s00_couplers_to_auto_ds_RDATA(127 downto 0);
  S_AXI_rid(15 downto 0) <= s00_couplers_to_auto_ds_RID(15 downto 0);
  S_AXI_rlast <= s00_couplers_to_auto_ds_RLAST;
  S_AXI_rresp(1 downto 0) <= s00_couplers_to_auto_ds_RRESP(1 downto 0);
  S_AXI_rvalid <= s00_couplers_to_auto_ds_RVALID;
  S_AXI_wready <= s00_couplers_to_auto_ds_WREADY;
  auto_pc_to_s00_couplers_ARREADY <= M_AXI_arready;
  auto_pc_to_s00_couplers_AWREADY <= M_AXI_awready;
  auto_pc_to_s00_couplers_BRESP(1 downto 0) <= M_AXI_bresp(1 downto 0);
  auto_pc_to_s00_couplers_BVALID <= M_AXI_bvalid;
  auto_pc_to_s00_couplers_RDATA(31 downto 0) <= M_AXI_rdata(31 downto 0);
  auto_pc_to_s00_couplers_RRESP(1 downto 0) <= M_AXI_rresp(1 downto 0);
  auto_pc_to_s00_couplers_RVALID <= M_AXI_rvalid;
  auto_pc_to_s00_couplers_WREADY <= M_AXI_wready;
  s00_couplers_to_auto_ds_ARADDR(39 downto 0) <= S_AXI_araddr(39 downto 0);
  s00_couplers_to_auto_ds_ARBURST(1 downto 0) <= S_AXI_arburst(1 downto 0);
  s00_couplers_to_auto_ds_ARCACHE(3 downto 0) <= S_AXI_arcache(3 downto 0);
  s00_couplers_to_auto_ds_ARID(15 downto 0) <= S_AXI_arid(15 downto 0);
  s00_couplers_to_auto_ds_ARLEN(7 downto 0) <= S_AXI_arlen(7 downto 0);
  s00_couplers_to_auto_ds_ARLOCK <= S_AXI_arlock;
  s00_couplers_to_auto_ds_ARPROT(2 downto 0) <= S_AXI_arprot(2 downto 0);
  s00_couplers_to_auto_ds_ARQOS(3 downto 0) <= S_AXI_arqos(3 downto 0);
  s00_couplers_to_auto_ds_ARSIZE(2 downto 0) <= S_AXI_arsize(2 downto 0);
  s00_couplers_to_auto_ds_ARVALID <= S_AXI_arvalid;
  s00_couplers_to_auto_ds_AWADDR(39 downto 0) <= S_AXI_awaddr(39 downto 0);
  s00_couplers_to_auto_ds_AWBURST(1 downto 0) <= S_AXI_awburst(1 downto 0);
  s00_couplers_to_auto_ds_AWCACHE(3 downto 0) <= S_AXI_awcache(3 downto 0);
  s00_couplers_to_auto_ds_AWID(15 downto 0) <= S_AXI_awid(15 downto 0);
  s00_couplers_to_auto_ds_AWLEN(7 downto 0) <= S_AXI_awlen(7 downto 0);
  s00_couplers_to_auto_ds_AWLOCK <= S_AXI_awlock;
  s00_couplers_to_auto_ds_AWPROT(2 downto 0) <= S_AXI_awprot(2 downto 0);
  s00_couplers_to_auto_ds_AWQOS(3 downto 0) <= S_AXI_awqos(3 downto 0);
  s00_couplers_to_auto_ds_AWSIZE(2 downto 0) <= S_AXI_awsize(2 downto 0);
  s00_couplers_to_auto_ds_AWVALID <= S_AXI_awvalid;
  s00_couplers_to_auto_ds_BREADY <= S_AXI_bready;
  s00_couplers_to_auto_ds_RREADY <= S_AXI_rready;
  s00_couplers_to_auto_ds_WDATA(127 downto 0) <= S_AXI_wdata(127 downto 0);
  s00_couplers_to_auto_ds_WLAST <= S_AXI_wlast;
  s00_couplers_to_auto_ds_WSTRB(15 downto 0) <= S_AXI_wstrb(15 downto 0);
  s00_couplers_to_auto_ds_WVALID <= S_AXI_wvalid;
auto_ds: component design_1_auto_ds_0
     port map (
      m_axi_araddr(39 downto 0) => auto_ds_to_auto_pc_ARADDR(39 downto 0),
      m_axi_arburst(1 downto 0) => auto_ds_to_auto_pc_ARBURST(1 downto 0),
      m_axi_arcache(3 downto 0) => auto_ds_to_auto_pc_ARCACHE(3 downto 0),
      m_axi_arlen(7 downto 0) => auto_ds_to_auto_pc_ARLEN(7 downto 0),
      m_axi_arlock(0) => auto_ds_to_auto_pc_ARLOCK(0),
      m_axi_arprot(2 downto 0) => auto_ds_to_auto_pc_ARPROT(2 downto 0),
      m_axi_arqos(3 downto 0) => auto_ds_to_auto_pc_ARQOS(3 downto 0),
      m_axi_arready => auto_ds_to_auto_pc_ARREADY,
      m_axi_arregion(3 downto 0) => auto_ds_to_auto_pc_ARREGION(3 downto 0),
      m_axi_arsize(2 downto 0) => auto_ds_to_auto_pc_ARSIZE(2 downto 0),
      m_axi_arvalid => auto_ds_to_auto_pc_ARVALID,
      m_axi_awaddr(39 downto 0) => auto_ds_to_auto_pc_AWADDR(39 downto 0),
      m_axi_awburst(1 downto 0) => auto_ds_to_auto_pc_AWBURST(1 downto 0),
      m_axi_awcache(3 downto 0) => auto_ds_to_auto_pc_AWCACHE(3 downto 0),
      m_axi_awlen(7 downto 0) => auto_ds_to_auto_pc_AWLEN(7 downto 0),
      m_axi_awlock(0) => auto_ds_to_auto_pc_AWLOCK(0),
      m_axi_awprot(2 downto 0) => auto_ds_to_auto_pc_AWPROT(2 downto 0),
      m_axi_awqos(3 downto 0) => auto_ds_to_auto_pc_AWQOS(3 downto 0),
      m_axi_awready => auto_ds_to_auto_pc_AWREADY,
      m_axi_awregion(3 downto 0) => auto_ds_to_auto_pc_AWREGION(3 downto 0),
      m_axi_awsize(2 downto 0) => auto_ds_to_auto_pc_AWSIZE(2 downto 0),
      m_axi_awvalid => auto_ds_to_auto_pc_AWVALID,
      m_axi_bready => auto_ds_to_auto_pc_BREADY,
      m_axi_bresp(1 downto 0) => auto_ds_to_auto_pc_BRESP(1 downto 0),
      m_axi_bvalid => auto_ds_to_auto_pc_BVALID,
      m_axi_rdata(31 downto 0) => auto_ds_to_auto_pc_RDATA(31 downto 0),
      m_axi_rlast => auto_ds_to_auto_pc_RLAST,
      m_axi_rready => auto_ds_to_auto_pc_RREADY,
      m_axi_rresp(1 downto 0) => auto_ds_to_auto_pc_RRESP(1 downto 0),
      m_axi_rvalid => auto_ds_to_auto_pc_RVALID,
      m_axi_wdata(31 downto 0) => auto_ds_to_auto_pc_WDATA(31 downto 0),
      m_axi_wlast => auto_ds_to_auto_pc_WLAST,
      m_axi_wready => auto_ds_to_auto_pc_WREADY,
      m_axi_wstrb(3 downto 0) => auto_ds_to_auto_pc_WSTRB(3 downto 0),
      m_axi_wvalid => auto_ds_to_auto_pc_WVALID,
      s_axi_aclk => S_ACLK_1,
      s_axi_araddr(39 downto 0) => s00_couplers_to_auto_ds_ARADDR(39 downto 0),
      s_axi_arburst(1 downto 0) => s00_couplers_to_auto_ds_ARBURST(1 downto 0),
      s_axi_arcache(3 downto 0) => s00_couplers_to_auto_ds_ARCACHE(3 downto 0),
      s_axi_aresetn => S_ARESETN_1,
      s_axi_arid(15 downto 0) => s00_couplers_to_auto_ds_ARID(15 downto 0),
      s_axi_arlen(7 downto 0) => s00_couplers_to_auto_ds_ARLEN(7 downto 0),
      s_axi_arlock(0) => s00_couplers_to_auto_ds_ARLOCK,
      s_axi_arprot(2 downto 0) => s00_couplers_to_auto_ds_ARPROT(2 downto 0),
      s_axi_arqos(3 downto 0) => s00_couplers_to_auto_ds_ARQOS(3 downto 0),
      s_axi_arready => s00_couplers_to_auto_ds_ARREADY,
      s_axi_arregion(3 downto 0) => B"0000",
      s_axi_arsize(2 downto 0) => s00_couplers_to_auto_ds_ARSIZE(2 downto 0),
      s_axi_arvalid => s00_couplers_to_auto_ds_ARVALID,
      s_axi_awaddr(39 downto 0) => s00_couplers_to_auto_ds_AWADDR(39 downto 0),
      s_axi_awburst(1 downto 0) => s00_couplers_to_auto_ds_AWBURST(1 downto 0),
      s_axi_awcache(3 downto 0) => s00_couplers_to_auto_ds_AWCACHE(3 downto 0),
      s_axi_awid(15 downto 0) => s00_couplers_to_auto_ds_AWID(15 downto 0),
      s_axi_awlen(7 downto 0) => s00_couplers_to_auto_ds_AWLEN(7 downto 0),
      s_axi_awlock(0) => s00_couplers_to_auto_ds_AWLOCK,
      s_axi_awprot(2 downto 0) => s00_couplers_to_auto_ds_AWPROT(2 downto 0),
      s_axi_awqos(3 downto 0) => s00_couplers_to_auto_ds_AWQOS(3 downto 0),
      s_axi_awready => s00_couplers_to_auto_ds_AWREADY,
      s_axi_awregion(3 downto 0) => B"0000",
      s_axi_awsize(2 downto 0) => s00_couplers_to_auto_ds_AWSIZE(2 downto 0),
      s_axi_awvalid => s00_couplers_to_auto_ds_AWVALID,
      s_axi_bid(15 downto 0) => s00_couplers_to_auto_ds_BID(15 downto 0),
      s_axi_bready => s00_couplers_to_auto_ds_BREADY,
      s_axi_bresp(1 downto 0) => s00_couplers_to_auto_ds_BRESP(1 downto 0),
      s_axi_bvalid => s00_couplers_to_auto_ds_BVALID,
      s_axi_rdata(127 downto 0) => s00_couplers_to_auto_ds_RDATA(127 downto 0),
      s_axi_rid(15 downto 0) => s00_couplers_to_auto_ds_RID(15 downto 0),
      s_axi_rlast => s00_couplers_to_auto_ds_RLAST,
      s_axi_rready => s00_couplers_to_auto_ds_RREADY,
      s_axi_rresp(1 downto 0) => s00_couplers_to_auto_ds_RRESP(1 downto 0),
      s_axi_rvalid => s00_couplers_to_auto_ds_RVALID,
      s_axi_wdata(127 downto 0) => s00_couplers_to_auto_ds_WDATA(127 downto 0),
      s_axi_wlast => s00_couplers_to_auto_ds_WLAST,
      s_axi_wready => s00_couplers_to_auto_ds_WREADY,
      s_axi_wstrb(15 downto 0) => s00_couplers_to_auto_ds_WSTRB(15 downto 0),
      s_axi_wvalid => s00_couplers_to_auto_ds_WVALID
    );
auto_pc: component design_1_auto_pc_0
     port map (
      aclk => S_ACLK_1,
      aresetn => S_ARESETN_1,
      m_axi_araddr(39 downto 0) => auto_pc_to_s00_couplers_ARADDR(39 downto 0),
      m_axi_arprot(2 downto 0) => NLW_auto_pc_m_axi_arprot_UNCONNECTED(2 downto 0),
      m_axi_arready => auto_pc_to_s00_couplers_ARREADY,
      m_axi_arvalid => auto_pc_to_s00_couplers_ARVALID,
      m_axi_awaddr(39 downto 0) => auto_pc_to_s00_couplers_AWADDR(39 downto 0),
      m_axi_awprot(2 downto 0) => NLW_auto_pc_m_axi_awprot_UNCONNECTED(2 downto 0),
      m_axi_awready => auto_pc_to_s00_couplers_AWREADY,
      m_axi_awvalid => auto_pc_to_s00_couplers_AWVALID,
      m_axi_bready => auto_pc_to_s00_couplers_BREADY,
      m_axi_bresp(1 downto 0) => auto_pc_to_s00_couplers_BRESP(1 downto 0),
      m_axi_bvalid => auto_pc_to_s00_couplers_BVALID,
      m_axi_rdata(31 downto 0) => auto_pc_to_s00_couplers_RDATA(31 downto 0),
      m_axi_rready => auto_pc_to_s00_couplers_RREADY,
      m_axi_rresp(1 downto 0) => auto_pc_to_s00_couplers_RRESP(1 downto 0),
      m_axi_rvalid => auto_pc_to_s00_couplers_RVALID,
      m_axi_wdata(31 downto 0) => auto_pc_to_s00_couplers_WDATA(31 downto 0),
      m_axi_wready => auto_pc_to_s00_couplers_WREADY,
      m_axi_wstrb(3 downto 0) => auto_pc_to_s00_couplers_WSTRB(3 downto 0),
      m_axi_wvalid => auto_pc_to_s00_couplers_WVALID,
      s_axi_araddr(39 downto 0) => auto_ds_to_auto_pc_ARADDR(39 downto 0),
      s_axi_arburst(1 downto 0) => auto_ds_to_auto_pc_ARBURST(1 downto 0),
      s_axi_arcache(3 downto 0) => auto_ds_to_auto_pc_ARCACHE(3 downto 0),
      s_axi_arlen(7 downto 0) => auto_ds_to_auto_pc_ARLEN(7 downto 0),
      s_axi_arlock(0) => auto_ds_to_auto_pc_ARLOCK(0),
      s_axi_arprot(2 downto 0) => auto_ds_to_auto_pc_ARPROT(2 downto 0),
      s_axi_arqos(3 downto 0) => auto_ds_to_auto_pc_ARQOS(3 downto 0),
      s_axi_arready => auto_ds_to_auto_pc_ARREADY,
      s_axi_arregion(3 downto 0) => auto_ds_to_auto_pc_ARREGION(3 downto 0),
      s_axi_arsize(2 downto 0) => auto_ds_to_auto_pc_ARSIZE(2 downto 0),
      s_axi_arvalid => auto_ds_to_auto_pc_ARVALID,
      s_axi_awaddr(39 downto 0) => auto_ds_to_auto_pc_AWADDR(39 downto 0),
      s_axi_awburst(1 downto 0) => auto_ds_to_auto_pc_AWBURST(1 downto 0),
      s_axi_awcache(3 downto 0) => auto_ds_to_auto_pc_AWCACHE(3 downto 0),
      s_axi_awlen(7 downto 0) => auto_ds_to_auto_pc_AWLEN(7 downto 0),
      s_axi_awlock(0) => auto_ds_to_auto_pc_AWLOCK(0),
      s_axi_awprot(2 downto 0) => auto_ds_to_auto_pc_AWPROT(2 downto 0),
      s_axi_awqos(3 downto 0) => auto_ds_to_auto_pc_AWQOS(3 downto 0),
      s_axi_awready => auto_ds_to_auto_pc_AWREADY,
      s_axi_awregion(3 downto 0) => auto_ds_to_auto_pc_AWREGION(3 downto 0),
      s_axi_awsize(2 downto 0) => auto_ds_to_auto_pc_AWSIZE(2 downto 0),
      s_axi_awvalid => auto_ds_to_auto_pc_AWVALID,
      s_axi_bready => auto_ds_to_auto_pc_BREADY,
      s_axi_bresp(1 downto 0) => auto_ds_to_auto_pc_BRESP(1 downto 0),
      s_axi_bvalid => auto_ds_to_auto_pc_BVALID,
      s_axi_rdata(31 downto 0) => auto_ds_to_auto_pc_RDATA(31 downto 0),
      s_axi_rlast => auto_ds_to_auto_pc_RLAST,
      s_axi_rready => auto_ds_to_auto_pc_RREADY,
      s_axi_rresp(1 downto 0) => auto_ds_to_auto_pc_RRESP(1 downto 0),
      s_axi_rvalid => auto_ds_to_auto_pc_RVALID,
      s_axi_wdata(31 downto 0) => auto_ds_to_auto_pc_WDATA(31 downto 0),
      s_axi_wlast => auto_ds_to_auto_pc_WLAST,
      s_axi_wready => auto_ds_to_auto_pc_WREADY,
      s_axi_wstrb(3 downto 0) => auto_ds_to_auto_pc_WSTRB(3 downto 0),
      s_axi_wvalid => auto_ds_to_auto_pc_WVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0 is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    M00_ACLK : in STD_LOGIC;
    M00_ARESETN : in STD_LOGIC;
    M00_AXI_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    M00_AXI_arready : in STD_LOGIC;
    M00_AXI_arvalid : out STD_LOGIC;
    M00_AXI_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    M00_AXI_awready : in STD_LOGIC;
    M00_AXI_awvalid : out STD_LOGIC;
    M00_AXI_bready : out STD_LOGIC;
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bvalid : in STD_LOGIC;
    M00_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_rready : out STD_LOGIC;
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rvalid : in STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_wready : in STD_LOGIC;
    M00_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_wvalid : out STD_LOGIC;
    S00_ACLK : in STD_LOGIC;
    S00_ARESETN : in STD_LOGIC;
    S00_AXI_araddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S00_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_arlock : in STD_LOGIC;
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arready : out STD_LOGIC;
    S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arvalid : in STD_LOGIC;
    S00_AXI_awaddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    S00_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S00_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_awlock : in STD_LOGIC;
    S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awready : out STD_LOGIC;
    S00_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awvalid : in STD_LOGIC;
    S00_AXI_bid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    S00_AXI_bready : in STD_LOGIC;
    S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_bvalid : out STD_LOGIC;
    S00_AXI_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    S00_AXI_rid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    S00_AXI_rlast : out STD_LOGIC;
    S00_AXI_rready : in STD_LOGIC;
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rvalid : out STD_LOGIC;
    S00_AXI_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    S00_AXI_wlast : in STD_LOGIC;
    S00_AXI_wready : out STD_LOGIC;
    S00_AXI_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S00_AXI_wvalid : in STD_LOGIC
  );
end design_1_axi_interconnect_0_0;

architecture STRUCTURE of design_1_axi_interconnect_0_0 is
  signal S00_ACLK_1 : STD_LOGIC;
  signal S00_ARESETN_1 : STD_LOGIC;
  signal axi_interconnect_0_ACLK_net : STD_LOGIC;
  signal axi_interconnect_0_ARESETN_net : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARLOCK : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARREADY : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_ARVALID : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWLOCK : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWREADY : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_AWVALID : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_BID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_BREADY : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_BVALID : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_RDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_RID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_RLAST : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_RREADY : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_RVALID : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_WDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_WLAST : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_WREADY : STD_LOGIC;
  signal axi_interconnect_0_to_s00_couplers_WSTRB : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal axi_interconnect_0_to_s00_couplers_WVALID : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_ARREADY : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_ARVALID : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_AWREADY : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_AWVALID : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_BREADY : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_BVALID : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_RREADY : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_RVALID : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_WREADY : STD_LOGIC;
  signal s00_couplers_to_axi_interconnect_0_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s00_couplers_to_axi_interconnect_0_WVALID : STD_LOGIC;
begin
  M00_AXI_araddr(39 downto 0) <= s00_couplers_to_axi_interconnect_0_ARADDR(39 downto 0);
  M00_AXI_arvalid <= s00_couplers_to_axi_interconnect_0_ARVALID;
  M00_AXI_awaddr(39 downto 0) <= s00_couplers_to_axi_interconnect_0_AWADDR(39 downto 0);
  M00_AXI_awvalid <= s00_couplers_to_axi_interconnect_0_AWVALID;
  M00_AXI_bready <= s00_couplers_to_axi_interconnect_0_BREADY;
  M00_AXI_rready <= s00_couplers_to_axi_interconnect_0_RREADY;
  M00_AXI_wdata(31 downto 0) <= s00_couplers_to_axi_interconnect_0_WDATA(31 downto 0);
  M00_AXI_wstrb(3 downto 0) <= s00_couplers_to_axi_interconnect_0_WSTRB(3 downto 0);
  M00_AXI_wvalid <= s00_couplers_to_axi_interconnect_0_WVALID;
  S00_ACLK_1 <= S00_ACLK;
  S00_ARESETN_1 <= S00_ARESETN;
  S00_AXI_arready <= axi_interconnect_0_to_s00_couplers_ARREADY;
  S00_AXI_awready <= axi_interconnect_0_to_s00_couplers_AWREADY;
  S00_AXI_bid(15 downto 0) <= axi_interconnect_0_to_s00_couplers_BID(15 downto 0);
  S00_AXI_bresp(1 downto 0) <= axi_interconnect_0_to_s00_couplers_BRESP(1 downto 0);
  S00_AXI_bvalid <= axi_interconnect_0_to_s00_couplers_BVALID;
  S00_AXI_rdata(127 downto 0) <= axi_interconnect_0_to_s00_couplers_RDATA(127 downto 0);
  S00_AXI_rid(15 downto 0) <= axi_interconnect_0_to_s00_couplers_RID(15 downto 0);
  S00_AXI_rlast <= axi_interconnect_0_to_s00_couplers_RLAST;
  S00_AXI_rresp(1 downto 0) <= axi_interconnect_0_to_s00_couplers_RRESP(1 downto 0);
  S00_AXI_rvalid <= axi_interconnect_0_to_s00_couplers_RVALID;
  S00_AXI_wready <= axi_interconnect_0_to_s00_couplers_WREADY;
  axi_interconnect_0_ACLK_net <= M00_ACLK;
  axi_interconnect_0_ARESETN_net <= M00_ARESETN;
  axi_interconnect_0_to_s00_couplers_ARADDR(39 downto 0) <= S00_AXI_araddr(39 downto 0);
  axi_interconnect_0_to_s00_couplers_ARBURST(1 downto 0) <= S00_AXI_arburst(1 downto 0);
  axi_interconnect_0_to_s00_couplers_ARCACHE(3 downto 0) <= S00_AXI_arcache(3 downto 0);
  axi_interconnect_0_to_s00_couplers_ARID(15 downto 0) <= S00_AXI_arid(15 downto 0);
  axi_interconnect_0_to_s00_couplers_ARLEN(7 downto 0) <= S00_AXI_arlen(7 downto 0);
  axi_interconnect_0_to_s00_couplers_ARLOCK <= S00_AXI_arlock;
  axi_interconnect_0_to_s00_couplers_ARPROT(2 downto 0) <= S00_AXI_arprot(2 downto 0);
  axi_interconnect_0_to_s00_couplers_ARQOS(3 downto 0) <= S00_AXI_arqos(3 downto 0);
  axi_interconnect_0_to_s00_couplers_ARSIZE(2 downto 0) <= S00_AXI_arsize(2 downto 0);
  axi_interconnect_0_to_s00_couplers_ARVALID <= S00_AXI_arvalid;
  axi_interconnect_0_to_s00_couplers_AWADDR(39 downto 0) <= S00_AXI_awaddr(39 downto 0);
  axi_interconnect_0_to_s00_couplers_AWBURST(1 downto 0) <= S00_AXI_awburst(1 downto 0);
  axi_interconnect_0_to_s00_couplers_AWCACHE(3 downto 0) <= S00_AXI_awcache(3 downto 0);
  axi_interconnect_0_to_s00_couplers_AWID(15 downto 0) <= S00_AXI_awid(15 downto 0);
  axi_interconnect_0_to_s00_couplers_AWLEN(7 downto 0) <= S00_AXI_awlen(7 downto 0);
  axi_interconnect_0_to_s00_couplers_AWLOCK <= S00_AXI_awlock;
  axi_interconnect_0_to_s00_couplers_AWPROT(2 downto 0) <= S00_AXI_awprot(2 downto 0);
  axi_interconnect_0_to_s00_couplers_AWQOS(3 downto 0) <= S00_AXI_awqos(3 downto 0);
  axi_interconnect_0_to_s00_couplers_AWSIZE(2 downto 0) <= S00_AXI_awsize(2 downto 0);
  axi_interconnect_0_to_s00_couplers_AWVALID <= S00_AXI_awvalid;
  axi_interconnect_0_to_s00_couplers_BREADY <= S00_AXI_bready;
  axi_interconnect_0_to_s00_couplers_RREADY <= S00_AXI_rready;
  axi_interconnect_0_to_s00_couplers_WDATA(127 downto 0) <= S00_AXI_wdata(127 downto 0);
  axi_interconnect_0_to_s00_couplers_WLAST <= S00_AXI_wlast;
  axi_interconnect_0_to_s00_couplers_WSTRB(15 downto 0) <= S00_AXI_wstrb(15 downto 0);
  axi_interconnect_0_to_s00_couplers_WVALID <= S00_AXI_wvalid;
  s00_couplers_to_axi_interconnect_0_ARREADY <= M00_AXI_arready;
  s00_couplers_to_axi_interconnect_0_AWREADY <= M00_AXI_awready;
  s00_couplers_to_axi_interconnect_0_BRESP(1 downto 0) <= M00_AXI_bresp(1 downto 0);
  s00_couplers_to_axi_interconnect_0_BVALID <= M00_AXI_bvalid;
  s00_couplers_to_axi_interconnect_0_RDATA(31 downto 0) <= M00_AXI_rdata(31 downto 0);
  s00_couplers_to_axi_interconnect_0_RRESP(1 downto 0) <= M00_AXI_rresp(1 downto 0);
  s00_couplers_to_axi_interconnect_0_RVALID <= M00_AXI_rvalid;
  s00_couplers_to_axi_interconnect_0_WREADY <= M00_AXI_wready;
s00_couplers: entity work.s00_couplers_imp_O7FAN0
     port map (
      M_ACLK => axi_interconnect_0_ACLK_net,
      M_ARESETN => axi_interconnect_0_ARESETN_net,
      M_AXI_araddr(39 downto 0) => s00_couplers_to_axi_interconnect_0_ARADDR(39 downto 0),
      M_AXI_arready => s00_couplers_to_axi_interconnect_0_ARREADY,
      M_AXI_arvalid => s00_couplers_to_axi_interconnect_0_ARVALID,
      M_AXI_awaddr(39 downto 0) => s00_couplers_to_axi_interconnect_0_AWADDR(39 downto 0),
      M_AXI_awready => s00_couplers_to_axi_interconnect_0_AWREADY,
      M_AXI_awvalid => s00_couplers_to_axi_interconnect_0_AWVALID,
      M_AXI_bready => s00_couplers_to_axi_interconnect_0_BREADY,
      M_AXI_bresp(1 downto 0) => s00_couplers_to_axi_interconnect_0_BRESP(1 downto 0),
      M_AXI_bvalid => s00_couplers_to_axi_interconnect_0_BVALID,
      M_AXI_rdata(31 downto 0) => s00_couplers_to_axi_interconnect_0_RDATA(31 downto 0),
      M_AXI_rready => s00_couplers_to_axi_interconnect_0_RREADY,
      M_AXI_rresp(1 downto 0) => s00_couplers_to_axi_interconnect_0_RRESP(1 downto 0),
      M_AXI_rvalid => s00_couplers_to_axi_interconnect_0_RVALID,
      M_AXI_wdata(31 downto 0) => s00_couplers_to_axi_interconnect_0_WDATA(31 downto 0),
      M_AXI_wready => s00_couplers_to_axi_interconnect_0_WREADY,
      M_AXI_wstrb(3 downto 0) => s00_couplers_to_axi_interconnect_0_WSTRB(3 downto 0),
      M_AXI_wvalid => s00_couplers_to_axi_interconnect_0_WVALID,
      S_ACLK => S00_ACLK_1,
      S_ARESETN => S00_ARESETN_1,
      S_AXI_araddr(39 downto 0) => axi_interconnect_0_to_s00_couplers_ARADDR(39 downto 0),
      S_AXI_arburst(1 downto 0) => axi_interconnect_0_to_s00_couplers_ARBURST(1 downto 0),
      S_AXI_arcache(3 downto 0) => axi_interconnect_0_to_s00_couplers_ARCACHE(3 downto 0),
      S_AXI_arid(15 downto 0) => axi_interconnect_0_to_s00_couplers_ARID(15 downto 0),
      S_AXI_arlen(7 downto 0) => axi_interconnect_0_to_s00_couplers_ARLEN(7 downto 0),
      S_AXI_arlock => axi_interconnect_0_to_s00_couplers_ARLOCK,
      S_AXI_arprot(2 downto 0) => axi_interconnect_0_to_s00_couplers_ARPROT(2 downto 0),
      S_AXI_arqos(3 downto 0) => axi_interconnect_0_to_s00_couplers_ARQOS(3 downto 0),
      S_AXI_arready => axi_interconnect_0_to_s00_couplers_ARREADY,
      S_AXI_arsize(2 downto 0) => axi_interconnect_0_to_s00_couplers_ARSIZE(2 downto 0),
      S_AXI_arvalid => axi_interconnect_0_to_s00_couplers_ARVALID,
      S_AXI_awaddr(39 downto 0) => axi_interconnect_0_to_s00_couplers_AWADDR(39 downto 0),
      S_AXI_awburst(1 downto 0) => axi_interconnect_0_to_s00_couplers_AWBURST(1 downto 0),
      S_AXI_awcache(3 downto 0) => axi_interconnect_0_to_s00_couplers_AWCACHE(3 downto 0),
      S_AXI_awid(15 downto 0) => axi_interconnect_0_to_s00_couplers_AWID(15 downto 0),
      S_AXI_awlen(7 downto 0) => axi_interconnect_0_to_s00_couplers_AWLEN(7 downto 0),
      S_AXI_awlock => axi_interconnect_0_to_s00_couplers_AWLOCK,
      S_AXI_awprot(2 downto 0) => axi_interconnect_0_to_s00_couplers_AWPROT(2 downto 0),
      S_AXI_awqos(3 downto 0) => axi_interconnect_0_to_s00_couplers_AWQOS(3 downto 0),
      S_AXI_awready => axi_interconnect_0_to_s00_couplers_AWREADY,
      S_AXI_awsize(2 downto 0) => axi_interconnect_0_to_s00_couplers_AWSIZE(2 downto 0),
      S_AXI_awvalid => axi_interconnect_0_to_s00_couplers_AWVALID,
      S_AXI_bid(15 downto 0) => axi_interconnect_0_to_s00_couplers_BID(15 downto 0),
      S_AXI_bready => axi_interconnect_0_to_s00_couplers_BREADY,
      S_AXI_bresp(1 downto 0) => axi_interconnect_0_to_s00_couplers_BRESP(1 downto 0),
      S_AXI_bvalid => axi_interconnect_0_to_s00_couplers_BVALID,
      S_AXI_rdata(127 downto 0) => axi_interconnect_0_to_s00_couplers_RDATA(127 downto 0),
      S_AXI_rid(15 downto 0) => axi_interconnect_0_to_s00_couplers_RID(15 downto 0),
      S_AXI_rlast => axi_interconnect_0_to_s00_couplers_RLAST,
      S_AXI_rready => axi_interconnect_0_to_s00_couplers_RREADY,
      S_AXI_rresp(1 downto 0) => axi_interconnect_0_to_s00_couplers_RRESP(1 downto 0),
      S_AXI_rvalid => axi_interconnect_0_to_s00_couplers_RVALID,
      S_AXI_wdata(127 downto 0) => axi_interconnect_0_to_s00_couplers_WDATA(127 downto 0),
      S_AXI_wlast => axi_interconnect_0_to_s00_couplers_WLAST,
      S_AXI_wready => axi_interconnect_0_to_s00_couplers_WREADY,
      S_AXI_wstrb(15 downto 0) => axi_interconnect_0_to_s00_couplers_WSTRB(15 downto 0),
      S_AXI_wvalid => axi_interconnect_0_to_s00_couplers_WVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axis_interconnect_0_0 is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    M00_AXIS_ACLK : in STD_LOGIC;
    M00_AXIS_ARESETN : in STD_LOGIC;
    M00_AXIS_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M00_AXIS_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXIS_tlast : out STD_LOGIC;
    M00_AXIS_tready : in STD_LOGIC;
    M00_AXIS_tvalid : out STD_LOGIC;
    S00_AXIS_ACLK : in STD_LOGIC;
    S00_AXIS_ARESETN : in STD_LOGIC;
    S00_AXIS_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S00_AXIS_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXIS_tlast : in STD_LOGIC;
    S00_AXIS_tuser : in STD_LOGIC;
    S00_AXIS_tvalid : in STD_LOGIC
  );
end design_1_axis_interconnect_0_0;

architecture STRUCTURE of design_1_axis_interconnect_0_0 is
  signal M00_AXIS_ACLK_1 : STD_LOGIC;
  signal M00_AXIS_ARESETN_1 : STD_LOGIC;
  signal S00_AXIS_ACLK_1 : STD_LOGIC;
  signal S00_AXIS_ARESETN_1 : STD_LOGIC;
  signal axis_interconnect_0_to_s00_couplers_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axis_interconnect_0_to_s00_couplers_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axis_interconnect_0_to_s00_couplers_TLAST : STD_LOGIC;
  signal axis_interconnect_0_to_s00_couplers_TUSER : STD_LOGIC;
  signal axis_interconnect_0_to_s00_couplers_TVALID : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_0_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal s00_couplers_to_axis_interconnect_0_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s00_couplers_to_axis_interconnect_0_TLAST : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_0_TREADY : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_0_TVALID : STD_LOGIC;
begin
  M00_AXIS_ACLK_1 <= M00_AXIS_ACLK;
  M00_AXIS_ARESETN_1 <= M00_AXIS_ARESETN;
  M00_AXIS_tdata(63 downto 0) <= s00_couplers_to_axis_interconnect_0_TDATA(63 downto 0);
  M00_AXIS_tkeep(7 downto 0) <= s00_couplers_to_axis_interconnect_0_TKEEP(7 downto 0);
  M00_AXIS_tlast <= s00_couplers_to_axis_interconnect_0_TLAST;
  M00_AXIS_tvalid <= s00_couplers_to_axis_interconnect_0_TVALID;
  S00_AXIS_ACLK_1 <= S00_AXIS_ACLK;
  S00_AXIS_ARESETN_1 <= S00_AXIS_ARESETN;
  axis_interconnect_0_to_s00_couplers_TDATA(63 downto 0) <= S00_AXIS_tdata(63 downto 0);
  axis_interconnect_0_to_s00_couplers_TKEEP(7 downto 0) <= S00_AXIS_tkeep(7 downto 0);
  axis_interconnect_0_to_s00_couplers_TLAST <= S00_AXIS_tlast;
  axis_interconnect_0_to_s00_couplers_TUSER <= S00_AXIS_tuser;
  axis_interconnect_0_to_s00_couplers_TVALID <= S00_AXIS_tvalid;
  s00_couplers_to_axis_interconnect_0_TREADY <= M00_AXIS_tready;
s00_couplers: entity work.s00_couplers_imp_1LLE45P
     port map (
      M_AXIS_ACLK => M00_AXIS_ACLK_1,
      M_AXIS_ARESETN => M00_AXIS_ARESETN_1,
      M_AXIS_tdata(63 downto 0) => s00_couplers_to_axis_interconnect_0_TDATA(63 downto 0),
      M_AXIS_tkeep(7 downto 0) => s00_couplers_to_axis_interconnect_0_TKEEP(7 downto 0),
      M_AXIS_tlast => s00_couplers_to_axis_interconnect_0_TLAST,
      M_AXIS_tready => s00_couplers_to_axis_interconnect_0_TREADY,
      M_AXIS_tvalid => s00_couplers_to_axis_interconnect_0_TVALID,
      S_AXIS_ACLK => S00_AXIS_ACLK_1,
      S_AXIS_ARESETN => S00_AXIS_ARESETN_1,
      S_AXIS_tdata(63 downto 0) => axis_interconnect_0_to_s00_couplers_TDATA(63 downto 0),
      S_AXIS_tkeep(7 downto 0) => axis_interconnect_0_to_s00_couplers_TKEEP(7 downto 0),
      S_AXIS_tlast => axis_interconnect_0_to_s00_couplers_TLAST,
      S_AXIS_tuser => axis_interconnect_0_to_s00_couplers_TUSER,
      S_AXIS_tvalid => axis_interconnect_0_to_s00_couplers_TVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axis_interconnect_1_0 is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    M00_AXIS_ACLK : in STD_LOGIC;
    M00_AXIS_ARESETN : in STD_LOGIC;
    M00_AXIS_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M00_AXIS_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXIS_tlast : out STD_LOGIC;
    M00_AXIS_tready : in STD_LOGIC;
    M00_AXIS_tuser : out STD_LOGIC;
    M00_AXIS_tvalid : out STD_LOGIC;
    S00_AXIS_ACLK : in STD_LOGIC;
    S00_AXIS_ARESETN : in STD_LOGIC;
    S00_AXIS_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S00_AXIS_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXIS_tlast : in STD_LOGIC;
    S00_AXIS_tready : out STD_LOGIC;
    S00_AXIS_tvalid : in STD_LOGIC
  );
end design_1_axis_interconnect_1_0;

architecture STRUCTURE of design_1_axis_interconnect_1_0 is
  signal M00_AXIS_ACLK_1 : STD_LOGIC;
  signal M00_AXIS_ARESETN_1 : STD_LOGIC;
  signal S00_AXIS_ACLK_1 : STD_LOGIC;
  signal S00_AXIS_ARESETN_1 : STD_LOGIC;
  signal axis_interconnect_1_to_s00_couplers_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axis_interconnect_1_to_s00_couplers_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axis_interconnect_1_to_s00_couplers_TLAST : STD_LOGIC;
  signal axis_interconnect_1_to_s00_couplers_TREADY : STD_LOGIC;
  signal axis_interconnect_1_to_s00_couplers_TVALID : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_1_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal s00_couplers_to_axis_interconnect_1_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s00_couplers_to_axis_interconnect_1_TLAST : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_1_TREADY : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_1_TUSER : STD_LOGIC;
  signal s00_couplers_to_axis_interconnect_1_TVALID : STD_LOGIC;
begin
  M00_AXIS_ACLK_1 <= M00_AXIS_ACLK;
  M00_AXIS_ARESETN_1 <= M00_AXIS_ARESETN;
  M00_AXIS_tdata(63 downto 0) <= s00_couplers_to_axis_interconnect_1_TDATA(63 downto 0);
  M00_AXIS_tkeep(7 downto 0) <= s00_couplers_to_axis_interconnect_1_TKEEP(7 downto 0);
  M00_AXIS_tlast <= s00_couplers_to_axis_interconnect_1_TLAST;
  M00_AXIS_tuser <= s00_couplers_to_axis_interconnect_1_TUSER;
  M00_AXIS_tvalid <= s00_couplers_to_axis_interconnect_1_TVALID;
  S00_AXIS_ACLK_1 <= S00_AXIS_ACLK;
  S00_AXIS_ARESETN_1 <= S00_AXIS_ARESETN;
  S00_AXIS_tready <= axis_interconnect_1_to_s00_couplers_TREADY;
  axis_interconnect_1_to_s00_couplers_TDATA(63 downto 0) <= S00_AXIS_tdata(63 downto 0);
  axis_interconnect_1_to_s00_couplers_TKEEP(7 downto 0) <= S00_AXIS_tkeep(7 downto 0);
  axis_interconnect_1_to_s00_couplers_TLAST <= S00_AXIS_tlast;
  axis_interconnect_1_to_s00_couplers_TVALID <= S00_AXIS_tvalid;
  s00_couplers_to_axis_interconnect_1_TREADY <= M00_AXIS_tready;
s00_couplers: entity work.s00_couplers_imp_1O4UG5P
     port map (
      M_AXIS_ACLK => M00_AXIS_ACLK_1,
      M_AXIS_ARESETN => M00_AXIS_ARESETN_1,
      M_AXIS_tdata(63 downto 0) => s00_couplers_to_axis_interconnect_1_TDATA(63 downto 0),
      M_AXIS_tkeep(7 downto 0) => s00_couplers_to_axis_interconnect_1_TKEEP(7 downto 0),
      M_AXIS_tlast => s00_couplers_to_axis_interconnect_1_TLAST,
      M_AXIS_tready => s00_couplers_to_axis_interconnect_1_TREADY,
      M_AXIS_tuser => s00_couplers_to_axis_interconnect_1_TUSER,
      M_AXIS_tvalid => s00_couplers_to_axis_interconnect_1_TVALID,
      S_AXIS_ACLK => S00_AXIS_ACLK_1,
      S_AXIS_ARESETN => S00_AXIS_ARESETN_1,
      S_AXIS_tdata(63 downto 0) => axis_interconnect_1_to_s00_couplers_TDATA(63 downto 0),
      S_AXIS_tkeep(7 downto 0) => axis_interconnect_1_to_s00_couplers_TKEEP(7 downto 0),
      S_AXIS_tlast => axis_interconnect_1_to_s00_couplers_TLAST,
      S_AXIS_tready => axis_interconnect_1_to_s00_couplers_TREADY,
      S_AXIS_tvalid => axis_interconnect_1_to_s00_couplers_TVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1 is
  port (
    gt_ref_clk_clk_n : in STD_LOGIC;
    gt_ref_clk_clk_p : in STD_LOGIC;
    gt_rtl_grx_n : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_rtl_grx_p : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_rtl_gtx_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_rtl_gtx_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    sfp_tx_dis : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_1 : entity is "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=26,numReposBlks=20,numNonXlnxBlks=0,numHierBlks=6,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_1 : entity is "design_1.hwdef";
end design_1;

architecture STRUCTURE of design_1 is
  component design_1_XilinxSwitch_0_0 is
  port (
    packet_in_packet_in_TVALID : in STD_LOGIC_VECTOR ( 0 to 0 );
    packet_in_packet_in_TREADY : out STD_LOGIC_VECTOR ( 0 to 0 );
    packet_in_packet_in_TDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    packet_in_packet_in_TKEEP : in STD_LOGIC_VECTOR ( 7 downto 0 );
    packet_in_packet_in_TLAST : in STD_LOGIC_VECTOR ( 0 to 0 );
    tuple_in_unused_VALID : in STD_LOGIC_VECTOR ( 0 to 0 );
    tuple_in_unused_DATA : in STD_LOGIC_VECTOR ( 0 to 0 );
    enable_processing : in STD_LOGIC_VECTOR ( 0 to 0 );
    packet_out_packet_out_TVALID : out STD_LOGIC_VECTOR ( 0 to 0 );
    packet_out_packet_out_TREADY : in STD_LOGIC_VECTOR ( 0 to 0 );
    packet_out_packet_out_TDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    packet_out_packet_out_TKEEP : out STD_LOGIC_VECTOR ( 7 downto 0 );
    packet_out_packet_out_TLAST : out STD_LOGIC_VECTOR ( 0 to 0 );
    tuple_out_unused_VALID : out STD_LOGIC_VECTOR ( 0 to 0 );
    tuple_out_unused_DATA : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk_line_rst : in STD_LOGIC;
    clk_line : in STD_LOGIC;
    internal_rst_done : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_XilinxSwitch_0_0;
  component design_1_proc_sys_reset_0_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_proc_sys_reset_0_0;
  component design_1_proc_sys_reset_1_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_proc_sys_reset_1_0;
  component design_1_system_ila_0_0 is
  port (
    clk : in STD_LOGIC;
    resetn : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    SLOT_0_AXIS_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    SLOT_0_AXIS_tvalid : in STD_LOGIC
  );
  end component design_1_system_ila_0_0;
  component design_1_util_vector_logic_0_0 is
  port (
    Op1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Res : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_util_vector_logic_0_0;
  component design_1_util_vector_logic_1_0 is
  port (
    Op1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Res : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_util_vector_logic_1_0;
  component design_1_util_vector_logic_2_0 is
  port (
    Op1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Res : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_util_vector_logic_2_0;
  component design_1_xlconstant_0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_xlconstant_0_0;
  component design_1_xlconstant_1_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 55 downto 0 )
  );
  end component design_1_xlconstant_1_0;
  component design_1_xlconstant_2_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_xlconstant_2_0;
  component design_1_xlconstant_3_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_xlconstant_3_0;
  component design_1_xxv_ethernet_0_0 is
  port (
    gt_txp_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_txn_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_rxp_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_rxn_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    rx_core_clk_0 : in STD_LOGIC;
    gtwiz_reset_tx_datapath_0 : in STD_LOGIC;
    gtwiz_reset_rx_datapath_0 : in STD_LOGIC;
    rxrecclkout_0 : out STD_LOGIC;
    sys_reset : in STD_LOGIC;
    dclk : in STD_LOGIC;
    tx_clk_out_0 : out STD_LOGIC;
    rx_clk_out_0 : out STD_LOGIC;
    gt_refclk_p : in STD_LOGIC;
    gt_refclk_n : in STD_LOGIC;
    gt_refclk_out : out STD_LOGIC;
    s_axi_aclk_0 : in STD_LOGIC;
    s_axi_aresetn_0 : in STD_LOGIC;
    pm_tick_0 : in STD_LOGIC;
    s_axi_awaddr_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awvalid_0 : in STD_LOGIC;
    s_axi_awready_0 : out STD_LOGIC;
    s_axi_wdata_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb_0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid_0 : in STD_LOGIC;
    s_axi_wready_0 : out STD_LOGIC;
    s_axi_bresp_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid_0 : out STD_LOGIC;
    s_axi_bready_0 : in STD_LOGIC;
    s_axi_araddr_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arvalid_0 : in STD_LOGIC;
    s_axi_arready_0 : out STD_LOGIC;
    s_axi_rdata_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid_0 : out STD_LOGIC;
    s_axi_rready_0 : in STD_LOGIC;
    rx_reset_0 : in STD_LOGIC;
    user_rx_reset_0 : out STD_LOGIC;
    rx_axis_tvalid_0 : out STD_LOGIC;
    rx_axis_tdata_0 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    rx_axis_tlast_0 : out STD_LOGIC;
    rx_axis_tkeep_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    rx_axis_tuser_0 : out STD_LOGIC;
    stat_rx_framing_err_0 : out STD_LOGIC;
    stat_rx_framing_err_valid_0 : out STD_LOGIC;
    stat_rx_local_fault_0 : out STD_LOGIC;
    stat_rx_block_lock_0 : out STD_LOGIC;
    stat_rx_valid_ctrl_code_0 : out STD_LOGIC;
    stat_rx_status_0 : out STD_LOGIC;
    stat_rx_remote_fault_0 : out STD_LOGIC;
    stat_rx_bad_fcs_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_stomped_fcs_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_truncated_0 : out STD_LOGIC;
    stat_rx_internal_local_fault_0 : out STD_LOGIC;
    stat_rx_received_local_fault_0 : out STD_LOGIC;
    stat_rx_hi_ber_0 : out STD_LOGIC;
    stat_rx_got_signal_os_0 : out STD_LOGIC;
    stat_rx_test_pattern_mismatch_0 : out STD_LOGIC;
    stat_rx_total_bytes_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_total_packets_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_total_good_bytes_0 : out STD_LOGIC_VECTOR ( 13 downto 0 );
    stat_rx_total_good_packets_0 : out STD_LOGIC;
    stat_rx_packet_bad_fcs_0 : out STD_LOGIC;
    stat_rx_packet_64_bytes_0 : out STD_LOGIC;
    stat_rx_packet_65_127_bytes_0 : out STD_LOGIC;
    stat_rx_packet_128_255_bytes_0 : out STD_LOGIC;
    stat_rx_packet_256_511_bytes_0 : out STD_LOGIC;
    stat_rx_packet_512_1023_bytes_0 : out STD_LOGIC;
    stat_rx_packet_1024_1518_bytes_0 : out STD_LOGIC;
    stat_rx_packet_1519_1522_bytes_0 : out STD_LOGIC;
    stat_rx_packet_1523_1548_bytes_0 : out STD_LOGIC;
    stat_rx_packet_1549_2047_bytes_0 : out STD_LOGIC;
    stat_rx_packet_2048_4095_bytes_0 : out STD_LOGIC;
    stat_rx_packet_4096_8191_bytes_0 : out STD_LOGIC;
    stat_rx_packet_8192_9215_bytes_0 : out STD_LOGIC;
    stat_rx_packet_small_0 : out STD_LOGIC;
    stat_rx_packet_large_0 : out STD_LOGIC;
    stat_rx_oversize_0 : out STD_LOGIC;
    stat_rx_toolong_0 : out STD_LOGIC;
    stat_rx_undersize_0 : out STD_LOGIC;
    stat_rx_fragment_0 : out STD_LOGIC;
    stat_rx_jabber_0 : out STD_LOGIC;
    stat_rx_bad_code_0 : out STD_LOGIC;
    stat_rx_bad_sfd_0 : out STD_LOGIC;
    stat_rx_bad_preamble_0 : out STD_LOGIC;
    tx_reset_0 : in STD_LOGIC;
    user_tx_reset_0 : out STD_LOGIC;
    tx_axis_tready_0 : out STD_LOGIC;
    tx_axis_tvalid_0 : in STD_LOGIC;
    tx_axis_tdata_0 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    tx_axis_tlast_0 : in STD_LOGIC;
    tx_axis_tkeep_0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    tx_axis_tuser_0 : in STD_LOGIC;
    tx_unfout_0 : out STD_LOGIC;
    tx_preamblein_0 : in STD_LOGIC_VECTOR ( 55 downto 0 );
    rx_preambleout_0 : out STD_LOGIC_VECTOR ( 55 downto 0 );
    stat_tx_local_fault_0 : out STD_LOGIC;
    stat_tx_total_bytes_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_tx_total_packets_0 : out STD_LOGIC;
    stat_tx_total_good_bytes_0 : out STD_LOGIC_VECTOR ( 13 downto 0 );
    stat_tx_total_good_packets_0 : out STD_LOGIC;
    stat_tx_bad_fcs_0 : out STD_LOGIC;
    stat_tx_packet_64_bytes_0 : out STD_LOGIC;
    stat_tx_packet_65_127_bytes_0 : out STD_LOGIC;
    stat_tx_packet_128_255_bytes_0 : out STD_LOGIC;
    stat_tx_packet_256_511_bytes_0 : out STD_LOGIC;
    stat_tx_packet_512_1023_bytes_0 : out STD_LOGIC;
    stat_tx_packet_1024_1518_bytes_0 : out STD_LOGIC;
    stat_tx_packet_1519_1522_bytes_0 : out STD_LOGIC;
    stat_tx_packet_1523_1548_bytes_0 : out STD_LOGIC;
    stat_tx_packet_1549_2047_bytes_0 : out STD_LOGIC;
    stat_tx_packet_2048_4095_bytes_0 : out STD_LOGIC;
    stat_tx_packet_4096_8191_bytes_0 : out STD_LOGIC;
    stat_tx_packet_8192_9215_bytes_0 : out STD_LOGIC;
    stat_tx_packet_small_0 : out STD_LOGIC;
    stat_tx_packet_large_0 : out STD_LOGIC;
    stat_tx_frame_error_0 : out STD_LOGIC;
    ctl_tx_send_rfi_0 : in STD_LOGIC;
    ctl_tx_send_lfi_0 : in STD_LOGIC;
    ctl_tx_send_idle_0 : in STD_LOGIC
  );
  end component design_1_xxv_ethernet_0_0;
  component design_1_zynq_ultra_ps_e_0_0 is
  port (
    maxihpm0_lpd_aclk : in STD_LOGIC;
    maxigp2_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp2_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp2_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_awlock : out STD_LOGIC;
    maxigp2_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_awvalid : out STD_LOGIC;
    maxigp2_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_awready : in STD_LOGIC;
    maxigp2_wdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    maxigp2_wstrb : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_wlast : out STD_LOGIC;
    maxigp2_wvalid : out STD_LOGIC;
    maxigp2_wready : in STD_LOGIC;
    maxigp2_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_bvalid : in STD_LOGIC;
    maxigp2_bready : out STD_LOGIC;
    maxigp2_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp2_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp2_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_arlock : out STD_LOGIC;
    maxigp2_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_arvalid : out STD_LOGIC;
    maxigp2_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_arready : in STD_LOGIC;
    maxigp2_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_rdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    maxigp2_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_rlast : in STD_LOGIC;
    maxigp2_rvalid : in STD_LOGIC;
    maxigp2_rready : out STD_LOGIC;
    maxigp2_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pl_resetn0 : out STD_LOGIC;
    pl_clk0 : out STD_LOGIC;
    pl_clk1 : out STD_LOGIC
  );
  end component design_1_zynq_ultra_ps_e_0_0;
  signal ARESETN_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal M00_AXIS_ACLK_1 : STD_LOGIC;
  signal M00_AXIS_ACLK_2 : STD_LOGIC;
  signal M00_AXIS_ARESETN_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal S00_AXIS_1_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  attribute CONN_BUS_INFO : string;
  attribute CONN_BUS_INFO of S00_AXIS_1_TDATA : signal is "S00_AXIS_1 xilinx.com:interface:axis:1.0 None TDATA";
  attribute DONT_TOUCH : boolean;
  attribute DONT_TOUCH of S00_AXIS_1_TDATA : signal is std.standard.true;
  signal S00_AXIS_1_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute CONN_BUS_INFO of S00_AXIS_1_TKEEP : signal is "S00_AXIS_1 xilinx.com:interface:axis:1.0 None TKEEP";
  attribute DONT_TOUCH of S00_AXIS_1_TKEEP : signal is std.standard.true;
  signal S00_AXIS_1_TLAST : STD_LOGIC;
  attribute CONN_BUS_INFO of S00_AXIS_1_TLAST : signal is "S00_AXIS_1 xilinx.com:interface:axis:1.0 None TLAST";
  attribute DONT_TOUCH of S00_AXIS_1_TLAST : signal is std.standard.true;
  signal S00_AXIS_1_TUSER : STD_LOGIC;
  attribute CONN_BUS_INFO of S00_AXIS_1_TUSER : signal is "S00_AXIS_1 xilinx.com:interface:axis:1.0 None TUSER";
  attribute DONT_TOUCH of S00_AXIS_1_TUSER : signal is std.standard.true;
  signal S00_AXIS_1_TVALID : STD_LOGIC;
  attribute CONN_BUS_INFO of S00_AXIS_1_TVALID : signal is "S00_AXIS_1 xilinx.com:interface:axis:1.0 None TVALID";
  attribute DONT_TOUCH of S00_AXIS_1_TVALID : signal is std.standard.true;
  signal XilinxSwitch_0_packet_out_packet_out_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal XilinxSwitch_0_packet_out_packet_out_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal XilinxSwitch_0_packet_out_packet_out_TLAST : STD_LOGIC_VECTOR ( 0 to 0 );
  signal XilinxSwitch_0_packet_out_packet_out_TREADY : STD_LOGIC;
  signal XilinxSwitch_0_packet_out_packet_out_TVALID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_0_M00_AXI_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal axi_interconnect_0_M00_AXI_ARREADY : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_ARVALID : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal axi_interconnect_0_M00_AXI_AWREADY : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_AWVALID : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_BREADY : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_M00_AXI_BVALID : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_0_M00_AXI_RREADY : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_M00_AXI_RVALID : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_0_M00_AXI_WREADY : STD_LOGIC;
  signal axi_interconnect_0_M00_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_0_M00_AXI_WVALID : STD_LOGIC;
  signal axis_interconnect_0_M00_AXIS_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axis_interconnect_0_M00_AXIS_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axis_interconnect_0_M00_AXIS_TLAST : STD_LOGIC;
  signal axis_interconnect_0_M00_AXIS_TREADY : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axis_interconnect_0_M00_AXIS_TVALID : STD_LOGIC;
  signal axis_interconnect_1_M00_AXIS_TDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axis_interconnect_1_M00_AXIS_TKEEP : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axis_interconnect_1_M00_AXIS_TLAST : STD_LOGIC;
  signal axis_interconnect_1_M00_AXIS_TREADY : STD_LOGIC;
  signal axis_interconnect_1_M00_AXIS_TUSER : STD_LOGIC;
  signal axis_interconnect_1_M00_AXIS_TVALID : STD_LOGIC;
  signal gt_ref_clk_1_CLK_N : STD_LOGIC;
  signal gt_ref_clk_1_CLK_P : STD_LOGIC;
  signal proc_sys_reset_0_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal proc_sys_reset_0_peripheral_reset : STD_LOGIC_VECTOR ( 0 to 0 );
  signal proc_sys_reset_1_interconnect_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal proc_sys_reset_1_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal proc_sys_reset_1_peripheral_reset : STD_LOGIC_VECTOR ( 0 to 0 );
  signal util_vector_logic_0_Res : STD_LOGIC_VECTOR ( 0 to 0 );
  signal util_vector_logic_1_Res : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xlconstant_0_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xlconstant_1_dout : STD_LOGIC_VECTOR ( 55 downto 0 );
  signal xlconstant_2_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xlconstant_3_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xxv_ethernet_0_gt_serial_port_GRX_N : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xxv_ethernet_0_gt_serial_port_GRX_P : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xxv_ethernet_0_gt_serial_port_GTX_N : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xxv_ethernet_0_gt_serial_port_GTX_P : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xxv_ethernet_0_rx_clk_out_0 : STD_LOGIC;
  signal xxv_ethernet_0_user_rx_reset_0 : STD_LOGIC;
  signal xxv_ethernet_0_user_tx_reset_0 : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARLOCK : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARREADY : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARVALID : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWADDR : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWLOCK : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWREADY : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWVALID : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BREADY : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BVALID : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RID : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RLAST : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RREADY : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RVALID : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WLAST : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WREADY : STD_LOGIC;
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WSTRB : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WVALID : STD_LOGIC;
  signal zynq_ultra_ps_e_0_pl_clk0 : STD_LOGIC;
  signal zynq_ultra_ps_e_0_pl_resetn0 : STD_LOGIC;
  signal NLW_XilinxSwitch_0_internal_rst_done_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_XilinxSwitch_0_tuple_out_unused_DATA_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_XilinxSwitch_0_tuple_out_unused_VALID_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_proc_sys_reset_0_mb_reset_UNCONNECTED : STD_LOGIC;
  signal NLW_proc_sys_reset_0_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_proc_sys_reset_1_mb_reset_UNCONNECTED : STD_LOGIC;
  signal NLW_proc_sys_reset_1_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_xxv_ethernet_0_gt_refclk_out_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_rxrecclkout_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_bad_code_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_bad_preamble_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_bad_sfd_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_block_lock_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_fragment_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_framing_err_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_framing_err_valid_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_got_signal_os_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_hi_ber_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_internal_local_fault_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_jabber_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_local_fault_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_oversize_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_1024_1518_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_128_255_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_1519_1522_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_1523_1548_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_1549_2047_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_2048_4095_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_256_511_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_4096_8191_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_512_1023_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_64_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_65_127_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_8192_9215_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_bad_fcs_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_large_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_packet_small_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_received_local_fault_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_remote_fault_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_status_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_test_pattern_mismatch_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_toolong_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_total_good_packets_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_truncated_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_undersize_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_rx_valid_ctrl_code_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_bad_fcs_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_frame_error_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_local_fault_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_1024_1518_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_128_255_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_1519_1522_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_1523_1548_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_1549_2047_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_2048_4095_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_256_511_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_4096_8191_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_512_1023_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_64_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_65_127_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_8192_9215_bytes_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_large_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_packet_small_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_total_good_packets_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_stat_tx_total_packets_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_tx_unfout_0_UNCONNECTED : STD_LOGIC;
  signal NLW_xxv_ethernet_0_rx_preambleout_0_UNCONNECTED : STD_LOGIC_VECTOR ( 55 downto 0 );
  signal NLW_xxv_ethernet_0_stat_rx_bad_fcs_0_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_xxv_ethernet_0_stat_rx_stomped_fcs_0_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_xxv_ethernet_0_stat_rx_total_bytes_0_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_xxv_ethernet_0_stat_rx_total_good_bytes_0_UNCONNECTED : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal NLW_xxv_ethernet_0_stat_rx_total_packets_0_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_xxv_ethernet_0_stat_tx_total_bytes_0_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_xxv_ethernet_0_stat_tx_total_good_bytes_0_UNCONNECTED : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal NLW_zynq_ultra_ps_e_0_maxigp2_aruser_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_zynq_ultra_ps_e_0_maxigp2_awuser_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
begin
  gt_ref_clk_1_CLK_N <= gt_ref_clk_clk_n;
  gt_ref_clk_1_CLK_P <= gt_ref_clk_clk_p;
  gt_rtl_gtx_n(0) <= xxv_ethernet_0_gt_serial_port_GTX_N(0);
  gt_rtl_gtx_p(0) <= xxv_ethernet_0_gt_serial_port_GTX_P(0);
  sfp_tx_dis(0) <= xlconstant_2_dout(0);
  xxv_ethernet_0_gt_serial_port_GRX_N(0) <= gt_rtl_grx_n(0);
  xxv_ethernet_0_gt_serial_port_GRX_P(0) <= gt_rtl_grx_p(0);
XilinxSwitch_0: component design_1_XilinxSwitch_0_0
     port map (
      clk_line => M00_AXIS_ACLK_1,
      clk_line_rst => proc_sys_reset_1_peripheral_reset(0),
      enable_processing(0) => xlconstant_3_dout(0),
      internal_rst_done(0) => NLW_XilinxSwitch_0_internal_rst_done_UNCONNECTED(0),
      packet_in_packet_in_TDATA(63 downto 0) => axis_interconnect_0_M00_AXIS_TDATA(63 downto 0),
      packet_in_packet_in_TKEEP(7 downto 0) => axis_interconnect_0_M00_AXIS_TKEEP(7 downto 0),
      packet_in_packet_in_TLAST(0) => axis_interconnect_0_M00_AXIS_TLAST,
      packet_in_packet_in_TREADY(0) => axis_interconnect_0_M00_AXIS_TREADY(0),
      packet_in_packet_in_TVALID(0) => axis_interconnect_0_M00_AXIS_TVALID,
      packet_out_packet_out_TDATA(63 downto 0) => XilinxSwitch_0_packet_out_packet_out_TDATA(63 downto 0),
      packet_out_packet_out_TKEEP(7 downto 0) => XilinxSwitch_0_packet_out_packet_out_TKEEP(7 downto 0),
      packet_out_packet_out_TLAST(0) => XilinxSwitch_0_packet_out_packet_out_TLAST(0),
      packet_out_packet_out_TREADY(0) => XilinxSwitch_0_packet_out_packet_out_TREADY,
      packet_out_packet_out_TVALID(0) => XilinxSwitch_0_packet_out_packet_out_TVALID(0),
      tuple_in_unused_DATA(0) => '0',
      tuple_in_unused_VALID(0) => '0',
      tuple_out_unused_DATA(0) => NLW_XilinxSwitch_0_tuple_out_unused_DATA_UNCONNECTED(0),
      tuple_out_unused_VALID(0) => NLW_XilinxSwitch_0_tuple_out_unused_VALID_UNCONNECTED(0)
    );
axi_interconnect_0: entity work.design_1_axi_interconnect_0_0
     port map (
      ACLK => zynq_ultra_ps_e_0_pl_clk0,
      ARESETN => ARESETN_1(0),
      M00_ACLK => zynq_ultra_ps_e_0_pl_clk0,
      M00_ARESETN => proc_sys_reset_0_peripheral_aresetn(0),
      M00_AXI_araddr(39 downto 0) => axi_interconnect_0_M00_AXI_ARADDR(39 downto 0),
      M00_AXI_arready => axi_interconnect_0_M00_AXI_ARREADY,
      M00_AXI_arvalid => axi_interconnect_0_M00_AXI_ARVALID,
      M00_AXI_awaddr(39 downto 0) => axi_interconnect_0_M00_AXI_AWADDR(39 downto 0),
      M00_AXI_awready => axi_interconnect_0_M00_AXI_AWREADY,
      M00_AXI_awvalid => axi_interconnect_0_M00_AXI_AWVALID,
      M00_AXI_bready => axi_interconnect_0_M00_AXI_BREADY,
      M00_AXI_bresp(1 downto 0) => axi_interconnect_0_M00_AXI_BRESP(1 downto 0),
      M00_AXI_bvalid => axi_interconnect_0_M00_AXI_BVALID,
      M00_AXI_rdata(31 downto 0) => axi_interconnect_0_M00_AXI_RDATA(31 downto 0),
      M00_AXI_rready => axi_interconnect_0_M00_AXI_RREADY,
      M00_AXI_rresp(1 downto 0) => axi_interconnect_0_M00_AXI_RRESP(1 downto 0),
      M00_AXI_rvalid => axi_interconnect_0_M00_AXI_RVALID,
      M00_AXI_wdata(31 downto 0) => axi_interconnect_0_M00_AXI_WDATA(31 downto 0),
      M00_AXI_wready => axi_interconnect_0_M00_AXI_WREADY,
      M00_AXI_wstrb(3 downto 0) => axi_interconnect_0_M00_AXI_WSTRB(3 downto 0),
      M00_AXI_wvalid => axi_interconnect_0_M00_AXI_WVALID,
      S00_ACLK => zynq_ultra_ps_e_0_pl_clk0,
      S00_ARESETN => proc_sys_reset_0_peripheral_aresetn(0),
      S00_AXI_araddr(39 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARADDR(39 downto 0),
      S00_AXI_arburst(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARBURST(1 downto 0),
      S00_AXI_arcache(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARCACHE(3 downto 0),
      S00_AXI_arid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARID(15 downto 0),
      S00_AXI_arlen(7 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARLEN(7 downto 0),
      S00_AXI_arlock => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARLOCK,
      S00_AXI_arprot(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARPROT(2 downto 0),
      S00_AXI_arqos(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARQOS(3 downto 0),
      S00_AXI_arready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARREADY,
      S00_AXI_arsize(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARSIZE(2 downto 0),
      S00_AXI_arvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARVALID,
      S00_AXI_awaddr(39 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWADDR(39 downto 0),
      S00_AXI_awburst(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWBURST(1 downto 0),
      S00_AXI_awcache(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWCACHE(3 downto 0),
      S00_AXI_awid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWID(15 downto 0),
      S00_AXI_awlen(7 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWLEN(7 downto 0),
      S00_AXI_awlock => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWLOCK,
      S00_AXI_awprot(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWPROT(2 downto 0),
      S00_AXI_awqos(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWQOS(3 downto 0),
      S00_AXI_awready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWREADY,
      S00_AXI_awsize(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWSIZE(2 downto 0),
      S00_AXI_awvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWVALID,
      S00_AXI_bid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BID(15 downto 0),
      S00_AXI_bready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BREADY,
      S00_AXI_bresp(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BRESP(1 downto 0),
      S00_AXI_bvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BVALID,
      S00_AXI_rdata(127 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RDATA(127 downto 0),
      S00_AXI_rid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RID(15 downto 0),
      S00_AXI_rlast => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RLAST,
      S00_AXI_rready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RREADY,
      S00_AXI_rresp(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RRESP(1 downto 0),
      S00_AXI_rvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RVALID,
      S00_AXI_wdata(127 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WDATA(127 downto 0),
      S00_AXI_wlast => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WLAST,
      S00_AXI_wready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WREADY,
      S00_AXI_wstrb(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WSTRB(15 downto 0),
      S00_AXI_wvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WVALID
    );
axis_interconnect_0: entity work.design_1_axis_interconnect_0_0
     port map (
      ACLK => M00_AXIS_ACLK_1,
      ARESETN => proc_sys_reset_1_interconnect_aresetn(0),
      M00_AXIS_ACLK => M00_AXIS_ACLK_1,
      M00_AXIS_ARESETN => proc_sys_reset_1_peripheral_aresetn(0),
      M00_AXIS_tdata(63 downto 0) => axis_interconnect_0_M00_AXIS_TDATA(63 downto 0),
      M00_AXIS_tkeep(7 downto 0) => axis_interconnect_0_M00_AXIS_TKEEP(7 downto 0),
      M00_AXIS_tlast => axis_interconnect_0_M00_AXIS_TLAST,
      M00_AXIS_tready => axis_interconnect_0_M00_AXIS_TREADY(0),
      M00_AXIS_tvalid => axis_interconnect_0_M00_AXIS_TVALID,
      S00_AXIS_ACLK => xxv_ethernet_0_rx_clk_out_0,
      S00_AXIS_ARESETN => util_vector_logic_1_Res(0),
      S00_AXIS_tdata(63 downto 0) => S00_AXIS_1_TDATA(63 downto 0),
      S00_AXIS_tkeep(7 downto 0) => S00_AXIS_1_TKEEP(7 downto 0),
      S00_AXIS_tlast => S00_AXIS_1_TLAST,
      S00_AXIS_tuser => S00_AXIS_1_TUSER,
      S00_AXIS_tvalid => S00_AXIS_1_TVALID
    );
axis_interconnect_1: entity work.design_1_axis_interconnect_1_0
     port map (
      ACLK => M00_AXIS_ACLK_1,
      ARESETN => proc_sys_reset_1_interconnect_aresetn(0),
      M00_AXIS_ACLK => M00_AXIS_ACLK_2,
      M00_AXIS_ARESETN => M00_AXIS_ARESETN_1(0),
      M00_AXIS_tdata(63 downto 0) => axis_interconnect_1_M00_AXIS_TDATA(63 downto 0),
      M00_AXIS_tkeep(7 downto 0) => axis_interconnect_1_M00_AXIS_TKEEP(7 downto 0),
      M00_AXIS_tlast => axis_interconnect_1_M00_AXIS_TLAST,
      M00_AXIS_tready => axis_interconnect_1_M00_AXIS_TREADY,
      M00_AXIS_tuser => axis_interconnect_1_M00_AXIS_TUSER,
      M00_AXIS_tvalid => axis_interconnect_1_M00_AXIS_TVALID,
      S00_AXIS_ACLK => M00_AXIS_ACLK_1,
      S00_AXIS_ARESETN => proc_sys_reset_1_peripheral_aresetn(0),
      S00_AXIS_tdata(63 downto 0) => XilinxSwitch_0_packet_out_packet_out_TDATA(63 downto 0),
      S00_AXIS_tkeep(7 downto 0) => XilinxSwitch_0_packet_out_packet_out_TKEEP(7 downto 0),
      S00_AXIS_tlast => XilinxSwitch_0_packet_out_packet_out_TLAST(0),
      S00_AXIS_tready => XilinxSwitch_0_packet_out_packet_out_TREADY,
      S00_AXIS_tvalid => XilinxSwitch_0_packet_out_packet_out_TVALID(0)
    );
proc_sys_reset_0: component design_1_proc_sys_reset_0_0
     port map (
      aux_reset_in => '1',
      bus_struct_reset(0) => NLW_proc_sys_reset_0_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => '1',
      ext_reset_in => zynq_ultra_ps_e_0_pl_resetn0,
      interconnect_aresetn(0) => ARESETN_1(0),
      mb_debug_sys_rst => '0',
      mb_reset => NLW_proc_sys_reset_0_mb_reset_UNCONNECTED,
      peripheral_aresetn(0) => proc_sys_reset_0_peripheral_aresetn(0),
      peripheral_reset(0) => proc_sys_reset_0_peripheral_reset(0),
      slowest_sync_clk => zynq_ultra_ps_e_0_pl_clk0
    );
proc_sys_reset_1: component design_1_proc_sys_reset_1_0
     port map (
      aux_reset_in => '1',
      bus_struct_reset(0) => NLW_proc_sys_reset_1_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => '1',
      ext_reset_in => zynq_ultra_ps_e_0_pl_resetn0,
      interconnect_aresetn(0) => proc_sys_reset_1_interconnect_aresetn(0),
      mb_debug_sys_rst => '0',
      mb_reset => NLW_proc_sys_reset_1_mb_reset_UNCONNECTED,
      peripheral_aresetn(0) => proc_sys_reset_1_peripheral_aresetn(0),
      peripheral_reset(0) => proc_sys_reset_1_peripheral_reset(0),
      slowest_sync_clk => M00_AXIS_ACLK_1
    );
system_ila_0: component design_1_system_ila_0_0
     port map (
      SLOT_0_AXIS_tdata(63 downto 0) => S00_AXIS_1_TDATA(63 downto 0),
      SLOT_0_AXIS_tkeep(7 downto 0) => S00_AXIS_1_TKEEP(7 downto 0),
      SLOT_0_AXIS_tlast => S00_AXIS_1_TLAST,
      SLOT_0_AXIS_tuser(0) => S00_AXIS_1_TUSER,
      SLOT_0_AXIS_tvalid => S00_AXIS_1_TVALID,
      clk => xxv_ethernet_0_rx_clk_out_0,
      probe0(0) => util_vector_logic_0_Res(0),
      probe1(0) => proc_sys_reset_0_peripheral_reset(0),
      probe2(0) => proc_sys_reset_0_peripheral_aresetn(0),
      resetn => util_vector_logic_1_Res(0)
    );
util_vector_logic_0: component design_1_util_vector_logic_0_0
     port map (
      Op1(0) => zynq_ultra_ps_e_0_pl_resetn0,
      Res(0) => util_vector_logic_0_Res(0)
    );
util_vector_logic_1: component design_1_util_vector_logic_1_0
     port map (
      Op1(0) => xxv_ethernet_0_user_rx_reset_0,
      Res(0) => util_vector_logic_1_Res(0)
    );
util_vector_logic_2: component design_1_util_vector_logic_2_0
     port map (
      Op1(0) => xxv_ethernet_0_user_tx_reset_0,
      Res(0) => M00_AXIS_ARESETN_1(0)
    );
xlconstant_0: component design_1_xlconstant_0_0
     port map (
      dout(0) => xlconstant_0_dout(0)
    );
xlconstant_1: component design_1_xlconstant_1_0
     port map (
      dout(55 downto 0) => xlconstant_1_dout(55 downto 0)
    );
xlconstant_2: component design_1_xlconstant_2_0
     port map (
      dout(0) => xlconstant_2_dout(0)
    );
xlconstant_3: component design_1_xlconstant_3_0
     port map (
      dout(0) => xlconstant_3_dout(0)
    );
xxv_ethernet_0: component design_1_xxv_ethernet_0_0
     port map (
      ctl_tx_send_idle_0 => xlconstant_0_dout(0),
      ctl_tx_send_lfi_0 => xlconstant_0_dout(0),
      ctl_tx_send_rfi_0 => xlconstant_0_dout(0),
      dclk => zynq_ultra_ps_e_0_pl_clk0,
      gt_refclk_n => gt_ref_clk_1_CLK_N,
      gt_refclk_out => NLW_xxv_ethernet_0_gt_refclk_out_UNCONNECTED,
      gt_refclk_p => gt_ref_clk_1_CLK_P,
      gt_rxn_in(0) => xxv_ethernet_0_gt_serial_port_GRX_N(0),
      gt_rxp_in(0) => xxv_ethernet_0_gt_serial_port_GRX_P(0),
      gt_txn_out(0) => xxv_ethernet_0_gt_serial_port_GTX_N(0),
      gt_txp_out(0) => xxv_ethernet_0_gt_serial_port_GTX_P(0),
      gtwiz_reset_rx_datapath_0 => util_vector_logic_0_Res(0),
      gtwiz_reset_tx_datapath_0 => util_vector_logic_0_Res(0),
      pm_tick_0 => '0',
      rx_axis_tdata_0(63 downto 0) => S00_AXIS_1_TDATA(63 downto 0),
      rx_axis_tkeep_0(7 downto 0) => S00_AXIS_1_TKEEP(7 downto 0),
      rx_axis_tlast_0 => S00_AXIS_1_TLAST,
      rx_axis_tuser_0 => S00_AXIS_1_TUSER,
      rx_axis_tvalid_0 => S00_AXIS_1_TVALID,
      rx_clk_out_0 => xxv_ethernet_0_rx_clk_out_0,
      rx_core_clk_0 => xxv_ethernet_0_rx_clk_out_0,
      rx_preambleout_0(55 downto 0) => NLW_xxv_ethernet_0_rx_preambleout_0_UNCONNECTED(55 downto 0),
      rx_reset_0 => util_vector_logic_0_Res(0),
      rxrecclkout_0 => NLW_xxv_ethernet_0_rxrecclkout_0_UNCONNECTED,
      s_axi_aclk_0 => zynq_ultra_ps_e_0_pl_clk0,
      s_axi_araddr_0(31 downto 0) => axi_interconnect_0_M00_AXI_ARADDR(31 downto 0),
      s_axi_aresetn_0 => proc_sys_reset_0_peripheral_aresetn(0),
      s_axi_arready_0 => axi_interconnect_0_M00_AXI_ARREADY,
      s_axi_arvalid_0 => axi_interconnect_0_M00_AXI_ARVALID,
      s_axi_awaddr_0(31 downto 0) => axi_interconnect_0_M00_AXI_AWADDR(31 downto 0),
      s_axi_awready_0 => axi_interconnect_0_M00_AXI_AWREADY,
      s_axi_awvalid_0 => axi_interconnect_0_M00_AXI_AWVALID,
      s_axi_bready_0 => axi_interconnect_0_M00_AXI_BREADY,
      s_axi_bresp_0(1 downto 0) => axi_interconnect_0_M00_AXI_BRESP(1 downto 0),
      s_axi_bvalid_0 => axi_interconnect_0_M00_AXI_BVALID,
      s_axi_rdata_0(31 downto 0) => axi_interconnect_0_M00_AXI_RDATA(31 downto 0),
      s_axi_rready_0 => axi_interconnect_0_M00_AXI_RREADY,
      s_axi_rresp_0(1 downto 0) => axi_interconnect_0_M00_AXI_RRESP(1 downto 0),
      s_axi_rvalid_0 => axi_interconnect_0_M00_AXI_RVALID,
      s_axi_wdata_0(31 downto 0) => axi_interconnect_0_M00_AXI_WDATA(31 downto 0),
      s_axi_wready_0 => axi_interconnect_0_M00_AXI_WREADY,
      s_axi_wstrb_0(3 downto 0) => axi_interconnect_0_M00_AXI_WSTRB(3 downto 0),
      s_axi_wvalid_0 => axi_interconnect_0_M00_AXI_WVALID,
      stat_rx_bad_code_0 => NLW_xxv_ethernet_0_stat_rx_bad_code_0_UNCONNECTED,
      stat_rx_bad_fcs_0(1 downto 0) => NLW_xxv_ethernet_0_stat_rx_bad_fcs_0_UNCONNECTED(1 downto 0),
      stat_rx_bad_preamble_0 => NLW_xxv_ethernet_0_stat_rx_bad_preamble_0_UNCONNECTED,
      stat_rx_bad_sfd_0 => NLW_xxv_ethernet_0_stat_rx_bad_sfd_0_UNCONNECTED,
      stat_rx_block_lock_0 => NLW_xxv_ethernet_0_stat_rx_block_lock_0_UNCONNECTED,
      stat_rx_fragment_0 => NLW_xxv_ethernet_0_stat_rx_fragment_0_UNCONNECTED,
      stat_rx_framing_err_0 => NLW_xxv_ethernet_0_stat_rx_framing_err_0_UNCONNECTED,
      stat_rx_framing_err_valid_0 => NLW_xxv_ethernet_0_stat_rx_framing_err_valid_0_UNCONNECTED,
      stat_rx_got_signal_os_0 => NLW_xxv_ethernet_0_stat_rx_got_signal_os_0_UNCONNECTED,
      stat_rx_hi_ber_0 => NLW_xxv_ethernet_0_stat_rx_hi_ber_0_UNCONNECTED,
      stat_rx_internal_local_fault_0 => NLW_xxv_ethernet_0_stat_rx_internal_local_fault_0_UNCONNECTED,
      stat_rx_jabber_0 => NLW_xxv_ethernet_0_stat_rx_jabber_0_UNCONNECTED,
      stat_rx_local_fault_0 => NLW_xxv_ethernet_0_stat_rx_local_fault_0_UNCONNECTED,
      stat_rx_oversize_0 => NLW_xxv_ethernet_0_stat_rx_oversize_0_UNCONNECTED,
      stat_rx_packet_1024_1518_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_1024_1518_bytes_0_UNCONNECTED,
      stat_rx_packet_128_255_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_128_255_bytes_0_UNCONNECTED,
      stat_rx_packet_1519_1522_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_1519_1522_bytes_0_UNCONNECTED,
      stat_rx_packet_1523_1548_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_1523_1548_bytes_0_UNCONNECTED,
      stat_rx_packet_1549_2047_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_1549_2047_bytes_0_UNCONNECTED,
      stat_rx_packet_2048_4095_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_2048_4095_bytes_0_UNCONNECTED,
      stat_rx_packet_256_511_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_256_511_bytes_0_UNCONNECTED,
      stat_rx_packet_4096_8191_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_4096_8191_bytes_0_UNCONNECTED,
      stat_rx_packet_512_1023_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_512_1023_bytes_0_UNCONNECTED,
      stat_rx_packet_64_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_64_bytes_0_UNCONNECTED,
      stat_rx_packet_65_127_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_65_127_bytes_0_UNCONNECTED,
      stat_rx_packet_8192_9215_bytes_0 => NLW_xxv_ethernet_0_stat_rx_packet_8192_9215_bytes_0_UNCONNECTED,
      stat_rx_packet_bad_fcs_0 => NLW_xxv_ethernet_0_stat_rx_packet_bad_fcs_0_UNCONNECTED,
      stat_rx_packet_large_0 => NLW_xxv_ethernet_0_stat_rx_packet_large_0_UNCONNECTED,
      stat_rx_packet_small_0 => NLW_xxv_ethernet_0_stat_rx_packet_small_0_UNCONNECTED,
      stat_rx_received_local_fault_0 => NLW_xxv_ethernet_0_stat_rx_received_local_fault_0_UNCONNECTED,
      stat_rx_remote_fault_0 => NLW_xxv_ethernet_0_stat_rx_remote_fault_0_UNCONNECTED,
      stat_rx_status_0 => NLW_xxv_ethernet_0_stat_rx_status_0_UNCONNECTED,
      stat_rx_stomped_fcs_0(1 downto 0) => NLW_xxv_ethernet_0_stat_rx_stomped_fcs_0_UNCONNECTED(1 downto 0),
      stat_rx_test_pattern_mismatch_0 => NLW_xxv_ethernet_0_stat_rx_test_pattern_mismatch_0_UNCONNECTED,
      stat_rx_toolong_0 => NLW_xxv_ethernet_0_stat_rx_toolong_0_UNCONNECTED,
      stat_rx_total_bytes_0(3 downto 0) => NLW_xxv_ethernet_0_stat_rx_total_bytes_0_UNCONNECTED(3 downto 0),
      stat_rx_total_good_bytes_0(13 downto 0) => NLW_xxv_ethernet_0_stat_rx_total_good_bytes_0_UNCONNECTED(13 downto 0),
      stat_rx_total_good_packets_0 => NLW_xxv_ethernet_0_stat_rx_total_good_packets_0_UNCONNECTED,
      stat_rx_total_packets_0(1 downto 0) => NLW_xxv_ethernet_0_stat_rx_total_packets_0_UNCONNECTED(1 downto 0),
      stat_rx_truncated_0 => NLW_xxv_ethernet_0_stat_rx_truncated_0_UNCONNECTED,
      stat_rx_undersize_0 => NLW_xxv_ethernet_0_stat_rx_undersize_0_UNCONNECTED,
      stat_rx_valid_ctrl_code_0 => NLW_xxv_ethernet_0_stat_rx_valid_ctrl_code_0_UNCONNECTED,
      stat_tx_bad_fcs_0 => NLW_xxv_ethernet_0_stat_tx_bad_fcs_0_UNCONNECTED,
      stat_tx_frame_error_0 => NLW_xxv_ethernet_0_stat_tx_frame_error_0_UNCONNECTED,
      stat_tx_local_fault_0 => NLW_xxv_ethernet_0_stat_tx_local_fault_0_UNCONNECTED,
      stat_tx_packet_1024_1518_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_1024_1518_bytes_0_UNCONNECTED,
      stat_tx_packet_128_255_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_128_255_bytes_0_UNCONNECTED,
      stat_tx_packet_1519_1522_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_1519_1522_bytes_0_UNCONNECTED,
      stat_tx_packet_1523_1548_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_1523_1548_bytes_0_UNCONNECTED,
      stat_tx_packet_1549_2047_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_1549_2047_bytes_0_UNCONNECTED,
      stat_tx_packet_2048_4095_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_2048_4095_bytes_0_UNCONNECTED,
      stat_tx_packet_256_511_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_256_511_bytes_0_UNCONNECTED,
      stat_tx_packet_4096_8191_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_4096_8191_bytes_0_UNCONNECTED,
      stat_tx_packet_512_1023_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_512_1023_bytes_0_UNCONNECTED,
      stat_tx_packet_64_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_64_bytes_0_UNCONNECTED,
      stat_tx_packet_65_127_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_65_127_bytes_0_UNCONNECTED,
      stat_tx_packet_8192_9215_bytes_0 => NLW_xxv_ethernet_0_stat_tx_packet_8192_9215_bytes_0_UNCONNECTED,
      stat_tx_packet_large_0 => NLW_xxv_ethernet_0_stat_tx_packet_large_0_UNCONNECTED,
      stat_tx_packet_small_0 => NLW_xxv_ethernet_0_stat_tx_packet_small_0_UNCONNECTED,
      stat_tx_total_bytes_0(3 downto 0) => NLW_xxv_ethernet_0_stat_tx_total_bytes_0_UNCONNECTED(3 downto 0),
      stat_tx_total_good_bytes_0(13 downto 0) => NLW_xxv_ethernet_0_stat_tx_total_good_bytes_0_UNCONNECTED(13 downto 0),
      stat_tx_total_good_packets_0 => NLW_xxv_ethernet_0_stat_tx_total_good_packets_0_UNCONNECTED,
      stat_tx_total_packets_0 => NLW_xxv_ethernet_0_stat_tx_total_packets_0_UNCONNECTED,
      sys_reset => proc_sys_reset_0_peripheral_reset(0),
      tx_axis_tdata_0(63 downto 0) => axis_interconnect_1_M00_AXIS_TDATA(63 downto 0),
      tx_axis_tkeep_0(7 downto 0) => axis_interconnect_1_M00_AXIS_TKEEP(7 downto 0),
      tx_axis_tlast_0 => axis_interconnect_1_M00_AXIS_TLAST,
      tx_axis_tready_0 => axis_interconnect_1_M00_AXIS_TREADY,
      tx_axis_tuser_0 => axis_interconnect_1_M00_AXIS_TUSER,
      tx_axis_tvalid_0 => axis_interconnect_1_M00_AXIS_TVALID,
      tx_clk_out_0 => M00_AXIS_ACLK_2,
      tx_preamblein_0(55 downto 0) => xlconstant_1_dout(55 downto 0),
      tx_reset_0 => util_vector_logic_0_Res(0),
      tx_unfout_0 => NLW_xxv_ethernet_0_tx_unfout_0_UNCONNECTED,
      user_rx_reset_0 => xxv_ethernet_0_user_rx_reset_0,
      user_tx_reset_0 => xxv_ethernet_0_user_tx_reset_0
    );
zynq_ultra_ps_e_0: component design_1_zynq_ultra_ps_e_0_0
     port map (
      maxigp2_araddr(39 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARADDR(39 downto 0),
      maxigp2_arburst(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARBURST(1 downto 0),
      maxigp2_arcache(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARCACHE(3 downto 0),
      maxigp2_arid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARID(15 downto 0),
      maxigp2_arlen(7 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARLEN(7 downto 0),
      maxigp2_arlock => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARLOCK,
      maxigp2_arprot(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARPROT(2 downto 0),
      maxigp2_arqos(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARQOS(3 downto 0),
      maxigp2_arready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARREADY,
      maxigp2_arsize(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARSIZE(2 downto 0),
      maxigp2_aruser(15 downto 0) => NLW_zynq_ultra_ps_e_0_maxigp2_aruser_UNCONNECTED(15 downto 0),
      maxigp2_arvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_ARVALID,
      maxigp2_awaddr(39 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWADDR(39 downto 0),
      maxigp2_awburst(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWBURST(1 downto 0),
      maxigp2_awcache(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWCACHE(3 downto 0),
      maxigp2_awid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWID(15 downto 0),
      maxigp2_awlen(7 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWLEN(7 downto 0),
      maxigp2_awlock => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWLOCK,
      maxigp2_awprot(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWPROT(2 downto 0),
      maxigp2_awqos(3 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWQOS(3 downto 0),
      maxigp2_awready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWREADY,
      maxigp2_awsize(2 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWSIZE(2 downto 0),
      maxigp2_awuser(15 downto 0) => NLW_zynq_ultra_ps_e_0_maxigp2_awuser_UNCONNECTED(15 downto 0),
      maxigp2_awvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_AWVALID,
      maxigp2_bid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BID(15 downto 0),
      maxigp2_bready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BREADY,
      maxigp2_bresp(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BRESP(1 downto 0),
      maxigp2_bvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_BVALID,
      maxigp2_rdata(127 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RDATA(127 downto 0),
      maxigp2_rid(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RID(15 downto 0),
      maxigp2_rlast => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RLAST,
      maxigp2_rready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RREADY,
      maxigp2_rresp(1 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RRESP(1 downto 0),
      maxigp2_rvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_RVALID,
      maxigp2_wdata(127 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WDATA(127 downto 0),
      maxigp2_wlast => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WLAST,
      maxigp2_wready => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WREADY,
      maxigp2_wstrb(15 downto 0) => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WSTRB(15 downto 0),
      maxigp2_wvalid => zynq_ultra_ps_e_0_M_AXI_HPM0_LPD_WVALID,
      maxihpm0_lpd_aclk => zynq_ultra_ps_e_0_pl_clk0,
      pl_clk0 => zynq_ultra_ps_e_0_pl_clk0,
      pl_clk1 => M00_AXIS_ACLK_1,
      pl_resetn0 => zynq_ultra_ps_e_0_pl_resetn0
    );
end STRUCTURE;
