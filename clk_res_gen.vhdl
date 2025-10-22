library ieee;
use ieee.std_logic_1164.all;

entity clk_res_gen is
  generic (T: time := 20 ns);
  port (stop:       in  std_logic := '0';
        clk, res_n: out std_logic);
end entity clk_res_gen;

architecture behav of clk_res_gen is
begin
  process
  begin
    clk <= '1'; wait for T/2;
    clk <= '0'; wait for T/2;
    if stop = '1' then
      wait;
    end if;
  end process;

  process
  begin
    res_n <= '0'; wait for 0.75 * T;
    res_n <= '1'; wait;
  end process;
end architecture behav;
