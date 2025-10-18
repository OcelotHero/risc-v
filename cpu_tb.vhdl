library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end entity cpu_tb;

architecture behav of cpu_tb is
  signal clk, res_n: std_logic;
begin

  osc:
    entity work.clk_res_gen
    generic map (T => 1 ns)
    port map (clk => clk, res_n => res_n);

  dut:
    entity work.cpu
    port map (clk => clk, res_n => res_n);
end architecture behav;
