library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmc is
  generic(K_BIT:      positive := 12;
          ADDR_WIDTH: positive := 32;
          OFFS_WIDTH: natural  := 0;
          WORD_WIDTH: positive := 32);
  port( clk, res_n:   in  std_logic;
        wena, kill:   in  std_logic;
        raddr, waddr: in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        wdata:        in  std_logic_vector(WORD_WIDTH*(2**OFFS_WIDTH)-1 downto 0);
        rdata:        out std_logic_vector(WORD_WIDTH*(2**OFFS_WIDTH)-1 downto 0);
        hit:          out std_logic);
end entity dmc;
