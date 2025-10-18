architecture behav of reg is
begin
  process(clk, res_n)
  begin
    if res_n = '0' then
      q <= (others => (others => '0'));
    elsif rising_edge(clk) and stall = '0' then
      q <= d;
    end if;
  end process;
end architecture behav;
