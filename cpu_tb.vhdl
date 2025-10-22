library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end entity cpu_tb;

architecture behav of cpu_tb is
  signal clk, res_n, stop: std_logic;
  signal count: natural range 0 to 5 := 0;
begin

  osc:
    entity work.clk_res_gen
    generic map (T => 1 ns)
    port map (clk => clk, res_n => res_n, stop => stop);

  dut:
    entity work.cpu
    port map (clk => clk, res_n => res_n);

  count_nop: process(clk, res_n) is
  begin

    if res_n = '0' then
      count <= 0;
      stop <= '0';
    elsif rising_edge(clk) then
      if count = 4 then
        stop <= '1';
      elsif <<signal dut.ir_dc: std_logic_vector(31 downto 0)>> = x"00000013" then
        count <= count + 1;
      else
        count <= 0;
      end if;
    end if;
  end process count_nop;
end architecture behav;
