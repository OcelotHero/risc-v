library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cs is
  generic(DATA_WIDTH: positive := 32; STACK_IDX_WIDTH: positive := 4);
  port( clk, res_n:     in  std_logic;
        push, pop, clr: in  std_logic;
        wdata:          in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rdata:          out std_logic_vector(DATA_WIDTH-1 downto 0);
        full, empty:    out std_logic);
end entity cs;
