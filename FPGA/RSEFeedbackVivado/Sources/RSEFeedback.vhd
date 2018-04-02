library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UniSim;
  use UniSim.VComponents.all;

library UniMacro;
  use UniMacro.VComponents.all;

library Work;
  use Work.Config.all;

entity RSEFeedback is
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
    rse_in_TVALID     : in  std_logic;
    rse_in_TREADY     : out std_logic;
    rse_in_TDATA      : in  std_logic_vector(63 downto 0);
    rse_in_TKEEP      : in  std_logic_vector(7 downto 0);
    rse_in_TLAST      : in  std_logic;
    tuple_in_VALID    : in  std_logic;
    tuple_in_DATA     : in  std_logic_vector(7 downto 0);
    axis_out_TVALID   : out std_logic;
    axis_out_TREADY   : in  std_logic;
    axis_out_TDATA    : out std_logic_vector(63 downto 0);
    axis_out_TKEEP    : out std_logic_vector(7 downto 0);
    axis_out_TLAST    : out std_logic;
    rse_out_TVALID    : out std_logic;
    rse_out_TREADY    : in  std_logic;
    rse_out_TDATA     : out std_logic_vector(63 downto 0);
    rse_out_TKEEP     : out std_logic_vector(7 downto 0);
    rse_out_TLAST     : out std_logic;
    tuple_out_VALID   : out std_logic;
    tuple_out_DATA    : out std_logic_vector(7 downto 0)
  );
end RSEFeedback;

architecture RTL of RSEFeedback is

  component fifo_generator_0
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
      wr_rst_busy : out std_logic;
      rd_rst_busy : out std_logic
    );
  end component;

  type input_state_type  is (input_state_data_start, input_state_data,
                             input_state_feedback_wait,
                             input_state_feedback_start, input_state_feedback);
  type output_state_type is (output_state_check, output_state_data,
                             output_state_duplicate);

  signal enable                : std_logic;
  signal fifo_din              : std_logic_vector(72 downto 0);
  signal fifo_wr_en            : std_logic;
  signal fifo_rd_en            : std_logic;
  signal fifo_dout             : std_logic_vector(72 downto 0);
  signal fifo_full             : std_logic;
  signal fifo_empty            : std_logic;
  signal mux_sel               : std_logic;
  signal input_state           : input_state_type;
  signal next_input_state      : input_state_type;
  signal output_state          : output_state_type;
  signal next_output_state     : output_state_type;
  signal inc_input_packet_cnt  : std_logic;
  signal input_packet_cnt      : std_logic_vector(FEC_PACKET_INDEX_WIDTH - 1 downto 0);
  signal dec_fifo_packet_cnt   : std_logic;
  signal inc_fifo_packet_cnt   : std_logic;
  signal last_data_packet      : std_logic;
  signal last_feedback_packet  : std_logic;
  signal fifo_packet_cnt       : std_logic_vector(3 downto 0);
  signal fifo_has_packet       : std_logic;
  signal fifo_has_packet_delay : std_logic_vector(2 downto 0);
  signal output_duplicate      : std_logic;

begin

  enable <= enable_processing and internal_rst_done;

  fifo : fifo_generator_0
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
      wr_rst_busy => open,
      rd_rst_busy => open
    );

  fifo_din <= rse_in_TDATA & rse_in_TKEEP & rse_in_TLAST;

  p_mux: process(mux_sel, axis_in_TDATA, axis_in_TKEEP, axis_in_TLAST,
                 rse_out_TREADY, fifo_dout)
  begin
    if mux_sel = '0' then
      rse_out_TDATA  <= axis_in_TDATA;
      rse_out_TKEEP  <= axis_in_TKEEP;
      rse_out_TLAST  <= axis_in_TLAST;
      axis_in_TREADY <= rse_out_TREADY;
    else
      rse_out_TDATA  <= fifo_dout(72 downto 9);
      rse_out_TKEEP  <= fifo_dout(8 downto 1);
      rse_out_TLAST  <= fifo_dout(0);
      axis_in_TREADY <= '0';
    end if;
  end process;

  axis_out_TDATA  <= rse_in_TDATA;
  axis_out_TVALID <= rse_in_TVALID;
  axis_out_TKEEP  <= rse_in_TKEEP;
  axis_out_TLAST  <= rse_in_TLAST;
  rse_in_TREADY   <= axis_out_TREADY;

  tuple_out_DATA  <= x"40" when mux_sel = '0' else x"30";

  p_input_fsm_sync: process(clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        input_state <= input_state_data_start;
      elsif enable = '1' then
        input_state <= next_input_state;
      end if;
    end if;
  end process;
  
  p_input_fsm_async: process(input_state, axis_in_TVALID, rse_out_TREADY,
                             axis_in_TLAST, last_data_packet,
                             fifo_has_packet_delay, fifo_dout, enable)
  begin
    rse_out_TVALID       <= '0';
    mux_sel              <= '0';
    inc_input_packet_cnt <= '0';
    fifo_rd_en           <= '0';
    dec_fifo_packet_cnt  <= '0';
    tuple_out_VALID      <= '0';
    next_input_state     <= input_state;

    case input_state is

      when input_state_data_start =>
        rse_out_TVALID        <= axis_in_TVALID;
        tuple_out_VALID       <= enable;
        next_input_state      <= input_state_data;

      when input_state_data =>
        rse_out_TVALID <= axis_in_TVALID;
        if axis_in_TVALID = '1' and rse_out_TREADY = '1' and axis_in_TLAST = '1' then
          inc_input_packet_cnt  <= '1';
          if last_data_packet = '1' then
            if fifo_has_packet_delay(fifo_has_packet_delay'left) = '1' then
              fifo_rd_en          <= '1';
              dec_fifo_packet_cnt <= '1';
              next_input_state    <= input_state_feedback_start;
            else
              next_input_state    <= input_state_feedback_wait;
            end if;
          else
            tuple_out_VALID       <= '1';
          end if;
        end if;

      when input_state_feedback_wait =>
        mux_sel               <= '1';
        if fifo_has_packet_delay(fifo_has_packet_delay'left) = '1' then
          fifo_rd_en          <= '1';
          dec_fifo_packet_cnt <= '1';
          next_input_state    <= input_state_feedback_start;
        end if;

      when input_state_feedback_start =>
        rse_out_TVALID        <= '1';
        mux_sel               <= '1';
        tuple_out_VALID       <= '1';
        if rse_out_TREADY = '1' then
          fifo_rd_en <= '1';
        end if;
        next_input_state      <= input_state_feedback;

      when input_state_feedback =>
        rse_out_TVALID        <= '1';
        mux_sel               <= '1';
        if rse_out_TREADY = '1' then
          if fifo_dout(0) = '0' then
            fifo_rd_en <= '1';
          else
            inc_input_packet_cnt  <= '1';
            if last_feedback_packet = '1' then
              next_input_state <= input_state_data_start;
            elsif fifo_has_packet_delay(fifo_has_packet_delay'left) = '1' then
              fifo_rd_en       <= '1';
              next_input_state <= input_state_feedback_start;
            else
              next_input_state <= input_state_feedback_wait;
            end if;
          end if;
        end if;

    end case;
  end process;

  p_input_packet_cnt: process(clk_line_rst, clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        input_packet_cnt <= (others => '0');
      elsif enable = '1' and inc_input_packet_cnt = '1' then
        if last_feedback_packet = '0' then
          input_packet_cnt <= std_logic_vector(unsigned(input_packet_cnt) + 1);
        else
          input_packet_cnt <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  last_data_packet     <= '1' when unsigned(input_packet_cnt) = FEC_K - 1 else '0';
  last_feedback_packet <= '1' when unsigned(input_packet_cnt) = FEC_K + FEC_H - 1 else '0';

  p_output_fsm_sync: process(clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        output_state <= output_state_check;
      elsif enable = '1' then
        output_state <= next_output_state;
      end if;
    end if;
  end process;
  
  p_output_fsm_async: process(output_state, tuple_in_VALID, output_duplicate,
                              rse_in_TVALID, axis_out_TREADY, rse_in_TLAST)
  begin
    fifo_wr_en          <= '0';
    inc_fifo_packet_cnt <= '0';
    next_output_state   <= output_state;

    case output_state is

      when output_state_check =>
        if tuple_in_VALID = '1' then
          if output_duplicate = '0' then
            next_output_state <= output_state_data;
          else
            if rse_in_TVALID = '1' and axis_out_TREADY = '1' then
              fifo_wr_en <= '1';
            end if;
            next_output_state <= output_state_duplicate;
          end if;
        end if;

      when output_state_data =>
        if rse_in_TVALID = '1' and axis_out_TREADY = '1' then
          if rse_in_TLAST = '1' then
            next_output_state <= output_state_check;
          end if;
        end if;

      when output_state_duplicate =>
        if rse_in_TVALID = '1' and axis_out_TREADY = '1' then
          fifo_wr_en <= '1';
          if rse_in_TLAST = '1' then
            inc_fifo_packet_cnt <= '1';
            next_output_state <= output_state_check;
          end if;
        end if;
 
    end case;
  end process;

  p_fifo_packet_cnt: process(clk_line_rst, clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        fifo_packet_cnt <= (others => '0');
      elsif enable = '1' then
        if inc_fifo_packet_cnt = '1' and dec_fifo_packet_cnt = '0' then
          fifo_packet_cnt <= std_logic_vector(unsigned(fifo_packet_cnt) + 1);
        elsif dec_fifo_packet_cnt = '1' and inc_fifo_packet_cnt = '0' then
          fifo_packet_cnt <= std_logic_vector(unsigned(fifo_packet_cnt) - 1);
        end if;
      end if;
    end if;
  end process;

  fifo_has_packet <= '0' when unsigned(fifo_packet_cnt) = 0 else '1';

  p_fifo_has_packet_delay: process(clk_line_rst, clk_line)
  begin
    if rising_edge(clk_line) then
      if clk_line_rst = '1' then
        fifo_has_packet_delay <= (others => '0');
      elsif enable = '1' then
        fifo_has_packet_delay <= fifo_has_packet_delay(fifo_has_packet_delay'left - 1 downto 0) & fifo_has_packet;
      end if;
    end if;
  end process;

  output_duplicate <= '0' when unsigned(tuple_in_DATA(3 downto 0)) = 0 else '1';

end RTL;
