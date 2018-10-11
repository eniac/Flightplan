library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PacketDropper is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface Config
		C_aximm_DATA_WIDTH	: integer	:= 32;
		C_aximm_ADDR_WIDTH	: integer	:= 4;

		-- Parameters of Axi Slave Bus Interface Input
		C_axis_in_TDATA_WIDTH	: integer	:= 64;

		-- Parameters of Axi Master Bus Interface Output
		C_axis_out_TDATA_WIDTH	: integer	:= 64
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface Config
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

		-- Ports of Axi Slave Bus Interface Input
		axis_in_aclk	: in std_logic;
		axis_in_aresetn	: in std_logic;
		axis_in_tready	: out std_logic;
		axis_in_tdata	: in std_logic_vector(C_axis_in_TDATA_WIDTH-1 downto 0);
		axis_in_tkeep	: in std_logic_vector((C_axis_in_TDATA_WIDTH/8)-1 downto 0);
		axis_in_tlast	: in std_logic;
		axis_in_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface Output
		axis_out_aclk	: in std_logic;
		axis_out_aresetn	: in std_logic;
		axis_out_tvalid	: out std_logic;
		axis_out_tdata	: out std_logic_vector(C_axis_out_TDATA_WIDTH-1 downto 0);
		axis_out_tkeep	: out std_logic_vector((C_axis_out_TDATA_WIDTH/8)-1 downto 0);
		axis_out_tlast	: out std_logic;
		axis_out_tready	: in std_logic
	);
end PacketDropper;

architecture arch_imp of PacketDropper is

	-- component declaration
	component PacketDropper_Config is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		threshold       : out std_logic_vector(31 downto 0);
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component PacketDropper_Config;

    component rng_trivium is
      generic (
        -- Number of output bits per clock cycle.
        -- Must be a power of two: either 1, 2, 4, 8, 16, 32 or 64.
        num_bits:   integer range 1 to 64;

        -- Default key.
        init_key:   std_logic_vector(79 downto 0);

        -- Default initialization vector.
        init_iv:    std_logic_vector(79 downto 0) );

      port (

        -- Clock, rising edge active.
        clk:        in  std_logic;

        -- Synchronous reset, active high.
        rst:        in  std_logic;

        -- High to request re-seeding of the generator.
        reseed:     in  std_logic;

        -- New key value (must be valid when reseed = '1').
        newkey:     in  std_logic_vector(79 downto 0);

        -- New initialization vector (must be valid when reseed = '1').
        newiv:      in  std_logic_vector(79 downto 0);

        -- High when the user accepts the current random data word
        -- and requests new random data for the next clock cycle.
        out_ready:  in  std_logic;

        -- High when valid random data is available on the output.
        -- This signal is low during the first (1152/num_bits) clock cycles
        -- after reset and after re-seeding, and high in all other cases.
        out_valid:  out std_logic;

        -- Random output data (valid when out_valid = '1').
        -- A new random word appears after every rising clock edge
        -- where out_ready = '1'.
        out_data:   out std_logic_vector(num_bits-1 downto 0) );
      end component;

    type state_type is (state_idle, state_output, state_drop);
    
	signal state          : state_type;
    signal next_state     : state_type;
    signal drop           : std_logic;
    signal random_value   : std_logic_vector(63 downto 0);
    signal threshold      : std_logic_vector(31 downto 0);
    signal rng_rst        : std_logic;
    signal drop_cnt       : std_logic_vector(31 downto 0);
    signal output_cnt     : std_logic_vector(31 downto 0);
    signal inc_drop_cnt   : std_logic;
    signal inc_output_cnt : std_logic;

begin

-- Instantiation of Axi Bus Interface Config
PacketDropper_aximm_inst : PacketDropper_Config
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_aximm_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_aximm_ADDR_WIDTH
	)
	port map (
	    threshold       => threshold,
		S_AXI_ACLK	=> aximm_aclk,
		S_AXI_ARESETN	=> aximm_aresetn,
		S_AXI_AWADDR	=> aximm_awaddr,
		S_AXI_AWPROT	=> aximm_awprot,
		S_AXI_AWVALID	=> aximm_awvalid,
		S_AXI_AWREADY	=> aximm_awready,
		S_AXI_WDATA	=> aximm_wdata,
		S_AXI_WSTRB	=> aximm_wstrb,
		S_AXI_WVALID	=> aximm_wvalid,
		S_AXI_WREADY	=> aximm_wready,
		S_AXI_BRESP	=> aximm_bresp,
		S_AXI_BVALID	=> aximm_bvalid,
		S_AXI_BREADY	=> aximm_bready,
		S_AXI_ARADDR	=> aximm_araddr,
		S_AXI_ARPROT	=> aximm_arprot,
		S_AXI_ARVALID	=> aximm_arvalid,
		S_AXI_ARREADY	=> aximm_arready,
		S_AXI_RDATA	=> aximm_rdata,
		S_AXI_RRESP	=> aximm_rresp,
		S_AXI_RVALID	=> aximm_rvalid,
		S_AXI_RREADY	=> aximm_rready
	);

	-- Add user logic here
  rng : rng_trivium
    generic map (
      num_bits => 64,
      init_key => (others => '0'),
      init_iv  => (others => '0')
    )
    port map (
      clk       => axis_in_aclk,
      rst       => rng_rst,
      reseed    => '0',
      newkey    => (others => '-'),
      newiv     => (others => '-'),
      out_ready => '1',
      out_valid => open,
      out_data  => random_value
    );

    p_fsm_sync: process(axis_in_aclk)
    begin
      if rising_edge(axis_in_aclk) then
        if axis_in_aresetn = '0' then
          state <= state_idle;
        else
          state <= next_state;
        end if;
      end if;
    end process;
    
    p_fsm_async: process(state, drop, axis_in_tlast, axis_in_tvalid, axis_out_tready)
    begin
      axis_out_tvalid <= '0';
      axis_in_tready  <= '0';
      inc_drop_cnt    <= '0';
      inc_output_cnt  <= '0';
      next_state      <= state;
  
      case state is
  
        when state_idle =>
          if drop = '0' then
            axis_out_tvalid <= axis_in_tvalid;
            axis_in_tready  <= axis_out_tready;
            inc_output_cnt <= '1';
            next_state    <= state_output;
          else 
            axis_out_tvalid <= '0';
            axis_in_tready  <= '1';
            inc_drop_cnt <= '1';
            next_state    <= state_drop;
          end if;
          
        when state_output =>
          axis_out_tvalid <= axis_in_tvalid;
          axis_in_tready  <= axis_out_tready;
          if axis_in_tlast = '1' and axis_in_tvalid = '1' and axis_out_tready = '1' then
            if drop = '1' then
              inc_drop_cnt <= '1';
              next_state <= state_drop;
            else
              inc_output_cnt <= '1';
            end if;
          end if;
          
        when state_drop =>
          axis_out_tvalid <= '0';
          axis_in_tready  <= '1';
          if axis_in_tlast = '1' and axis_in_tvalid = '1' then
            if drop = '0' then
              inc_output_cnt <= '1';
              next_state <= state_output;
            else
              inc_drop_cnt <= '1';
            end if;
          end if;
          
      end case;
    end process;
    
    drop <= '1' when unsigned(random_value(31 downto 0)) < unsigned(threshold) else '0';
    
    axis_out_tdata <= axis_in_tdata;
    axis_out_tkeep <= axis_in_tkeep;
    axis_out_tlast <= axis_in_tlast;
    
    rng_rst <= not axis_in_aresetn;

    p_drop_cnt: process(axis_in_aclk)
    begin
      if rising_edge(axis_in_aclk) then
        if axis_in_aresetn = '0' then
          drop_cnt <= (others => '0');
        elsif inc_drop_cnt = '1' then
          drop_cnt <= std_logic_vector(unsigned(drop_cnt) + 1);
        end if;
      end if;
    end process;

    p_output_cnt: process(axis_in_aclk)
    begin
      if rising_edge(axis_in_aclk) then
        if axis_in_aresetn = '0' then
          output_cnt <= (others => '0');
        elsif inc_output_cnt = '1' then
          output_cnt <= std_logic_vector(unsigned(output_cnt) + 1);
        end if;
      end if;
    end process;

	-- User logic ends

end arch_imp;
