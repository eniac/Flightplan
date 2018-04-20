library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity TupleGenerator is
  port
  (
    clk_line                   : in  std_logic;
    clk_line_rst               : in  std_logic;
    enable_processing          : in  std_logic;
    internal_rst_done          : in  std_logic;
    packet_in_packet_in_TVALID : in  std_logic;
    packet_in_packet_in_TREADY : in  std_logic;
    packet_in_packet_in_TDATA  : in  std_logic_vector(63 downto 0);
    packet_in_packet_in_TKEEP  : in  std_logic_vector(7 downto 0);
    packet_in_packet_in_TLAST  : in  std_logic;
    tuple_in_unused_VALID      : out std_logic;
    tuple_in_unused_DATA       : out std_logic_vector(7 downto 0)
  );
end TupleGenerator;

architecture RTL of TupleGenerator is

  signal update          : std_logic;
  signal start_of_packet : std_logic;

begin

  update <= enable_processing and internal_rst_done and packet_in_packet_in_TREADY and packet_in_packet_in_TVALID;

  p_start: process(clk_line_rst, clk_line)
  begin
    if clk_line_rst = '1' then
      start_of_packet <= '1';
    elsif rising_edge(clk_line) then
      if update = '1' then
        start_of_packet <= packet_in_packet_in_TLAST;
      end if;
    end if;
  end process;

  tuple_in_unused_VALID <= update and start_of_packet;
  tuple_in_unused_DATA <= (others => '0');  

end RTL;
