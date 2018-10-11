library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity Testbench is
end Testbench;

architecture TB of Testbench is

  component PacketDropper
	generic (
		C_aximm_DATA_WIDTH  : integer	:= 32;
		C_aximm_ADDR_WIDTH  : integer	:= 4;
		C_axis_in_TDATA_WIDTH  : integer	:= 64;
		C_axis_out_TDATA_WIDTH : integer	:= 64
	);
	port (
		aximm_aclk	: in std_logic;
		aximm_aresetn	: in std_logic;
		aximm_awaddr	: in std_logic_vector(C_aximm_ADDR_WIDTH-1 downto 0);
		aximm_awprot	: in std_logic_vector(2 downto 0);
		aximm_awvalid	: in std_logic;
		aximm_awready	: out std_logic;
		aximm_wdata	: in std_logic_vector(C_aximm_DATA_WIDTH-1 downto 0);
		aximm_wstrb	: in std_logic_vector((C_aximm_DATA_WIDTH/8)-1 downto 0);
		aximm_wvalid	: in std_logic;
		aximm_wready	: out std_logic;
		aximm_bresp	: out std_logic_vector(1 downto 0);
		aximm_bvalid	: out std_logic;
		aximm_bready	: in std_logic;
		aximm_araddr	: in std_logic_vector(C_aximm_ADDR_WIDTH-1 downto 0);
		aximm_arprot	: in std_logic_vector(2 downto 0);
		aximm_arvalid	: in std_logic;
		aximm_arready	: out std_logic;
		aximm_rdata	: out std_logic_vector(C_aximm_DATA_WIDTH-1 downto 0);
		aximm_rresp	: out std_logic_vector(1 downto 0);
		aximm_rvalid	: out std_logic;
		aximm_rready	: in std_logic;

		axis_in_aclk	: in std_logic;
		axis_in_aresetn	: in std_logic;
		axis_in_tready	: out std_logic;
		axis_in_tdata	: in std_logic_vector(C_axis_in_TDATA_WIDTH-1 downto 0);
		axis_in_tkeep	: in std_logic_vector((C_axis_in_TDATA_WIDTH/8)-1 downto 0);
		axis_in_tlast	: in std_logic;
		axis_in_tvalid	: in std_logic;

		axis_out_aclk	: in std_logic;
		axis_out_aresetn	: in std_logic;
		axis_out_tvalid	: out std_logic;
		axis_out_tdata	: out std_logic_vector(C_axis_out_TDATA_WIDTH-1 downto 0);
		axis_out_tkeep	: out std_logic_vector((C_axis_out_TDATA_WIDTH/8)-1 downto 0);
		axis_out_tlast	: out std_logic;
		axis_out_tready	: in std_logic
	);
  end component;
  
  signal clk : std_logic := '0';

  signal aximm_aclk	: std_logic;
  signal aximm_aresetn : std_logic := '0';
  signal aximm_awaddr  : std_logic_vector(3 downto 0) := (others => '0');
  signal aximm_awprot  : std_logic_vector(2 downto 0) := (others => '0');
  signal aximm_awvalid : std_logic := '0';
  signal aximm_awready : std_logic;
  signal aximm_wdata   : std_logic_vector(31 downto 0) := (others => '0');
  signal aximm_wstrb   : std_logic_vector(3 downto 0) := (others => '0');
  signal aximm_wvalid  : std_logic := '0';
  signal aximm_wready  : std_logic;
  signal aximm_bresp   : std_logic_vector(1 downto 0);
  signal aximm_bvalid  : std_logic;
  signal aximm_bready  : std_logic := '0';
  signal aximm_araddr  : std_logic_vector(3 downto 0) := (others => '0');
  signal aximm_arprot  : std_logic_vector(2 downto 0) := (others => '0');
  signal aximm_arvalid : std_logic := '0';
  signal aximm_arready : std_logic;
  signal aximm_rdata   : std_logic_vector(31 downto 0);
  signal aximm_rresp   : std_logic_vector(1 downto 0);
  signal aximm_rvalid  : std_logic;
  signal aximm_rready  : std_logic := '0';

  signal axis_in_aclk    : std_logic;
  signal axis_in_aresetn : std_logic := '0';
  signal axis_in_tready  : std_logic;
  signal axis_in_tdata   : std_logic_vector(63 downto 0) := (others => '0');
  signal axis_in_tkeep   : std_logic_vector(7 downto 0) := (others => '0');
  signal axis_in_tlast   : std_logic := '0';
  signal axis_in_tvalid  : std_logic := '0';

  signal axis_out_aclk    : std_logic;
  signal axis_out_aresetn : std_logic := '0';
  signal axis_out_tvalid  : std_logic;
  signal axis_out_tdata   : std_logic_vector(63 downto 0);
  signal axis_out_tkeep   : std_logic_vector(7 downto 0);
  signal axis_out_tlast   : std_logic;
  signal axis_out_tready  : std_logic := '0';
  
begin

  i_PacketDropper: PacketDropper
    port map
    (
      aximm_aclk    => aximm_aclk,
      aximm_aresetn => aximm_aresetn,
      aximm_awaddr  => aximm_awaddr,
      aximm_awprot  => aximm_awprot,
      aximm_awvalid => aximm_awvalid,
      aximm_awready => aximm_awready,
      aximm_wdata   => aximm_wdata,
      aximm_wstrb   => aximm_wstrb,
      aximm_wvalid  => aximm_wvalid,
      aximm_wready  => aximm_wready,
      aximm_bresp   => aximm_bresp,
      aximm_bvalid  => aximm_bvalid,
      aximm_bready  => aximm_bready,
      aximm_araddr  => aximm_araddr,
      aximm_arprot  => aximm_arprot,
      aximm_arvalid => aximm_arvalid,
      aximm_arready => aximm_arready,
      aximm_rdata   => aximm_rdata,
      aximm_rresp   => aximm_rresp,
      aximm_rvalid  => aximm_rvalid,
      aximm_rready  => aximm_rready,  
      axis_in_aclk    => axis_in_aclk,
      axis_in_aresetn => axis_in_aresetn,
      axis_in_tready  => axis_in_tready,
      axis_in_tdata   => axis_in_tdata,
      axis_in_tkeep   => axis_in_tkeep,
      axis_in_tlast   => axis_in_tlast,
      axis_in_tvalid  => axis_in_tvalid,
      axis_out_aclk    => axis_out_aclk,
      axis_out_aresetn => axis_out_aresetn,
      axis_out_tvalid  => axis_out_tvalid,
      axis_out_tdata   => axis_out_tdata,
      axis_out_tkeep   => axis_out_tkeep,
      axis_out_tlast   => axis_out_tlast,
      axis_out_tready  => axis_out_tready
    );
    
  p_clk: process
  begin
    wait for 6.4 ns;
    clk <= not clk;
  end process;
  
  aximm_aclk <= clk;
  axis_in_aclk  <= clk;
  axis_out_aclk <= clk;

  p_stimulus: process
  begin
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    aximm_aresetn <= '1';
    axis_in_aresetn  <= '1';
    axis_out_aresetn <= '1';
    
    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    
    aximm_awaddr  <= x"0";
    aximm_wdata   <= x"19999999";
    aximm_wvalid  <= '1';
    aximm_awvalid <= '1';
    aximm_wstrb   <= "1111";
    wait until rising_edge(clk);
    aximm_wvalid  <= '0';
    aximm_awvalid <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk);
    end loop;
    
    loop
      for i in 1 to 10 loop
        axis_in_tvalid <= '1';
        axis_in_tdata  <= std_logic_vector(to_unsigned(i, 64));
        axis_in_tkeep  <= x"FF";
        axis_in_tlast  <= '0';
        if i = 10 then
          axis_in_tlast <= '1';
        end if;
        wait until rising_edge(clk);
        while axis_in_tready = '0' loop
          wait until rising_edge(clk);
        end loop;
      end loop;

      axis_in_tvalid <= '0';

      for i in 1 to 10 loop
        wait until rising_edge(clk);
      end loop;
    end loop;

    wait;

  end process;
  
  p_ready: process(aximm_aclk)
  begin
    if rising_edge(aximm_aclk) then
      if aximm_aresetn = '0' then
        axis_out_tready <= '0';
      else
        axis_out_tready <= not axis_out_tready;
      end if;
    end if;
  end process;

end TB;