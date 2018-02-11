library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UniSim;
  use UniSim.VComponents.all;

library UniMacro;
  use UniMacro.VComponents.all;

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
END COMPONENT;

  signal mux_sel             : std_logic;
  signal dup_en              : std_logic;
  signal feedback_in_TVALID  : std_logic;
  signal feedback_in_TREADY  : std_logic;
  signal feedback_in_TDATA   : std_logic_vector(63 downto 0);
  signal feedback_in_TKEEP   : std_logic_vector(7 downto 0);
  signal feedback_in_TLAST   : std_logic;
  signal feedback_out_TVALID : std_logic;
  signal feedback_out_TREADY : std_logic;
  signal feedback_out_TDATA  : std_logic_vector(63 downto 0);
  signal feedback_out_TKEEP  : std_logic_vector(7 downto 0);
  signal feedback_out_TLAST  : std_logic;
  signal packet_cnt          : std_logic_vector(3 downto 0);
  signal tmp_rse_out_TVALID  : std_logic;
  signal tmp_rse_out_TLAST   : std_logic;
  signal enable              : std_logic;
  signal update              : std_logic;
  signal start_of_packet     : std_logic;
  signal fifo_din            : std_logic_vector(72 downto 0);
  signal fifo_wr_en          : std_logic;
  signal fifo_rd_en          : std_logic;
  signal fifo_dout           : std_logic_vector(72 downto 0);
  signal fifo_full           : std_logic;
  signal fifo_empty          : std_logic;

begin

  p_mux: process(mux_sel, axis_in_TVALID, rse_out_TREADY, axis_in_TDATA, axis_in_TKEEP, axis_in_TLAST,
                 feedback_out_TVALID, feedback_out_TDATA, feedback_out_TKEEP, feedback_out_TLAST)
  begin
    if mux_sel = '0' then
      tmp_rse_out_TVALID  <= axis_in_TVALID;
      axis_in_TREADY      <= rse_out_TREADY;
      feedback_out_TREADY <= '0';
      rse_out_TDATA       <= axis_in_TDATA;
      rse_out_TKEEP       <= axis_in_TKEEP;
      tmp_rse_out_TLAST   <= axis_in_TLAST;
    else
      tmp_rse_out_TVALID  <= feedback_out_TVALID;
      axis_in_TREADY      <= '0';
      feedback_out_TREADY <= rse_out_TREADY;
      rse_out_TDATA       <= feedback_out_TDATA;
      rse_out_TKEEP       <= feedback_out_TKEEP;
      tmp_rse_out_TLAST   <= feedback_out_TLAST;
    end if;
  end process;

  p_dup: process(dup_en, rse_in_TVALID, rse_in_TDATA, rse_in_TKEEP, rse_in_TLAST, axis_out_TREADY,
                 feedback_in_TREADY)
  begin
    if dup_en = '0' then
      feedback_in_TVALID <= '0';
      feedback_in_TDATA  <= (others => '0');
      feedback_in_TKEEP  <= (others => '0');
      feedback_in_TLAST  <= '0';
      rse_in_TREADY      <= axis_out_TREADY;
    else
      feedback_in_TVALID <= rse_in_TVALID;
      feedback_in_TDATA  <= rse_in_TDATA;
      feedback_in_TKEEP  <= rse_in_TKEEP;
      feedback_in_TLAST  <= rse_in_TLAST;
      rse_in_TREADY      <= axis_out_TREADY and feedback_in_TREADY;
    end if;
  end process;

  axis_out_TVALID <= rse_in_TVALID;
  axis_out_TDATA  <= rse_in_TDATA;
  axis_out_TKEEP  <= rse_in_TKEEP;
  axis_out_TLAST  <= rse_in_TLAST;

  p_packet_cnt: process(clk_line_rst, clk_line)
  begin
    if clk_line_rst = '1' then
      packet_cnt <= (others => '0');
    elsif rising_edge(clk_line) then
      if enable = '1' and tmp_rse_out_TLAST = '1' and tmp_rse_out_TVALID = '1' and rse_out_TREADY = '1' then
        if unsigned(packet_cnt) + 1 < 12 then
          packet_cnt <= std_logic_vector(unsigned(packet_cnt) + 1);
        else
          packet_cnt <= (others => '0');
        end if;
      end if;
    end if;
  end process;
  
  p_mux_sel: mux_sel <= '0' when unsigned(packet_cnt) < 8 else '1';
  
  p_dup_en: process(clk_line_rst, clk_line)
  begin
    if clk_line_rst = '1' then
      dup_en <= '0';
    elsif rising_edge(clk_line) then
      if enable = '1' and tuple_in_VALID = '1' then
        if unsigned(tuple_in_DATA(3 downto 0)) = 13 then
          dup_en <= '1';
        else
          dup_en <= '0';
        end if;
      end if;
    end if;
  end process;  

  rse_out_TVALID <= tmp_rse_out_TVALID;
  rse_out_TLAST  <= tmp_rse_out_TLAST;

  enable <= enable_processing and internal_rst_done;

  update <= rse_out_TREADY and tmp_rse_out_TVALID;

  p_start: process(clk_line_rst, clk_line)
  begin
    if clk_line_rst = '1' then
      start_of_packet <= '1';
    elsif rising_edge(clk_line) then
      if enable = '1' and update = '1' then
        start_of_packet <= tmp_rse_out_TLAST;
      end if;
    end if;
  end process;

  tuple_out_VALID <= update and start_of_packet;
  tuple_out_DATA  <= x"40" when mux_sel = '0' else x"30";

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
    
  fifo_din            <= feedback_in_TDATA & feedback_in_TKEEP & feedback_in_TLAST;
  fifo_wr_en          <= feedback_in_TVALID and feedback_in_TREADY;
  feedback_in_TREADY  <= not fifo_full;  
  feedback_out_TDATA  <= fifo_dout(72 downto 9);
  feedback_out_TKEEP  <= fifo_dout(8 downto 1);
  feedback_out_TLAST  <= fifo_dout(0); 
  feedback_out_TVALID <= not fifo_empty;
  fifo_rd_en          <= feedback_out_TREADY;

end RTL;