library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library XPM;
  use XPM.VComponents.all;

entity RSEInputBuffer is
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
end RSEInputBuffer;

architecture RTL of RSEInputBuffer is

  type input_state_type  is (input_state_idle, input_state_store,
                             input_state_drop);
  type output_state_type is (output_state_idle, output_state_check,
                             output_state_output, output_state_drop);

  signal enable                : std_logic;
  signal packet_fifo_din       : std_logic_vector(72 downto 0);
  signal packet_fifo_wr_en     : std_logic;
  signal packet_fifo_rd_en     : std_logic;
  signal packet_fifo_dout      : std_logic_vector(72 downto 0);
  signal packet_fifo_full      : std_logic;
  signal packet_fifo_empty     : std_logic;
  signal packet_fifo_prog_full : std_logic;
  signal valid_fifo_din        : std_logic_vector(0 downto 0);
  signal valid_fifo_wr_en      : std_logic;
  signal valid_fifo_rd_en      : std_logic;
  signal valid_fifo_dout       : std_logic_vector(0 downto 0);
  signal valid_fifo_full       : std_logic;
  signal valid_fifo_empty      : std_logic;
  signal input_state           : input_state_type;
  signal next_input_state      : input_state_type;
  signal output_state          : output_state_type;
  signal next_output_state     : output_state_type;
  signal last_word             : std_logic;

begin

  enable <= enable_processing and internal_rst_done;

  packet_fifo: xpm_fifo_sync
    generic map
    (
      FIFO_MEMORY_TYPE    => "auto",
      ECC_MODE            => "no_ecc",
      FIFO_WRITE_DEPTH    => 2048,
      WRITE_DATA_WIDTH    => 73,
      WR_DATA_COUNT_WIDTH => 9,
      PROG_FULL_THRESH    => 1847,
      FULL_RESET_VALUE    => 0,
      READ_MODE           => "std",
      FIFO_READ_LATENCY   => 1,
      READ_DATA_WIDTH     => 73,
      RD_DATA_COUNT_WIDTH => 9,
      PROG_EMPTY_THRESH   => 3,
      DOUT_RESET_VALUE    => "0",
      WAKEUP_TIME         => 0
    )
    port map
    (
      rst           => clk_line_rst,
      wr_clk        => clk_line,
      wr_en         => packet_fifo_wr_en,
      din           => packet_fifo_din,
      full          => packet_fifo_full,
      overflow      => open,
      wr_rst_busy   => open,
      rd_en         => packet_fifo_rd_en,
      dout          => packet_fifo_dout,
      empty         => packet_fifo_empty,
      underflow     => open,
      rd_rst_busy   => open,
      prog_full     => packet_fifo_prog_full,
      wr_data_count => open,
      prog_empty    => open,
      rd_data_count => open,
      sleep         => '0',
      injectsbiterr => '0',
      injectdbiterr => '0',
      sbiterr       => open,
      dbiterr       => open
    );

  valid_fifo: xpm_fifo_sync
    generic map
    (
      FIFO_MEMORY_TYPE    => "auto",
      ECC_MODE            => "no_ecc",
      FIFO_WRITE_DEPTH    => 2048,
      WRITE_DATA_WIDTH    => 1,
      WR_DATA_COUNT_WIDTH => 9,
      PROG_FULL_THRESH    => 1847,
      FULL_RESET_VALUE    => 0,
      READ_MODE           => "std",
      FIFO_READ_LATENCY   => 1,
      READ_DATA_WIDTH     => 1,
      RD_DATA_COUNT_WIDTH => 9,
      PROG_EMPTY_THRESH   => 3,
      DOUT_RESET_VALUE    => "0",
      WAKEUP_TIME         => 0
    )
    port map
    (
      rst           => clk_line_rst,
      wr_clk        => clk_line,
      wr_en         => valid_fifo_wr_en,
      din           => valid_fifo_din,
      full          => valid_fifo_full,
      overflow      => open,
      wr_rst_busy   => open,
      rd_en         => valid_fifo_rd_en,
      dout          => valid_fifo_dout,
      empty         => valid_fifo_empty,
      underflow     => open,
      rd_rst_busy   => open,
      prog_full     => open,
      wr_data_count => open,
      prog_empty    => open,
      rd_data_count => open,
      sleep         => '0',
      injectsbiterr => '0',
      injectdbiterr => '0',
      sbiterr       => open,
      dbiterr       => open
    );
    
  packet_fifo_din <= axis_in_TDATA & axis_in_TKEEP & last_word;

  axis_out_TDATA <= packet_fifo_dout(72 downto 9);
  axis_out_TKEEP <= packet_fifo_dout(8 downto 1);
  axis_out_TLAST <= packet_fifo_dout(0); 

  axis_in_TREADY <= '1';
    
  p_input_fsm_sync: process(clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        input_state <= input_state_idle;
      elsif enable = '1' then
        input_state <= next_input_state;
      end if;
    end if;
  end process;
  
  p_input_fsm_async: process(input_state, enable, axis_in_TVALID, axis_in_TLAST,
                             axis_in_TUSER, packet_fifo_prog_full)
  begin
    packet_fifo_wr_en <= '0';
    valid_fifo_wr_en <= '0';
    valid_fifo_din <= "0";
    last_word <= axis_in_TLAST;
    next_input_state <= input_state;

    case input_state is

      when input_state_idle =>
        if enable = '1' and axis_in_TVALID = '1' then
          if packet_fifo_prog_full = '0' then
            packet_fifo_wr_en <= '1';
            next_input_state <= input_state_store;
          else
            next_input_state <= input_state_drop;
          end if;
        end if;

      when input_state_store =>
        if axis_in_TVALID = '1' and axis_in_TUSER = '0' then
          packet_fifo_wr_en <= '1';
          if axis_in_TLAST = '1' then
            valid_fifo_wr_en <= '1';
            valid_fifo_din <= "1";
            next_input_state <= input_state_idle;
          end if;
        else
          packet_fifo_wr_en <= '1';
          valid_fifo_wr_en <= '1';
          last_word <= '1';
          next_input_state <= input_state_idle;
        end if;

      when input_state_drop =>
        if axis_in_TVALID = '1' and axis_in_TLAST = '1' then
          next_input_state <= input_state_idle;
        end if;

    end case;
  end process;

  p_output_fsm_sync: process(clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        output_state <= output_state_idle;
      elsif enable = '1' then
        output_state <= next_output_state;
      end if;
    end if;
  end process;
  
  p_output_fsm_async: process(output_state, enable, valid_fifo_empty, axis_out_TREADY,
                              valid_fifo_dout, packet_fifo_dout)
  begin
    packet_fifo_rd_en <= '0';
    valid_fifo_rd_en <= '0';
    axis_out_TVALID <= '0';
    next_output_state <= output_state;

    case output_state is

      when output_state_idle =>
        if enable = '1' and valid_fifo_empty = '0' then
          packet_fifo_rd_en <= '1';
          valid_fifo_rd_en <= '1';
          next_output_state <= output_state_check;
        end if;

      when output_state_check =>
        if valid_fifo_dout = "1" then
          axis_out_TVALID <= '1';
          if axis_out_TREADY = '1' then
            if packet_fifo_dout(0) = '0' then
              packet_fifo_rd_en <= '1';
              next_output_state <= output_state_output;
            elsif valid_fifo_empty = '0' then
              packet_fifo_rd_en <= '1';
              valid_fifo_rd_en <= '1';        
            else
              next_output_state <= output_state_idle;              
            end if;
          else
            next_output_state <= output_state_output;
          end if;
        else
          if packet_fifo_dout(0) = '0' then
            next_output_state <= output_state_drop;
          else
            next_output_state <= output_state_idle;            
          end if;
        end if;

      when output_state_output =>
        axis_out_TVALID <= '1';
        if axis_out_TREADY = '1' then
          if packet_fifo_dout(0) = '0' then
            packet_fifo_rd_en <= '1';
          elsif valid_fifo_empty = '0' then
            packet_fifo_rd_en <= '1';
            valid_fifo_rd_en <= '1';        
            next_output_state <= output_state_check;
          else
            next_output_state <= output_state_idle;              
          end if;
        end if;

      when output_state_drop =>
        if packet_fifo_dout(0) = '0' then
          packet_fifo_rd_en <= '1';
          next_output_state <= output_state_drop;
        elsif valid_fifo_empty = '0' then
          packet_fifo_rd_en <= '1';
          valid_fifo_rd_en <= '1';        
          next_output_state <= output_state_check;
        else
          next_output_state <= output_state_idle;              
        end if;

    end case;
  end process;

end RTL;
