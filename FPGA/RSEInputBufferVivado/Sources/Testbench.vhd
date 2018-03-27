library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity Testbench is
end Testbench;

architecture TB of Testbench is

  component RSEInputBuffer
    port
    (
      clk_line          : in  std_logic;
      clk_line_rst      : in  std_logic;
      enable_processing : in  std_logic;
      internal_rst_done : in  std_logic;
      axis_in_TVALID    : in  std_logic;
      axis_in_TREADY    : out std_logic;
      axis_in_TDATA     : in  std_logic_vector(63 downto 0);
      axis_in_TKEEP     : in  std_logic_vector(7 downto 0);
      axis_in_TLAST     : in  std_logic;
      axis_in_TUSER     : in  std_logic;
      axis_out_TVALID   : out std_logic;
      axis_out_TREADY   : in  std_logic;
      axis_out_TDATA    : out std_logic_vector(63 downto 0);
      axis_out_TKEEP    : out std_logic_vector(7 downto 0);
      axis_out_TLAST    : out std_logic
    );
  end component;

  signal clk_line          : std_logic := '0';
  signal clk_line_rst      : std_logic := '1';
  signal enable_processing : std_logic := '0';
  signal internal_rst_done : std_logic := '0';
  signal axis_in_TVALID    : std_logic := '0';
  signal axis_in_TREADY    : std_logic;
  signal axis_in_TDATA     : std_logic_vector(63 downto 0) := (others => '0');
  signal axis_in_TKEEP     : std_logic_vector(7 downto 0) := (others => '0');
  signal axis_in_TLAST     : std_logic := '0';
  signal axis_in_TUSER     : std_logic := '0';
  signal axis_out_TVALID   : std_logic;
  signal axis_out_TREADY   : std_logic := '0';
  signal axis_out_TDATA    : std_logic_vector(63 downto 0);
  signal axis_out_TKEEP    : std_logic_vector(7 downto 0);
  signal axis_out_TLAST    : std_logic;

begin

  InputBuffer: RSEInputBuffer
    port map
    (
      clk_line          => clk_line,
      clk_line_rst      => clk_line_rst,
      enable_processing => enable_processing,
      internal_rst_done => internal_rst_done,
      axis_in_TVALID    => axis_in_TVALID,
      axis_in_TREADY    => axis_in_TREADY,
      axis_in_TDATA     => axis_in_TDATA,
      axis_in_TKEEP     => axis_in_TKEEP,
      axis_in_TLAST     => axis_in_TLAST,
      axis_in_TUSER     => axis_in_TUSER,
      axis_out_TVALID   => axis_out_TVALID,
      axis_out_TREADY   => axis_out_TREADY,
      axis_out_TDATA    => axis_out_TDATA,
      axis_out_TKEEP    => axis_out_TKEEP,
      axis_out_TLAST    => axis_out_TLAST
    );
    
  p_clk_line: process
  begin
    wait for 6.4 ns;
    clk_line <= not clk_line;
  end process;

  p_stimulus: process
  begin
    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;
    clk_line_rst <= '0';
    
    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;
    enable_processing <= '1';    

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;
    internal_rst_done <= '1';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;
    
    -- Correct packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      if i = 10 then
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;

    -- Correct packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      if i = 10 then
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;
    
    -- Bad packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      if i = 10 then
        axis_in_TUSER  <= '1';
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';
    
    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;
    
    -- Bad packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;

    -- Correct packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      if i = 10 then
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;

    -- Giant packet
    for i in 1 to 300 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      if i = 300 then
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;

    -- Correct packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      if i = 10 then
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;

    -- Read packets
    for i in 1 to 400 loop
      axis_out_TREADY <= '1';
      wait until rising_edge(clk_line);
      axis_out_TREADY <= '0';
      wait until rising_edge(clk_line);
    end loop;

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;

    -- Correct packet
    for i in 1 to 10 loop
      axis_in_TVALID <= '1';
      axis_in_TDATA  <= std_logic_vector(to_unsigned(i, 64));
      axis_in_TKEEP  <= x"FF";
      axis_in_TLAST  <= '0';
      axis_in_TUSER  <= '0';
      if i = 10 then
        axis_in_TLAST <= '1';
      end if; 
      wait until rising_edge(clk_line);
    end loop;
    axis_in_TVALID <= '0';
    axis_in_TDATA  <= (others => '0');
    axis_in_TKEEP  <= (others => '0');
    axis_in_TLAST  <= '0';
    axis_in_TUSER  <= '0';

    for i in 1 to 10 loop
      wait until rising_edge(clk_line);
    end loop;

    -- Read packets
    for i in 1 to 400 loop
      axis_out_TREADY <= '1';
      wait until rising_edge(clk_line);
      axis_out_TREADY <= '0';
      wait until rising_edge(clk_line);
    end loop;
    
    wait;

  end process;

end TB;
