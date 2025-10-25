library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interp is
  generic(PC_WIDTH: positive := 32; XLEN: positive := 32);
  port( clk, res_n:     in  std_logic;
        stall:          in  std_logic;
        pc:             in  std_logic_vector(PC_WIDTH-1 downto 0);
        ir:             in  std_logic_vector(31 downto 0);
        ir_n:           out std_logic_vector(31 downto 0);
        is_c, illegal:  out std_logic);
end entity interp;
