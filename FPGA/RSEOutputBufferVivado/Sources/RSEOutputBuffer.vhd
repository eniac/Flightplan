library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UniSim;
  use UniSim.VComponents.all;

library UniMacro;
  use UniMacro.VComponents.all;

entity RSEOutputBuffer is
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
    axis_out_TVALID   : out std_logic;
    axis_out_TREADY   : in  std_logic;
    axis_out_TDATA    : out std_logic_vector(63 downto 0);
    axis_out_TKEEP    : out std_logic_vector(7 downto 0);
    axis_out_TLAST    : out std_logic;
    axis_out_TUSER    : out std_logic
  );
end RSEOutputBuffer;

architecture RTL of RSEOutputBuffer is

  component fifo
    port
    (
      clk         : in  std_logic;
      srst        : in  std_logic;
      din         : in  std_logic_vector(72 downto 0);
      wr_en       : in  std_logic;
      rd_en       : in  std_logic;
      dout        : out std_logic_vector(72 downto 0);
      full        : out std_logic;
      empty       : out std_logic;
      prog_full   : out std_logic;
      wr_rst_busy : out std_logic;
      rd_rst_busy : out std_logic
    );
  end component;

  type state_type is (state_idle, state_output);

  signal enable           : std_logic;
  signal fifo_din         : std_logic_vector(72 downto 0);
  signal fifo_wr_en       : std_logic;
  signal fifo_rd_en       : std_logic;
  signal fifo_dout        : std_logic_vector(72 downto 0);
  signal fifo_full        : std_logic;
  signal fifo_empty       : std_logic;
  signal fifo_prog_full   : std_logic;
  signal state            : state_type;
  signal next_state       : state_type;
  signal packet_cnt       : std_logic_vector(3 downto 0);
  signal inc_packet_cnt   : std_logic;
  signal dec_packet_cnt   : std_logic;
  signal packet_available : std_logic;

begin

  enable <= enable_processing and internal_rst_done;

  fifo_0: fifo
    port map
    (
      clk         => clk_line,
      srst        => clk_line_rst,
      din         => fifo_din,
      wr_en       => fifo_wr_en,
      rd_en       => fifo_rd_en,
      dout        => fifo_dout,
      full        => fifo_full,
      empty       => fifo_empty,
      prog_full   => fifo_prog_full,
      wr_rst_busy => open,
      rd_rst_busy => open
    );

  fifo_din <= axis_in_TDATA & axis_in_TKEEP & axis_in_TLAST;
  fifo_wr_en <= enable and axis_in_TVALID and not fifo_prog_full;

  axis_in_TREADY <= not fifo_prog_full;

  inc_packet_cnt <= axis_in_TVALID and axis_in_TLAST and not fifo_prog_full;

  p_packet_cnt: process(clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        packet_cnt <= std_logic_vector(to_unsigned(0, 4));
      elsif enable = '1' then
        if inc_packet_cnt = '1' and dec_packet_cnt = '0' then
          packet_cnt <= std_logic_vector(unsigned(packet_cnt) + 1);
        elsif inc_packet_cnt = '0' and dec_packet_cnt = '1' then
          packet_cnt <= std_logic_vector(unsigned(packet_cnt) - 1);
        end if;
      end if;
    end if;
  end process;

  packet_available <= '1' when unsigned(packet_cnt) > 0 else '0';

  p_fsm_sync: process(clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        state <= state_idle;
      elsif enable = '1' then
        state <= next_state;
      end if;
    end if;
  end process;
  
  p_fsm_async: process(state, enable, packet_available, axis_out_TREADY,
                       fifo_dout)
  begin
    fifo_rd_en      <= '0';
    axis_out_TVALID <= '0';
    dec_packet_cnt  <= '0';
    next_state      <= state;

    case state is

      when state_idle =>
        if enable = '1' and packet_available = '1' then
          fifo_rd_en     <= '1';
          dec_packet_cnt <= '1';
          next_state     <= state_output;
        end if;

      when state_output =>
        axis_out_TVALID <= '1';
        if axis_out_TREADY = '1' then
          if fifo_dout(0) = '0' then
            fifo_rd_en <= '1';
            next_state <= state_output;
          elsif packet_available = '1' then
            fifo_rd_en     <= '1';
            dec_packet_cnt <= '1';
          else
            next_state <= state_idle;              
          end if;
        end if;

    end case;
  end process;

  axis_out_TDATA <= fifo_dout(72 downto 9);
  axis_out_TKEEP <= fifo_dout(8 downto 1);
  axis_out_TLAST <= fifo_dout(0); 
  axis_out_TUSER <= '0';

end RTL;
