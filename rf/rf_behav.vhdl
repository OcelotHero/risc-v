architecture behav of rf is
  type ram_array is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

  signal ram: ram_array := (others => (others => '0'));
begin

  write_reset: process(clk) is
  begin
    if res_n = '0' then
      ram <= (others => (others => '0'));
    elsif rising_edge(clk) and (or rd_addr /= '0') then
      ram(to_integer(unsigned(rd_addr))) <= rd;
    end if;
  end process write_reset;

  read:
    rs1 <= ram(to_integer(unsigned(rs1_addr)));
    rs2 <= ram(to_integer(unsigned(rs2_addr)));
end architecture behav;
